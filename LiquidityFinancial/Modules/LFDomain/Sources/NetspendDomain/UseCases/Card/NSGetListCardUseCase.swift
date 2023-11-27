import Foundation

public class NSGetListCardUseCase: NSGetListCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [NSCardEntity] {
    try await repository.getListCard()
  }
}
