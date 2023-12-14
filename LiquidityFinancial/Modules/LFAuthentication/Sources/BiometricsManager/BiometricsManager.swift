import Combine
import Foundation
import LocalAuthentication
import LFLocalizable

class BiometricsManager: BiometricsManagerProtocol {
  private var error: NSError?
  
  private let context: LAContext
  
  init(context: LAContext) {
    self.context = context
  }
}

// MARK: - Functions
extension BiometricsManager {
  func checkBiometricsCapability() -> AnyPublisher<Biometric, BiometricError> {
    let isBiometricEnabled = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    let biometryType = BiometricType.getType(from: context.biometryType)
    let isSupportedBiometric = !(biometryType == .none || biometryType == .unknown)
    
    guard isSupportedBiometric else {
      return Fail(error: BiometricError.biometricError(from: error))
        .eraseToAnyPublisher()
    }
    
    let result = Biometric(isEnabled: isBiometricEnabled, type: biometryType)
    return Just(result)
      .setFailureType(to: BiometricError.self)
      .eraseToAnyPublisher()
  }
  
  func performBiometricsAuthentication() -> AnyPublisher<Biometric, BiometricError> {
    checkBiometricsCapability()
      .flatMap { [weak self] biometric -> AnyPublisher<Biometric, BiometricError> in
        guard let self else {
          return Fail(error: BiometricError.unknown).eraseToAnyPublisher()
        }
        
        guard biometric.type != .none else {
          return Fail(error: BiometricError.biometricError(from: self.error))
            .eraseToAnyPublisher()
        }
        
        return self.performBiometricEvaluation(biometric: biometric)
          .eraseToAnyPublisher()
      }
      .eraseToAnyPublisher()
  }
  
  func performDeviceAuthentication() -> AnyPublisher<Bool, BiometricError> {
    Future { [weak self] promise in
      guard let self else {
        promise(.failure(.unknown))
        return
      }
      
      let policy: LAPolicy = .deviceOwnerAuthentication
      let localizedReason = LFLocalizable.Authentication.DeviceLocalizedReason.title
      let canEvaluatePolicy = self.context.canEvaluatePolicy(policy, error: &self.error)

      guard canEvaluatePolicy else {
        promise(.failure(.authenticationFailed))
        return
      }
      
      self.context.evaluatePolicy(policy, localizedReason: localizedReason) { success, error in
        DispatchQueue.main.async {
          guard success else {
            let biometricError = BiometricError.biometricError(from: error as? NSError)
            promise(.failure(biometricError))
            return
          }
          promise(.success(true))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}

// MARK: - Private Helper Functions
private extension BiometricsManager {
  func performBiometricEvaluation(biometric: Biometric) -> AnyPublisher<Biometric, BiometricError> {
    Future { promise in
      let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
      let localizedReason = LFLocalizable.Authentication.BiometricsLocalizedReason.title
      
      self.context.evaluatePolicy(policy, localizedReason: localizedReason) { success, error in
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
