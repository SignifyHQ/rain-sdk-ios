import Foundation

// sourcery: AutoMockable
public protocol RainExternalVerificationLinkEntity {
  var url: String { get }
  var paramsEntity: RainParamsEntity? { get }
}

// sourcery: AutoMockable
public protocol RainParamsEntity {
  var userId: String? { get }
}
