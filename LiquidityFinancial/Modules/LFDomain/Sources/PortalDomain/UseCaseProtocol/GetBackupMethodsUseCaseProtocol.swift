import Foundation

public protocol GetBackupMethodsUseCaseProtocol {
  func execute() async throws -> PortalBackupMethodsEntity
}
