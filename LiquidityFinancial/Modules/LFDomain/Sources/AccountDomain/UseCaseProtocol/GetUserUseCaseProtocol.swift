import Foundation

public protocol GetUserUseCaseProtocol {
  func execute() async throws -> LFUser
}
