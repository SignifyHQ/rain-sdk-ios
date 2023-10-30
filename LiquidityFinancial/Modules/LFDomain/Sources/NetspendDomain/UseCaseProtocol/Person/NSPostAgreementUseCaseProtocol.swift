import Foundation

public protocol NSPostAgreementUseCaseProtocol {
  func execute(body: [String: Any]) async throws -> Bool
}
