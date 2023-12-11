import Combine
import Factory
import Foundation
import BiometricsManager
import LFLocalizable
import LFUtilities

@MainActor
public final class SecurityHubViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.biometricsManager) var biometricsManager

  @Published var toastMessage: String?
  @Published var biometricType: BiometricType = .none
  
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
      }, receiveValue: { [weak self] biometricType in
        self?.biometricType = biometricType
      })
      .store(in: &cancellables)
  }
}

struct SecurityInformation {
  let value: String
  let isVerified: Bool
  
  var status: String {
    isVerified
    ? LFLocalizable.Authentication.SecurityVerified.title
    : LFLocalizable.Authentication.SecurityVerify.title
  }
}
