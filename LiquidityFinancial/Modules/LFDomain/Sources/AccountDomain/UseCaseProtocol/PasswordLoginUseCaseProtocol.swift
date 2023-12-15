import Foundation
import OnboardingDomain

public protocol PasswordLoginUseCaseProtocol {
  func execute(password: String) async throws -> AccessTokensEntity
}
