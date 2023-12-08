import Foundation
import Combine

// sourcery: AutoMockable
public protocol BiometricsManagerProtocol {
  func checkBiometricsCapability() -> AnyPublisher<BiometricType, BiometricError>
  func performBiometricsCheck() -> AnyPublisher<BiometricType, BiometricError>
}
