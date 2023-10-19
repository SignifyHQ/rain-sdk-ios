import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class SolidOnboardingUseCaseTests: XCTestCase {
  
  var repository: MockSolidOnboardingRepositoryProtocol!
  var usecase: SolidOnboardingUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockSolidOnboardingRepositoryProtocol()
    usecase = SolidOnboardingUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
  
  // Test the getOnboardingStep functionality under normal conditions.
  func test_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockSuccessResult = MockSolidOnboardingStepEntity()
      mockSuccessResult.processSteps = ["solid_create_account", "solid_account_rejected", "solid_in_review"]
      self.repository.getOnboardingStepReturnValue = mockSuccessResult
      // When calling getOnboardingStep function on the usecase should return an value successfully
      let resultExpectUseCase = try await self.usecase.execute()
      // Then the usecase will returns the same result as the repository
      expect(resultExpectUseCase.processSteps).to(equal(mockSuccessResult.processSteps))
    }
  }
  
  // Test the getOnboardingStep functionality when it encounters an error.
  func test_failed_case_not_throw() async {
    // Given the expected mock success and fail results
    let mockSuccessResult = MockSolidOnboardingStepEntity()
    mockSuccessResult.processSteps = ["solid_create_account", "solid_account_rejected", "solid_in_review"]
    let mockFailedResult = MockSolidOnboardingStepEntity()
    mockFailedResult.processSteps = []
    // And give to repository should return a mockFailedResult
    self.repository.getOnboardingStepReturnValue = mockFailedResult
    // When calling getOnboardingStep function on the usecase should return an value not equal mockSuccessResult
    let resultExpectUseCase = try? await self.usecase.execute()
    //Then the use case will returns the another result as compared to the repository
      expect(resultExpectUseCase?.processSteps).toNot(equal(mockSuccessResult.processSteps))
  }
  
  // Test the getOnboardingStep functionality when it encounters an error.
  func test_failed_case_throw() async {
    do {
      // Given the expected mock success and fail results
      let mockSuccessResult = MockSolidOnboardingStepEntity()
      mockSuccessResult.processSteps = ["solid_create_account", "solid_account_rejected", "solid_in_review"]
      let mockFailedResult = MockSolidOnboardingStepEntity()
      mockFailedResult.processSteps = []
      // And expected description of the error which will be thrown
      self.repository.getOnboardingStepThrowableError = "Can't create a person"
      
      // When calling getOnboardingStep function on the usecase should throw an error as the same
      _ = try await self.usecase.execute()
      
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.repository.getOnboardingStepThrowableError?.localizedDescription).to(equal(error.localizedDescription))
    }
  }
}
