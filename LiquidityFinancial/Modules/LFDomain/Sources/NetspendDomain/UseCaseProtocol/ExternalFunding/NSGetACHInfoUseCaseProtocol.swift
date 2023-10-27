import Foundation
  
public protocol NSGetACHInfoUseCaseProtocol {
  func execute(sessionID: String) async throws -> ACHInfoEntity
}
