import Foundation

public class NSEstablishPersonSessionUseCase: NSEstablishPersonSessionUseCaseProtocol {
  private let repository: NSPersonsRepositoryProtocol
  
  public init(repository: NSPersonsRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(deviceData: EstablishSessionParametersEntity) async throws -> EstablishedSessionEntity {
    try await repository.establishPersonSession(deviceData: deviceData)
  }
}
