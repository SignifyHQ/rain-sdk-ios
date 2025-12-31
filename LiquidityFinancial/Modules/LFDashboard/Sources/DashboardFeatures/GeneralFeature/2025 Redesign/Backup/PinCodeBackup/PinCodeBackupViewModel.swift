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
import Services

@MainActor
public final class PinCodeBackupViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository
  
  @Published var isLoading: Bool = false
  @Published var isButtonDisable: Bool = false
  @Published var pinCode: String = .empty
  @Published var errorInlineMessage: String?
  @Published var successInlineMessage: String?
  
  lazy var backupWalletUseCase: BackupWalletUseCaseProtocol = {
    BackupWalletUseCase(repository: portalRepository)
  }()
  
  let pinCodeLength = Constants.MaxCharacterLimit.backupPinCode.value
  let purpose: Purpose
  
  private var subscribers: Set<AnyCancellable> = []
  
  public init(purpose: Purpose) {
    self.purpose = purpose
    observePinCode()
  }
}

// MARK: - Observable
extension PinCodeBackupViewModel {
  func observePinCode() {
    $pinCode
      .receive(on: DispatchQueue.main)
      .sink { [weak self] pinCode in
        guard let self
        else {
          return
        }
        
        switch purpose {
        case .confirm(let pin):
          // Activate the Continue button only if the pin codes match to follow the logic from the onboarding
          self.isButtonDisable = pinCode != pin
          // Show the error immediately if pin codes don't match
          self.errorInlineMessage = (pinCode.count == self.pinCodeLength && pinCode != pin) ? L10N.Common.WalletBackup.UpdatePin.InputConfirmPin.errorMessage : nil
        case .enterNewPin:
          // Only check the pin length when entering new pin
          self.isButtonDisable = pinCode.count != self.pinCodeLength
          // Error message never shows up in this case
          self.errorInlineMessage = nil
        }
      }
      .store(
        in: &subscribers
      )
  }
}

// MARK: - Handle Interactions
extension PinCodeBackupViewModel {
  func onContinueButtonTap(
    onContinue: ((String) -> Void)?
  ) {
    switch purpose {
    case .enterNewPin:
      onContinue?(pinCode)
    case .confirm:
      backupWalletByPassword()
    }
  }
}

// MARK: - APIs
extension PinCodeBackupViewModel {
  func backupWalletByPassword() {
    Task {
      isLoading = true
      defer { isLoading = false }
      
      do {
        try await backupWalletUseCase.execute(backupMethod: .Password, password: pinCode)
        
        NotificationCenter.default.post(name: .didBackupByPasswordSuccess, object: nil)
        successInlineMessage = L10N.Common.WalletBackup.UpdatePin.InputConfirmPin.successMessage
        log.debug(Constants.DebugLog.cipherTextSavedSuccessfully.value)
      } catch {
        guard let portalError = error as? LFPortalError else {
          errorInlineMessage = error.userFriendlyMessage
          log.error(error.userFriendlyMessage)
          return
        }
        
        switch portalError {
        case .customError(let message):
          errorInlineMessage = message
        default:
          errorInlineMessage = error.localizedDescription
        }
        
        log.error(errorInlineMessage ?? error.localizedDescription)
      }
    }
  }
}

// MARK: - Types
extension PinCodeBackupViewModel {
  public enum Purpose: Equatable {
    case enterNewPin
    case confirm(String)
    
    var description: String {
      switch self {
      case .confirm:
        return L10N.Common.WalletBackup.UpdatePin.InputConfirmPin.title
      case .enterNewPin:
        return L10N.Common.WalletBackup.UpdatePin.InputNewPin.title
      }
    }
  }
}
