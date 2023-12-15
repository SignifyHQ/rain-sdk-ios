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

  @Published var isBiometricEnabled: Bool = false
  @Published var toastMessage: String?
  
  @Published var biometricType: BiometricType = .none
  @Published var navigation: Navigation?
  @Published var popup: Popup?

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
  }
  
  func didTapPhoneVerifyButton() {
  }
  
  func didTapChangePasswordButton() {
    navigation = .changePassword
  }
  
  func resetBiometricToggleState() {
    isBiometricEnabled = accountDataManager.isBiometricUsageEnabled
  }
  
  func declineBiometricAuthentication() {
    popup = nil
    isBiometricEnabled = false
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
    biometricsManager.performBiometricsAuthentication()
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
}

// MARK: - Private Functions
private extension SecurityHubViewModel {
  func checkBiometricsCapability() {
    biometricsManager.checkBiometricsCapability()
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case .finished:
          log.debug("Biometrics capability check completed.")
        case .failure(let error):
          self?.toastMessage = error.errorDescription
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
    case changePassword
  }
  
  enum Popup {
    case biometric
  }
}
