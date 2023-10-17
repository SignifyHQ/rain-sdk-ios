import Foundation
import AccountDomain

public class SendCryptoUseCase: SendCryptoUseCaseProtocol {

  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, destinationAddress: String, amount: Double) async throws -> TransactionEntity {
    return try await repository.sendCrypto(accountId: accountId, destinationAddress: destinationAddress, amount: amount)
  }
  
}
