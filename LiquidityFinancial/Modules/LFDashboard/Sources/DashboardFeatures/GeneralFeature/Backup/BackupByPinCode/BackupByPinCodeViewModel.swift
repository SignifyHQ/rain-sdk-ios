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
public final class BackupByPinCodeViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository

  @Published var isLoading: Bool = false
  @Published var isButtonDisable: Bool = false
  @Published var pinCode: String = .empty
  @Published var inlineMessage: String?

  @Published var popup: Popup?
  @Published var navigation: Navigation?
  
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

// MARK: - View Handle
extension BackupByPinCodeViewModel {
  func primaryButtonTapped() {
    switch purpose {
    case .setup:
      navigation = .confirmBackupPin
    case let .confirm(pinCode):
      guard self.pinCode == pinCode else {
        self.inlineMessage = L10N.Common.BackupByPinCode.WrongCode.error
        return
      }
      
      backupWalletByPassword()
    }
  }
  
  func primaryPinCreatedButtonTapped() {
    popup = .pinSecure
  }
  
  func pinSecureButtonTapped() {
    popup = nil
    NotificationCenter.default.post(name: .didBackupByPasswordSuccess, object: nil)
  }
}

// MARK: - Private Functions
extension BackupByPinCodeViewModel {
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
  
  func backupWalletByPassword() {
    Task {
      isLoading = true
      defer { isLoading = false }
      
      do {
        try await backupWalletUseCase.execute(backupMethod: .Password, password: pinCode)
        
        popup = .pinCreated
        log.debug(Constants.DebugLog.cipherTextSavedSuccessfully.value)
      } catch {
        inlineMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - Types
extension BackupByPinCodeViewModel {
  enum Navigation {
    case confirmBackupPin
  }
  
  public enum Purpose {
    case setup
    case confirm(String)
    
    var title: String {
      switch self {
      case .setup:
        return L10N.Common.BackupByPinCode.Setup.title
      case .confirm:
        return L10N.Common.BackupByPinCode.Confirm.title
      }
    }
    
    var description: String {
      switch self {
      case .setup:
        return L10N.Common.BackupByPinCode.Setup.description
      case .confirm:
        return L10N.Common.BackupByPinCode.Confirm.description
      }
    }
    
    var buttonTitle: String {
      switch self {
      case .setup:
        return L10N.Common.BackupByPinCode.Setup.buttonTitle
      case .confirm:
        return L10N.Common.BackupByPinCode.Confirm.buttonTitle
      }
    }
  }
  
  enum Popup {
    case pinCreated
    case pinSecure
  }
}
