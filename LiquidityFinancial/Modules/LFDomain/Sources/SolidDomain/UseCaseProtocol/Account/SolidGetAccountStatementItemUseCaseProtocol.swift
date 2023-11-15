import Foundation

public protocol SolidGetAccountStatementItemUseCaseProtocol {
  func execute(liquidityAccountId: String, fileName: String, year: String, month: String) async throws -> SolidAccountStatementItemEntity
}
