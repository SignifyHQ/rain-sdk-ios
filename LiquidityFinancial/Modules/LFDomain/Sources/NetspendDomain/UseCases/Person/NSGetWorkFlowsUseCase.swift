import Foundation

public class NSGetWorkFlowsUseCase: NSGetWorkFlowsUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute() async throws -> WorkflowsDataEntity {
    try await repository.getWorkflows()
  }
}
