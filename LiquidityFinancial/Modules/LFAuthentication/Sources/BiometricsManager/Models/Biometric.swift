import Foundation

public struct Biometric {
  public let isEnabled: Bool
  public let type: BiometricType
  
  public init(isEnabled: Bool, type: BiometricType) {
    self.isEnabled = isEnabled
    self.type = type
  }
}
