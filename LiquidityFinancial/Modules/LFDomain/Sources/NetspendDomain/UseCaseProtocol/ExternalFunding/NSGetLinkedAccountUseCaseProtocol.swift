import Foundation
  
public protocol NSGetLinkedAccountUseCaseProtocol {
  func execute(sessionId: String) async throws -> any LinkedSourcesEntity
}
