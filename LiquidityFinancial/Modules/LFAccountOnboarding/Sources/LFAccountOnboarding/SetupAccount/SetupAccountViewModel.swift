import Foundation
import LFUtilities
import LFLocalizable
import SwiftUI

@MainActor
final class SetupAccountViewModel: ObservableObject {
  @Published var isDisableButton: Bool = true
  @Published var isAgreedNetSpendCondition: Bool = false {
    didSet {
      isEnableButton()
    }
  }
  @Published var isAgreedPathwardCondition: Bool = false {
    didSet {
      isEnableButton()
    }
  }
  
  let netspendCondition = ServiceCondition(
    message: LFLocalizable.SetUpAccount.NetpendCondition.description,
    attributeInformation: Constants.netspendAttributeInformation
  )
  let pathwardCondition = ServiceCondition(
    message: LFLocalizable.SetUpAccount.PathwardCondition.description,
    attributeInformation: Constants.pathwardAttributeInformation
  )
  
  init() {}
}

// MARK: View Helpers
extension SetupAccountViewModel {
  func openIntercom() {
    // TODO: Will be implemented later
    // intercomService.openIntercom()
  }
  
  func getURL(tappedString: String) -> String {
    Constants.netspendAttributeInformation[tappedString] ?? Constants.pathwardAttributeInformation[tappedString] ?? ""
  }
}

// MARK: Private Functions
private extension SetupAccountViewModel {
  func isEnableButton() {
    isDisableButton = !(isAgreedNetSpendCondition && isAgreedPathwardCondition)
  }
}
