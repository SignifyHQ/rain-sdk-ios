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
  
  @Published var isFlowPresented: Bool = true
  @Published var toastMessage: String?
  @Published var biometricType: BiometricType = .none
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  private var cancellables: Set<AnyCancellable> = []

  public init() {
    checkBiometricsCapability()
  }
}

// MARK: - View Helper Functions
extension BiometricsBackupViewModel {
  func didTapBiometricsLogin() {
    biometricsManager.performBiometricsAuthentication(purpose: .backup)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        switch completion {
        case .finished:
          log.debug("Biometrics capabxility check completed.")
        case .failure(let error):
          self.handleBiometricAuthenticationError(error: error)
        }
      }, receiveValue: { [weak self] _ in
        guard let self else { return }
        self.isFlowPresented = false
      })
      .store(in: &cancellables)
  }
  
  func didTapPasswordLogin() {
    navigation = .passwordLogin
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Private Functions
private extension BiometricsBackupViewModel {
  func checkBiometricsCapability() {
    biometricsManager.checkBiometricsCapability(purpose: .enable)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          log.debug("Biometrics capability check completed.")
        case .failure(let error):
          log.error("Biometrics capability error: \(error.localizedDescription)")
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        self.biometricType = result.type
      })
      .store(in: &cancellables)
  }
  
  func openDeviceSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func handleBiometricAuthenticationError(error: BiometricError) {
    log.error("Biometrics error: \(error.localizedDescription)")
    switch error {
    case .biometryNotAvailable:
      self.openDeviceSettings()
    case .biometryLockout:
      self.popup = .biometricsLockout
    default:
      break
    }
  }
}

// MARK: - Types
extension BiometricsBackupViewModel {
  enum Navigation {
    case passwordLogin
  }
  
  enum Popup {
    case biometricsLockout
  }
}
