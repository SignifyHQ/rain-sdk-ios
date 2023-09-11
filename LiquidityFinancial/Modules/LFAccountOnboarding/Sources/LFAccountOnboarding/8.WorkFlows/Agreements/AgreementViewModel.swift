import Foundation
import LFUtilities
import LFLocalizable
import SwiftUI
import NetSpendData
import LFServices
import Factory
import SwiftSoup

@MainActor
public final class AgreementViewModel: ObservableObject {
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @Published var isNavigationPersonalInformation: Bool = false
  @Published var isDisableButton: Bool = true
  @Published var conditions: [ServiceConditionModel] = []
  @Published var condition: ServiceConditionModel?
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var isAcceptAgreementLoading: Bool = false
  
  private(set) var isAcceptAgreement: Bool = false

  private var fundingAgreement: APIAgreementData?
  
  var showConditions: [ServiceConditionModel] {
    guard let condition = condition else {
      return conditions
    }
    return [condition]
  }
  
  public init(fundingAgreement: APIAgreementData? = nil) {
    self.fundingAgreement = fundingAgreement
    checkData()
  }
    
  func continute() {
    isNavigationPersonalInformation = true
  }
  
  func openIntercom() {
    intercomService.openIntercom()
  }
  
  private func checkData() {
    if let fundingAgreement = fundingAgreement {
      mapToServiceCondition(agreementData: fundingAgreement)
    } else if let agreementData = netspendDataManager.agreement {
      mapToServiceCondition(agreementData: agreementData)
    } else {
      Task { @MainActor in
        defer { isLoading = false }
        isLoading = true
        do {
          let agreementData = try await nsPersionRepository.getAgreement()
          netspendDataManager.update(agreement: agreementData)
          mapToServiceCondition(agreementData: agreementData)
        } catch {
          log.error(error)
          toastMessage = error.localizedDescription
        }
      }
    }
  }
  
  func apiPostAgreements(onNext: @escaping () -> Void) {
    Task {
      defer { isAcceptAgreementLoading = false }
      isAcceptAgreementLoading = true
      do {
        let ids: [String] = fundingAgreement?.agreements.map({ $0.id }) ?? []
        let body: [String: Any] = [
          "agreementIds": ids
        ]
        let entity = try await nsPersionRepository.postAgreement(body: body)
        if entity {
          isAcceptAgreement = true
          onNext()
        }
      } catch {
        log.error(error.localizedDescription)
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: View Helpers
extension AgreementViewModel {
  func getURL(tappedString: String) -> String {
    if let url = condition?.attributeInformation[tappedString] {
      return url
    }
    let itemTapped = conditions.first(where: { $0.attributeInformation[tappedString] != nil })
    return itemTapped?.attributeInformation[tappedString] ?? ""
  }
  
  func updateSelectedAgreementItem(agreementID: String, selected: Bool) {
    if let condition = condition, condition.id == agreementID {
      condition.update(selected: selected)
    } else {
      conditions.first(where: { $0.id == agreementID })?.update(selected: selected)
    }
    isEnableButton()
    self.objectWillChange.send()
  }
}

// MARK: Private Functions
private extension AgreementViewModel {
  func isEnableButton() {
    if let condition = condition {
      isDisableButton = !condition.selected
    } else {
      isDisableButton = conditions.contains(where: { $0.selected == false })
    }
  }
  
  func mapToServiceGenericCondition(description: String) {
    do {
      let html: String = description
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
        id: UUID().uuidString,
        message: text,
        attributeInformation: attributeInformation
      )
      self.condition = condition
    } catch {
      log.error(error)
    }
  }
  
  func mapToServiceCondition(agreementData: APIAgreementData) {
    if let description = agreementData.description {
      mapToServiceGenericCondition(description: description)
    }
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
  }
}
