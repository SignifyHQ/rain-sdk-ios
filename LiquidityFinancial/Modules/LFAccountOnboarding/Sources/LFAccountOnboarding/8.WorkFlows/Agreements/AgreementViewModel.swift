import Foundation
import LFUtilities
import LFLocalizable
import SwiftUI
import NetSpendData

@MainActor
final class AgreementViewModel: ObservableObject {
  
  @Published var isNavigationPersonalInformation: Bool = false
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
    message: LFLocalizable.Question.NetpendCondition.description,
    attributeInformation: Constants.netspendAttributeInformation
  )
  let pathwardCondition = ServiceCondition(
    message: LFLocalizable.Question.PathwardCondition.description,
    attributeInformation: Constants.pathwardAttributeInformation
  )
}

// MARK: View Helpers
extension AgreementViewModel {
  func openIntercom() {
    // TODO: Will be implemented later
    // intercomService.openIntercom()
  }
  
  func getURL(tappedString: String) -> String {
    Constants.netspendAttributeInformation[tappedString] ?? Constants.pathwardAttributeInformation[tappedString] ?? ""
  }
}

// MARK: Private Functions
private extension AgreementViewModel {
  func isEnableButton() {
    isDisableButton = !isAgreedNetSpendCondition//!(isAgreedNetSpendCondition && isAgreedPathwardCondition)
  }
}
