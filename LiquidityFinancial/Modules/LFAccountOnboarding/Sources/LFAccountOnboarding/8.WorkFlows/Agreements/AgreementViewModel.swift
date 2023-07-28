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
  
  func openIntercom() {
    intercomService.openIntercom()
  }
}

// MARK: View Helpers
extension AgreementViewModel {
  func getURL(tappedString: String) -> String {
    Constants.netspendAttributeInformation[tappedString] ?? Constants.pathwardAttributeInformation[tappedString] ?? ""
  }
}

// MARK: Private Functions
private extension AgreementViewModel {
  func isEnableButton() {
    isDisableButton = !(isAgreedNetSpendCondition && isAgreedPathwardCondition)
  }
}
