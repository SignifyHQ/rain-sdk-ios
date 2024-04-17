import Foundation

public class GetExternalVerificationLinkUseCase: GetExternalVerificationLinkUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(repository: RainRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> RainExternalVerificationLinkEntity {
    try await repository.getExternalVerificationLink()
  }
}
