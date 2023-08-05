import Foundation
import LFUtilities
import LFLocalizable
import SwiftUI
import NetSpendData
import LFServices
import Factory

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
    isDisableButton = agreements.first(where: { $0.selected == false }) != nil
  }
  
  func mapToServiceCondition() {
    guard let agreementData = netspendDataManager.agreement else { return }
    var agreementList: [ServiceConditionModel] = []
    for item in agreementData.agreements {
      let component = item.description.components(separatedBy: "\"")
      if let message = component.first?.replacingOccurrences(of: " <a href=", with: ""),
         let linkIndex = component.firstIndex(where: { $0.contains("http") }),
         let key = message.components(separatedBy: ": ").last {
        let link = component[linkIndex]
        let condition = ServiceConditionModel(
          id: item.id,
          message: message,
          attributeInformation: [key : link]
        )
        agreementList.append(condition)
      }
    }
    self.agreements = agreementList
  }
}
