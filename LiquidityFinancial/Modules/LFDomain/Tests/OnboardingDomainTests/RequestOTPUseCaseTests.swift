import XCTest
import Foundation
import DomainTestHelpers
import TestHelpers
import XCTest
import Nimble

@testable import OnboardingDomain

final class RequestOTPUseCaseTests: XCTestCase {
  var repository: MockOnboardingRepositoryProtocol!
  var usecase: RequestOTPUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockOnboardingRepositoryProtocol()
    usecase = RequestOTPUseCase(repository: repository)
  }
  
  func test_happy_case() async {
    // Given: Set up a mock success result with required authentication information.
    let mockSuccessResult = MockOtpEntity()
    mockSuccessResult.requiredAuth = ["mock_requiredAuth", "mock_requiredAuth_1"]
    self.repository.requestOTPParametersReturnValue = mockSuccessResult
    
    // When: Call the 'execute' method on the use case with a specific phoneNumber and retrieve the required authentication information.
    let parameters = MockOTPParametersEntity()
    parameters.phoneNumber = "9999999999"
    await expect {
      try await self.usecase.execute(isNewAuth: false, parameters: parameters).requiredAuth
    }
    // Then: Ensure that the returned required authentication information matches the one set in the mock success result.
    .to(equal(mockSuccessResult.requiredAuth))
  }
  
  func test_failed_case() async {
    // Given: Set up a mock error.
    let mockError = TestError.fail("mock_error")
    self.repository.requestOTPParametersThrowableError = mockError
    
    // When: Call the 'execute' method on the use case with an empty phoneNumber, which triggers an error.
    let parameters = MockOTPParametersEntity()
    parameters.phoneNumber = "9999999999"
    await expect {
      try await self.usecase.execute(isNewAuth: false, parameters: parameters)
    }
    // Then: Ensure that the use case throws the expected error.
    .to(
      throwError(closure: { error in
        expect(error).to(equal(mockError))
      })
    )
  }
  
}
