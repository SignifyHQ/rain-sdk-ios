import Foundation

public protocol GetTransactionsListUseCaseProtocol {
  func execute(parameters: TransactionsParametersEntity) async throws -> TransactionListEntity
}
