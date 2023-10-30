import Foundation

public class NSGetAgreementUseCase: NSGetAgreementUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> AgreementDataEntity {
    try await repository.getAgreement()
  }
}
