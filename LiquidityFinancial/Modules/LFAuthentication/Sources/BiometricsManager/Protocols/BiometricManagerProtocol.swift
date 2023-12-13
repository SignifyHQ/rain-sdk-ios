import Foundation
import Combine

// sourcery: AutoMockable
public protocol BiometricsManagerProtocol {
  func checkBiometricsCapability() -> AnyPublisher<Biometric, BiometricError>
  func performBiometricsCheck() -> AnyPublisher<Biometric, BiometricError>
}
