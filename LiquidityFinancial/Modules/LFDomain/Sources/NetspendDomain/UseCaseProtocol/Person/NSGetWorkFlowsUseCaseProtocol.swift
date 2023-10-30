import Foundation

public protocol NSGetWorkFlowsUseCaseProtocol {
  func execute() async throws -> WorkflowsDataEntity
}
