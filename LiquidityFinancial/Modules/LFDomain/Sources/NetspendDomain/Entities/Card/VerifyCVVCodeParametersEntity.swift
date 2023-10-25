import Foundation

// sourcery: AutoMockable
public protocol VerifyCVVCodeParametersEntity {
  var verificationType: String { get }
  var encryptedData: String { get }
}
