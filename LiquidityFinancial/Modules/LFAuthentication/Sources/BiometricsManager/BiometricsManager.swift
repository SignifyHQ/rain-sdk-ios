import Combine
import Foundation
import LocalAuthentication
import LFLocalizable

class BiometricsManager: BiometricsManagerProtocol {
  private var error: NSError?
  
  private let context: LAContext
  private let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
  private let localizedReason = LFLocalizable.Authentication.BiometricsLocalizedReason.title
  
  init(context: LAContext) {
    self.context = context
  }
}

// MARK: - Functions
extension BiometricsManager {
  func checkBiometricsCapability() -> AnyPublisher<Biometric, BiometricError> {
    let isBiometricEnabled = context.canEvaluatePolicy(policy, error: &error)
    let biometryType = BiometricType.getType(from: context.biometryType)
    let isSupportedBiometric = !(biometryType == .none || biometryType == .unknown)
    
    if isSupportedBiometric {
      let result = Biometric(isEnabled: isBiometricEnabled, type: biometryType)
      return Just(result)
        .setFailureType(to: BiometricError.self)
        .eraseToAnyPublisher()
    } else {
      return Fail(error: BiometricError.biometricError(from: error))
        .eraseToAnyPublisher()
    }
  }
  
  func performBiometricsCheck() -> AnyPublisher<Biometric, BiometricError> {
    checkBiometricsCapability()
      .flatMap { [weak self] biometric -> AnyPublisher<Biometric, BiometricError> in
        guard let self = self else {
          return Fail(error: BiometricError.unknown).eraseToAnyPublisher()
        }
        
        if biometric.type == .none {
          return Fail(error: BiometricError.biometricError(from: self.error))
            .eraseToAnyPublisher()
        } else {
          return self.performBiometricEvaluation(biometric: biometric)
            .eraseToAnyPublisher()
        }
      }
      .eraseToAnyPublisher()
  }
}

// MARK: - Private Helper Functions
private extension BiometricsManager {
  func performBiometricEvaluation(biometric: Biometric) -> AnyPublisher<Biometric, BiometricError> {
    Future { promise in
      self.context.evaluatePolicy(self.policy, localizedReason: self.localizedReason) { success, error in
        DispatchQueue.main.async {
          guard success else {
            let biometricError = BiometricError.biometricError(from: error as? NSError)
            promise(.failure(biometricError))
            return
          }
          
          promise(.success(biometric))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
