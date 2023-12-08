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
  func checkBiometricsCapability() -> AnyPublisher<BiometricType, BiometricError> {
    let isCapability = context.canEvaluatePolicy(policy, error: &error)
    let biometryType = BiometricType.getType(from: context.biometryType)
    
    if isCapability {
      return Just(biometryType)
        .setFailureType(to: BiometricError.self)
        .eraseToAnyPublisher()
    } else {
      return Fail(error: BiometricError.biometricError(from: error))
        .eraseToAnyPublisher()
    }
  }
  
  func performBiometricsCheck() -> AnyPublisher<BiometricType, BiometricError> {
    checkBiometricsCapability()
      .flatMap { [weak self] type -> AnyPublisher<BiometricType, BiometricError> in
        guard let self = self else {
          return Fail(error: BiometricError.unknown).eraseToAnyPublisher()
        }
        
        if type == .none {
          return Fail(error: BiometricError.biometricError(from: self.error))
            .eraseToAnyPublisher()
        } else {
          return self.performBiometricEvaluation(type: type)
            .eraseToAnyPublisher()
        }
      }
      .eraseToAnyPublisher()
  }
}

// MARK: - Private Helper Functions
private extension BiometricsManager {
  func performBiometricEvaluation(type: BiometricType) -> AnyPublisher<BiometricType, BiometricError> {
    Future { promise in
      self.context.evaluatePolicy(self.policy, localizedReason: self.localizedReason) { success, error in
        DispatchQueue.main.async {
          guard success else {
            let biometricError = BiometricError.biometricError(from: error as? NSError)
            promise(.failure(biometricError))
            return
          }
          
          promise(.success(type))
        }
      }
    }
    .eraseToAnyPublisher()
  }
}
