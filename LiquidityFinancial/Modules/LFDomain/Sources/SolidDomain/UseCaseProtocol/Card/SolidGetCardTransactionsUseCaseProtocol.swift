import Foundation
import AccountDomain

public protocol SolidGetCardTransactionsUseCaseProtocol {
  func execute(parameters: SolidCardTransactionParametersEntity) async throws -> TransactionListEntity
}
