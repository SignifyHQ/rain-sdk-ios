import Foundation

public class BuyCryptoUseCase: BuyCryptoUseCaseProtocol {

  private let repository: ZerohashRepositoryProtocol
  
  public init(repository: ZerohashRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, quoteId: String) async throws -> BuyCryptoEntity {
    return try await repository.buyCrypto(accountId: accountId, quoteId: quoteId)
  }
  
}
