import Foundation

public protocol GetWithdrawalSignatureUseCaseProtocol {
  func execute(parameters: RainWithdrawalSignatureParametersEntity) async throws -> RainWithdrawalSignatureEntity
}
