import Foundation

public protocol SolidGetAccountStatementListUseCaseProtocol {
  func execute(liquidityAccountId: String) async throws -> [SolidAccountStatementListEntity]
}
