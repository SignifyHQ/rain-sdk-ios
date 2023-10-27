import Foundation
  
public class NSSetExternalFundingUseCase: NSSetExternalFundingUseCaseProtocol {
  private let repository: NSExternalFundingRepositoryProtocol
  
  public init(repository: NSExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(request: ExternalCardParametersEntity, sessionID: String) async throws -> ExternalCardEntity {
    try await repository.set(request: request, sessionID: sessionID)
  }
}
