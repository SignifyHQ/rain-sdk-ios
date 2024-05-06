import Foundation
import LFLocalizable
import Factory
import Combine
import SwiftUI
import LFUtilities
import SwiftUI
import LFStyleGuide
import PortalSwift
import PortalData
import PortalDomain

@MainActor
public final class EnterPinCodeViewModel: ObservableObject {
  @LazyInjected(\.rainOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.portalRepository) var portalRepository
  
  @Published var isLoading: Bool = false
  @Published var isButtonDisable: Bool = false
  @Published var pinCode: String = .empty
  @Published var inlineMessage: String?
  
  @Published var popup: Popup?
  
  lazy var recoverWalletUseCase: RecoverWalletUseCaseProtocol = {
    RecoverWalletUseCase(repository: portalRepository)
  }()
  
  let pinCodeLength = Constants.MaxCharacterLimit.backupPinCode.value
  
  private var subscribers: Set<AnyCancellable> = []
  
  public init() {
    observePinCode()
  }
}

// MARK: - View Handle
extension EnterPinCodeViewModel {
  func recoverWalletByPassword() {
    Task {
      isLoading = true
      defer { isLoading = false }
      
      do {
        try await recoverWalletUseCase.execute(backupMethod: .Password, password: pinCode)
        
        popup = .recoverySuccessfully
      } catch {
        inlineMessage = error.userFriendlyMessage
      }
    }
  }
  
  func recoverySuccessfullyPrimaryButtonTapped() {
    popup = nil
    onboardingFlowCoordinator.set(route: .dashboard)
  }
}

// MARK: - Private Functions
extension EnterPinCodeViewModel {
  func observePinCode() {
    $pinCode
      .receive(on: DispatchQueue.main)
      .sink { [weak self] pinCode in
        guard let self else { return }
        self.isButtonDisable = pinCode.count != self.pinCodeLength
        self.inlineMessage = nil
      }
      .store(in: &subscribers)
  }
}

// MARK: - Types
extension EnterPinCodeViewModel {
  enum Popup {
    case recoverySuccessfully
  }
}
