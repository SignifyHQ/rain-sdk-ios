import Foundation

public class NSPostAgreementUseCase: NSPostAgreementUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(body: [String: Any]) async throws -> Bool {
    try await repository.postAgreement(body: body)
  }
}
