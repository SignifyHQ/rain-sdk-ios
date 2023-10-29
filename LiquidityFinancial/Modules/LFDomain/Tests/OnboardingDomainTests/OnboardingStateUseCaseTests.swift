import XCTest
import Foundation
import DomainTestHelpers
import TestHelpers
import XCTest
import Nimble

@testable import OnboardingDomain

final class OnboardingStateUseCaseTests: XCTestCase {
  var repository: MockOnboardingRepositoryProtocol!
  var usecase: OnboardingStateUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockOnboardingRepositoryProtocol()
    usecase = OnboardingStateUseCase(repository: repository)
  }
  
  func test_happy_case() async {
    // Given: Set up a mock success result with missing steps.
    let mockSuccessResult = MockOnboardingStateEnity()
    mockSuccessResult.missingSteps = ["missingSteps_1", "missingSteps_2"]
    self.repository.onboardingStateSessionIdReturnValue = mockSuccessResult
    
    // When: Call the 'execute' method on the use case with a specific sessionId and retrieve the missing steps.
    await expect {
      try await self.usecase.execute(sessionId: "mockSessionID").missingSteps
    }
    // Then: Ensure that the returned missing steps match the ones set in the mock success result.
    .to(equal(mockSuccessResult.missingSteps))
  }
  
  func test_failed_case() async {
    // Given: Set up a mock error.
    let mockError = TestError.fail("mock_error")
    self.repository.onboardingStateSessionIdThrowableError = mockError
    
    // When: Call the 'execute' method on the use case with an empty sessionId, which triggers an error.
    await expect {
      try await self.usecase.execute(sessionId: "")
    }
    // Then: Ensure that the use case throws the expected error.
    .to(
      throwError(closure: { error in
        expect(error).to(equal(mockError))
      })
    )
  }
  
}
