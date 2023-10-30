import Foundation

public protocol NSGetAgreementUseCaseProtocol {
  func execute() async throws -> AgreementDataEntity
}
