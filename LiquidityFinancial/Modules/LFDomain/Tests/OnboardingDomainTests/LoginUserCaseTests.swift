import XCTest
import Foundation
import DomainTestHelpers
import TestHelpers
import XCTest

@testable import OnboardingDomain

final class LoginUserCaseTests: XCTestCase {
  var repository: MockOnboardingRepositoryProtocol!
  var usecase: LoginUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockOnboardingRepositoryProtocol()
    usecase = LoginUseCase(repository: repository)
  }
  
  func test_happy_case() {
    runAsyncTest {
      let mockSuccessResult = MockAccessTokensEntity()
      mockSuccessResult.accessToken = "mock_accessToken"
      mockSuccessResult.refreshToken = "mock_refreshToken"
      
      let mockFailedResult = MockAccessTokensEntity()
      
      self.repository.loginPhoneNumberOtpCodeLastIDClosure = { phoneNumber, otpCode, lastID async throws -> MockAccessTokensEntity in
        if phoneNumber == "123456789" && otpCode == "1234" && lastID == "9999" {
          return mockSuccessResult
        }
        return mockFailedResult
      }
      
      let result = try await self.usecase.execute(phoneNumber: "123456789", otpCode: "1234", lastID: "9999")
      
      XCTAssertEqual(mockSuccessResult.accessToken, result.accessToken)
      XCTAssertEqual(mockSuccessResult.refreshToken, result.refreshToken)
    }
  }
  
  func test_failed_case() async {
    do {
      let mockSuccessResult = MockAccessTokensEntity(accessToken: "mock_accessToken", tokenType: "mock_tokenType", refreshToken: "mock_refreshToken", expiresIn: 9999)

      let mockFailedResult = MockAccessTokensEntity()
      
      self.repository.loginPhoneNumberOtpCodeLastIDClosure = { phoneNumber, otpCode, lastID async throws -> MockAccessTokensEntity in
        if phoneNumber == "mock_accountId" && otpCode == "mock_quoteId" && lastID == "9999" {
          return mockSuccessResult
        }
        self.repository.loginPhoneNumberOtpCodeLastIDThrowableError = "wrong the otp code"
        return mockFailedResult
      }
      
      _ = try await self.usecase.execute(phoneNumber: "", otpCode: "", lastID: "")
      
    } catch {
      XCTAssertEqual(self.repository.loginPhoneNumberOtpCodeLastIDThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
}
