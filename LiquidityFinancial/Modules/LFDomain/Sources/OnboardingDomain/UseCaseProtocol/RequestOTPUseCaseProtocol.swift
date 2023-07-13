import Foundation

public protocol RequestOTPUseCaseProtocol {
  func execute(phoneNumber: String) async throws -> OtpEntity
}
