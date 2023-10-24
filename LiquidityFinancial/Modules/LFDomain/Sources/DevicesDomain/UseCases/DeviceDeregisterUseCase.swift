import Foundation

public class DeviceDeregisterUseCase: DeviceDeregisterUseCaseProtocol {
  
  private let repository: DevicesRepositoryProtocol
  
  public init(repository: DevicesRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(deviceId: String, token: String) async throws -> NotificationTokenEntity {
    return try await repository.deregister(deviceId: deviceId, token: token)
  }
  
}
