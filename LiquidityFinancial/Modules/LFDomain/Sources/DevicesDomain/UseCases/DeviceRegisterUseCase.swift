import Foundation

public class DeviceRegisterUseCase: DeviceRegisterUseCaseProtocol {
  
  private let repository: DevicesRepositoryProtocol
  
  public init(repository: DevicesRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(deviceId: String, token: String) async throws -> NotificationTokenEntity {
    return try await repository.register(deviceId: deviceId, token: token)
  }
  
}
