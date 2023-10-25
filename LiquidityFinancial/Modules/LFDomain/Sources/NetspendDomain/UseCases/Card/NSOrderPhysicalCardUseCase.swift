import Foundation

public class NSOrderPhysicalCardUseCase: NSOrderPhysicalCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(address: AddressCardParametersEntity, sessionID: String) async throws -> CardEntity {
    try await repository.orderPhysicalCard(address: address, sessionID: sessionID)
  }
}
