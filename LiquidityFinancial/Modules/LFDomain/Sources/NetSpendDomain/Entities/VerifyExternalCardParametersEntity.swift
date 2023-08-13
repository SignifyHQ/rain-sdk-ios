import Foundation

public protocol VerifyExternalCardParametersEntity {
  var transferAmount: Double { get }
  var cardId: String { get }
}
