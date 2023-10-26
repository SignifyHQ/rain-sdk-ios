import Foundation

public class SolidUnlinkContactUseCase: SolidUnlinkContactUseCaseProtocol {

  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(id: String) async throws -> SolidUnlinkContactResponseEntity {
    try await repository.unlinkContact(id: id)
  }
  
}
