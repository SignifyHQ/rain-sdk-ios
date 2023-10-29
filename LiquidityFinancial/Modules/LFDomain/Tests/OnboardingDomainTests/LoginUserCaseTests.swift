import XCTest
import Foundation
import DomainTestHelpers
import TestHelpers
import XCTest
import Nimble

@testable import OnboardingDomain

final class LoginUserCaseTests: XCTestCase {
  var repository: MockOnboardingRepositoryProtocol!
  var usecase: LoginUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockOnboardingRepositoryProtocol()
    usecase = LoginUseCase(repository: repository)
  }
  
  func test_happy_case() async {
    // Given: Set up a mock success result with an access token.
    let mockSuccessResult = MockAccessTokensEntity()
    mockSuccessResult.accessToken = "mock_accessToken"
    self.repository.loginPhoneNumberOtpCodeLastIDReturnValue = mockSuccessResult
    // When: Call the 'execute' method on the use case with specific phoneNumber, otpCode, and lastID, and retrieve the access token.
    await expect {
      try await self.usecase.execute(phoneNumber: "123456789", otpCode: "1234", lastID: "9999").accessToken
    }
    // Then: Ensure that the returned access token matches the one set in the mock success result.
    .to(equal(mockSuccessResult.accessToken))
  }
  
  func test_failed_case() async {
    // Given: Set up a mock error.
    let mockError = TestError.fail("mock_error")
    self.repository.loginPhoneNumberOtpCodeLastIDThrowableError = mockError
    // When: Call the 'execute' method on the use case with empty phoneNumber, otpCode, and lastID, which triggers an error.
    await expect {
      try await self.usecase.execute(phoneNumber: "", otpCode: "", lastID: "")
    }
    // Then: Ensure that the use case throws the expected error.
    .to(
      throwError(closure: { error in
        expect(error).to(equal(mockError))
      })
    )
  }
  
}
