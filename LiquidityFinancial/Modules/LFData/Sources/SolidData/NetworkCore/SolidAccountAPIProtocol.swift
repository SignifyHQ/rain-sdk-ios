import Foundation

// sourcery: AutoMockable
public protocol SolidAccountAPIProtocol {
  func getAccounts() async throws -> [APISolidAccount]
}
