import Foundation
import Combine

// sourcery: AutoMockable
public protocol BiometricsManagerProtocol {
  func checkBiometricsCapability(purpose: BiometricsPurpose) -> AnyPublisher<Biometric, BiometricError>
  func performBiometricsAuthentication(purpose: BiometricsPurpose) -> AnyPublisher<Biometric, BiometricError>
  func performDeviceAuthentication() -> AnyPublisher<Bool, BiometricError>
}
