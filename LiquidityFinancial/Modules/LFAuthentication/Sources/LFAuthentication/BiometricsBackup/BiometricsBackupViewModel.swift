import BiometricsManager
import Combine
import Factory
import LFLocalizable
import LFUtilities
import Foundation
import SwiftUI

public final class BiometricsBackupViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.biometricsManager) var biometricsManager
  
  @Published var isBiometricEnabled: Bool = false
  @Published var toastMessage: String?
  @Published var biometricType: BiometricType = .none
  @Published var navigation: Navigation?
  
  private var cancellables: Set<AnyCancellable> = []

  public init() {
    checkBiometricsCapability()
  }
}

// MARK: - View Helper Functions
extension BiometricsBackupViewModel {
  func didTapBiometricsLogin() {
    
  }
  
  func didTapPasswordLogin() {
    navigation = .passwordLogin
  }
}

// MARK: - Private Functions
private extension BiometricsBackupViewModel {
  func checkBiometricsCapability() {
    biometricsManager.checkBiometricsCapability()
      .sink(receiveCompletion: { [weak self] completion in
        switch completion {
        case .finished:
          log.debug("Biometrics capability check completed.")
        case .failure(let error):
          log.error("Biometrics capability error: \(error.localizedDescription)")
          self?.toastMessage = error.localizedDescription
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
}

// MARK: - Types
extension BiometricsBackupViewModel {
  enum Navigation {
    case passwordLogin
  }
}
