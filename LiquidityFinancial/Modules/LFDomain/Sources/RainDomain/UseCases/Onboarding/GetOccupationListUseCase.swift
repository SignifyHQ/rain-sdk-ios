import Foundation

public class GetOccupationListUseCase: GetOccupationListUseCaseProtocol {
  
  private let repository: RainRepositoryProtocol
  
  public init(
    repository: RainRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  public func execute() async throws -> [OccupationEntity] {
    try await repository.getOccupationList()
  }
}
