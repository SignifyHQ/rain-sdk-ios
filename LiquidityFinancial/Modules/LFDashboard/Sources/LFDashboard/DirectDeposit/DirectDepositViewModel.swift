import Foundation
import UIKit
import LFLocalizable
import LFUtilities

@MainActor
final class DirectDepositViewModel: ObservableObject {
  @Published var toastMessage: String?
  @Published var directDepositLoading: Bool = false
  @Published var isShowAllBenefits: Bool = false
  @Published var isNavigateToDirectDepositForm: Bool = false
  
  let accountNumber: String
  let routingNumber: String
  
  init() {
    //TODO: Will be updated later
    accountNumber = "939383401273847"
    routingNumber = "121124125"
  }
}

// MARK: - View Helpers
extension DirectDepositViewModel {
  func onClickedSeeAllBenefitsButton() {
    isShowAllBenefits = true
  }
  
  func automationSetup() {
    Task {
      await loadPinWheel()
    }
  }
  
  func manualSetup() {
    isNavigateToDirectDepositForm = true
  }
  
  func copy(text: String) {
    let pasteboard = UIPasteboard.general
    pasteboard.string = text
    Haptic.impact(.medium).generate()
    toastMessage = LFLocalizable.DirectDeposit.Copied.message
  }
}

// MARK: - Private Functions
private extension DirectDepositViewModel {
  func loadPinWheel() async {
  }
}
