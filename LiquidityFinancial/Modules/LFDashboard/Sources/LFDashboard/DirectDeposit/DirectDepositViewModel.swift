import Foundation
import UIKit
import LFLocalizable
import LFUtilities
import LFServices
import Factory
import NetSpendData
import NetSpendDomain

@MainActor
final class DirectDepositViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository

  @Published var directDepositLoading: Bool = false
  @Published var isShowAllBenefits: Bool = false
  @Published var isLoading: Bool = false
  @Published var isNavigateToDirectDepositForm: Bool = false
  @Published var toastMessage: String?
  @Published var pinWheelData: PinWheelViewController.PinWheelData?
  @Published var accountNumber: String = ""
  @Published var routingNumber: String = ""
  
  private lazy var pinWheelService = PinWheelService()
  private lazy var externalFundingUseCase: NSExternalFundingUseCaseProtocol = {
    NSExternalFundingUseCase(repository: externalFundingRepository)
  }()
  
  init() {
    getACHInfo()
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
  func getACHInfo() {
    isLoading = true
    Task {
      do {
        let achResponse = try await externalFundingUseCase.getACHInfo(sessionID: accountDataManager.sessionID)
        accountNumber = achResponse.accountNumber ?? Constants.Default.undefined.rawValue
        routingNumber = achResponse.routingNumber ?? Constants.Default.undefined.rawValue
        isLoading = false
      } catch {
        isLoading = false
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func generatePinWheelData() async {
    do {
      let pinwheelResponse = try await externalFundingUseCase.getPinWheelToken(
        sessionID: accountDataManager.sessionID
      )
      pinWheelData = PinWheelViewController.PinWheelData(
        delegate: pinWheelService,
        token: pinwheelResponse.token
      )
    } catch {
      toastMessage = error.localizedDescription
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
