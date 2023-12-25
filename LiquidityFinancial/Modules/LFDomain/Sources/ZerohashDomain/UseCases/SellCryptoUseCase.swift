import Foundation

public class SellCryptoUseCase: SellCryptoUseCaseProtocol {

  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, quoteId: String) async throws -> SellCryptoEntity {
    return try await repository.sellCrypto(accountId: accountId, quoteId: quoteId)
  }
  
}
