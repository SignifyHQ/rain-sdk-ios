import Combine
import Factory
import Foundation
import BiometricsManager
import LFLocalizable
import LFUtilities
import SwiftUI

@MainActor
public final class SecurityHubViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.biometricsManager) var biometricsManager

  @Published var isMFAEnabled: Bool = false
  @Published var isBiometricEnabled: Bool = false
  @Published var toastMessage: String?
  
  @Published var biometricType: BiometricType = .none
  @Published var navigation: Navigation?
  @Published var popup: Popup?

  @Published
  var isChangePasswordFlowPresented: Bool = false
  
  private var cancellables: Set<AnyCancellable> = []

  var email: SecurityInformation {
    SecurityInformation(
      value: accountDataManager.userInfomationData.email ?? .empty,
      isVerified: accountDataManager.userInfomationData.emailVerified ?? false
    )
  }
  
  var phone: SecurityInformation {
    SecurityInformation(
      value: accountDataManager.userInfomationData.phone ?? .empty,
      isVerified: accountDataManager.userInfomationData.phoneVerified ?? false
    )
  }
  
  var isBiometricsCapability: Bool {
    !(biometricType == .none || biometricType == .unknown)
  }
  
  public init() {
    checkBiometricsCapability()
  }
}

// MARK: - APIs
extension SecurityHubViewModel {
}

// MARK: - View Helper Functions
extension SecurityHubViewModel {
  func didTapEmailVerifyButton() {
    navigation = .verifyEmail
  }
  
  func didTapPhoneVerifyButton() {
  }
  
  func didTapChangePasswordButton() {
  }
  
  func resetBiometricToggleState() {
    isBiometricEnabled = accountDataManager.isBiometricUsageEnabled
  }
  
  func declineBiometricAuthentication() {
    popup = nil
    isBiometricEnabled = false
  }
  
  func didMFAToggleStateChange() {
    if isMFAEnabled {
      navigation = .turnOnMFA
    }
  }
  
  func didBiometricToggleStateChanged() {
    if isBiometricEnabled {
      withAnimation {
        popup = .biometric
      }
    } else {
      accountDataManager.isBiometricUsageEnabled = false
    }
  }
  
  func allowBiometricAuthentication() {
    popup = nil
    biometricsManager.performBiometricsAuthentication(purpose: .enable)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        switch completion {
        case .finished:
          log.debug("Biometrics capabxility check completed.")
        case .failure(let error):
          self.handleBiometricAuthenticationError(error: error)
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        self.biometricType = result.type
        self.accountDataManager.isBiometricUsageEnabled = result.isEnabled
      })
      .store(in: &cancellables)
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Private Functions
private extension SecurityHubViewModel {
  func checkBiometricsCapability() {
    biometricsManager.checkBiometricsCapability(purpose: .enable)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          log.debug("Biometrics capability check completed.")
        case .failure(let error):
          log.error("Biometrics error: \(error.localizedDescription)")
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        self.biometricType = result.type
        self.isBiometricEnabled = self.accountDataManager.isBiometricUsageEnabled
      })
      .store(in: &cancellables)
  }
  
  func openDeviceSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func handleBiometricAuthenticationError(error: BiometricError) {
    accountDataManager.isBiometricUsageEnabled = false
    isBiometricEnabled = false
    switch error {
    case .biometryNotAvailable:
      openDeviceSettings()
    case .biometryLockout:
      popup = .biometricsLockout
    case .userCancel:
      break
    default:
      toastMessage = error.localizedDescription
    }
  }
}

// MARK: - Types
extension SecurityHubViewModel {
  struct SecurityInformation {
    let value: String
    let isVerified: Bool
    
    var status: String {
      isVerified
      ? LFLocalizable.Authentication.SecurityVerified.title
      : LFLocalizable.Authentication.SecurityVerify.title
    }
  }
  
  enum Navigation {
    case turnOnMFA
    case verifyEmail
  }
  
  enum Popup {
    case biometric
    case biometricsLockout
  }
}
