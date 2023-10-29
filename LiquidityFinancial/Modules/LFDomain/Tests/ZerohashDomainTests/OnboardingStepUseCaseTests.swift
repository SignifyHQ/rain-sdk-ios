import XCTest
import Foundation
import AccountDomain
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import ZerohashDomain

final class OnboardingStepUseCaseTests: XCTestCase {
  
  var repository: MockZerohashRepositoryProtocol!
  var usecase: OnboardingStepUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockZerohashRepositoryProtocol()
    usecase = OnboardingStepUseCase(repository: repository)
  }
  
  func testHappyCase() async {
    // Given: Set up a mock success result with missing steps.
    let mockSuccessResult = MockZHOnboardingStepEntity(missingSteps: ["mock_missingSteps_1", "mock_missingSteps_2"])
    self.repository.getOnboardingStepReturnValue = mockSuccessResult
    
    // When: Call the 'execute' method on the use case and retrieve the missing steps.
    await expect {
      try await self.usecase.execute().missingSteps
    }
    // Then: Ensure that the returned missing steps match the ones set in the mock success result.
    .to(equal(mockSuccessResult.missingSteps))
  }
  
  func testFailedCase() async {
    // Given: Set up a mock error.
    let mockError = TestError.fail("mock_error")
    self.repository.getOnboardingStepThrowableError = mockError
    
    // When: Call the 'execute' method on the use case, which triggers an error.
    await expect {
      try await self.usecase.execute()
    }
    // Then: Ensure that the use case throws the expected error.
    .to(
      throwError(closure: { error in
        expect(error).to(equal(mockError))
      })
    )
  }
  
}
