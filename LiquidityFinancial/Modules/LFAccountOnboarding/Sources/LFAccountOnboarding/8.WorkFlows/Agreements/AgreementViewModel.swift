import Foundation
import LFUtilities
import LFLocalizable
import SwiftUI
import NetSpendData
import LFServices
import Factory
import SwiftSoup

@MainActor
final class AgreementViewModel: ObservableObject {
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendRepository) var netspendRepository
  
  @Published var isNavigationPersonalInformation: Bool = false
  @Published var isDisableButton: Bool = true
  @Published var agreements: [ServiceConditionModel] = []
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  init() {
    checkData()
  }
    
  func openIntercom() {
    intercomService.openIntercom()
  }
  
  private func checkData() {
    if let agreementData = netspendDataManager.agreement {
      mapToServiceCondition(agreementData: agreementData)
    } else {
      intercomService.loginIdentifiedUser(userAttributes: IntercomService.UserAttributes(phone: accountDataManager.phoneNumber))
      
      Task { @MainActor in
        defer { isLoading = false }
        isLoading = true
        do {
          let agreementData = try await netspendRepository.getAgreement()
          netspendDataManager.update(agreement: agreementData)
          mapToServiceCondition(agreementData: agreementData)
        } catch {
          log.error(error)
          toastMessage = error.localizedDescription
        }
      }
    }
  }
}

// MARK: View Helpers
extension AgreementViewModel {
  func getURL(tappedString: String) -> String {
    let itemTapped = agreements.first(where: { $0.attributeInformation[tappedString] != nil })
    return itemTapped?.attributeInformation[tappedString] ?? ""
  }
  
  func updateSelectedAgreementItem(agreementID: String, selected: Bool) {
    agreements.first(where: { $0.id == agreementID })?.update(selected: selected)
    isEnableButton()
    self.objectWillChange.send()
  }
}

// MARK: Private Functions
private extension AgreementViewModel {
  func isEnableButton() {
    isDisableButton = agreements.contains(where: { $0.selected == false })
  }
  
  func mapToServiceCondition(agreementData: APIAgreementData) {
    var agreementList: [ServiceConditionModel] = []
    for item in agreementData.agreements {
      do {
        let html: String = item.description
        let doc: SwiftSoup.Document = try SwiftSoup.parse(html)
        let text: String = try doc.body()?.text() ?? ""
        let links: [SwiftSoup.Element] = try doc.select("a").array()
        var attributeInformation: [String: String] = [:]
        for link in links {
          let linkHref: String = try link.attr("href")
          let linkText: String = try link.text()
          attributeInformation[linkText] = linkHref
        }
        let condition = ServiceConditionModel(
          id: item.id,
          message: text,
          attributeInformation: attributeInformation
        )
        agreementList.append(condition)
      } catch {
        log.error(error)
      }
    }
    self.agreements = agreementList
  }
}
