import Foundation
  
public class ZerohashGetAccountDetailUseCase: ZerohashGetAccountDetailUseCaseProtocol {
  
  private let repository: ZerohashAccountRepositoryProtocol
  
  public init(repository: ZerohashAccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(id: String) async throws -> ZerohashAccountEntity {
    try await self.repository.getAccountDetail(id: id)
  }
}
