import Foundation

public class GetWithdrawalSignatureUseCase: GetWithdrawalSignatureUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(repository: RainRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(parameters: RainWithdrawalSignatureParametersEntity) async throws -> RainWithdrawalSignatureEntity {
    try await repository.getWithdrawalSignature(parameters: parameters)
  }
}
