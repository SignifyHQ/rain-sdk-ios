import Foundation
import UIKit
import LFLocalizable
import LFUtilities
import Services
import Factory
import NetSpendData
import NetspendDomain

@MainActor
final class DirectDepositViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository

  @Published var directDepositLoading: Bool = false
  @Published var isShowAllBenefits: Bool = false
  @Published var isNavigateToDirectDepositForm: Bool = false
  @Published var toastMessage: String?
  @Published var pinWheelData: PinWheelViewController.PinWheelData?
  
  private lazy var pinWheelService = PinWheelService()
  private lazy var getPinWheelTokenUseCase: NSGetPinWheelTokenUseCaseProtocol = {
    NSGetPinWheelTokenUseCase(repository: externalFundingRepository)
  }()
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
    toastMessage = L10N.Common.DirectDeposit.Copied.message
  }
}

// MARK: - Private Functions
private extension DirectDepositViewModel {
  func generatePinWheelData() async {
    do {
      let pinwheelResponse = try await getPinWheelTokenUseCase.execute(
        sessionID: accountDataManager.sessionID
      )
      pinWheelData = PinWheelViewController.PinWheelData(
        delegate: pinWheelService,
        token: pinwheelResponse.token
      )
    } catch {
      toastMessage = error.userFriendlyMessage
    }
  }
  
  func loadPinWheel() async {
    directDepositLoading = true
    pinWheelService.onDismiss = { [weak self] value in
      self?.pinWheelData = nil
      if let value = value {
        self?.toastMessage = value
      }
    }
    pinWheelService.onSuccess = {
      self.pinWheelData = nil
    }
    await generatePinWheelData()
    directDepositLoading = false
  }
}
