import Foundation

public protocol NSEstablishPersonSessionUseCaseProtocol {
  func execute(deviceData: EstablishSessionParametersEntity) async throws -> EstablishedSessionEntity
}
