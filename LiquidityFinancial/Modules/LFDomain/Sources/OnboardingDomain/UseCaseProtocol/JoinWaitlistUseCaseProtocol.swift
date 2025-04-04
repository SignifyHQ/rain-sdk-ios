import Foundation

public protocol JoinWaitlistUseCaseProtocol {
  func execute(parameters: JoinWaitlistParametersEntity) async throws
}
