import Foundation
import Combine

// sourcery: AutoMockable
public protocol BiometricsManagerProtocol {
  func checkBiometricsCapability() -> AnyPublisher<Biometric, BiometricError>
  func performBiometricsAuthentication() -> AnyPublisher<Biometric, BiometricError>
  func performDeviceAuthentication() -> AnyPublisher<Bool, BiometricError>
}
