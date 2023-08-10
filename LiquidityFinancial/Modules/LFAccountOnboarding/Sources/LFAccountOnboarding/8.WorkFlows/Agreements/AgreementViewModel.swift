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
  
  @Published var isNavigationPersonalInformation: Bool = false
  @Published var isDisableButton: Bool = true
  @Published var agreements: [ServiceConditionModel] = []
  
  init() {
    mapToServiceCondition()
  }
    
  func openIntercom() {
    intercomService.openIntercom()
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
  
  func mapToServiceCondition() {
    guard let agreementData = netspendDataManager.agreement else { return }
    var agreementList: [ServiceConditionModel] = []
    for item in agreementData.agreements {
      do {
        let html: String = item.description
        let doc: SwiftSoup.Document = try SwiftSoup.parse(html)
        let text: String = try doc.body()!.text()
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
