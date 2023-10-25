import Foundation

public class NSGetListCardUseCase: NSGetListCardUseCaseProtocol {
  private let repository: NSCardRepositoryProtocol
  
  public init(repository: NSCardRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> [CardEntity] {
    try await repository.getListCard()
  }
}
