import DataTestHelpers
import Foundation
import NetworkTestHelpers
import Nimble
import TestHelpers
import XCTest

@testable import SolidData

// Test cases for the OnboardingData module.
final class OnboardingDataTests: XCTestCase {
  
  var api: MockSolidOnboardingAPIProtocol!
  var repository: SolidOnboardingRepository!
  
  override func setUp() {
    super.setUp()
    api = MockSolidOnboardingAPIProtocol()
    repository = SolidOnboardingRepository(onboardingAPI: api)
  }
  
  override func tearDown() {
    api = nil
    repository = nil
    
    super.tearDown()
  }
  
  // Test the getOnboardingStep functionality under normal conditions.
  func test_getOnboardingStep_happy_case() async {
    // Given the expected mock success and fail results
    let mockSuccessResult = APISolidOnboardingStep(processSteps: ["solid_create_account", "solid_account_rejected", "solid_in_review"])
    self.api.getOnboardingStepReturnValue = mockSuccessResult
    // When calling the getOnboardingStep function on the repository, it should return a value successfully.
    await expect {
      try await self.repository.getOnboardingStep().processSteps
    }
    // Then the repository will return the same result as the API
    .to(equal(mockSuccessResult.processSteps))
  }
    
  // Test the getOnboardingStep functionality when it encounters an error and throws.
  func test_getOnboardingStep_failed_case_throw() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.getOnboardingStepThrowableError = expectedError
    // When calling the getOnboardingStep function on the repository, it should throw an error as expected
    await expect {
      try await self.repository.getOnboardingStep()
    }
    // Then the description of the caught error is the one we expected
    .to(throwError(closure: { error in
      expect(expectedError).to(equal(error))
    }))
  }
  
  // Test the create person functionality under normal conditions.
  func test_create_person_happy_case() async {
    // Given the expected mock success and fail results
    let mockParameterSuccessResult = MockAPISolidPersonParameters.mockData
    self.api.createPersonParametersReturnValue = true
    // When calling the createPerson function on the use case with parameters, it should return a value successfully
    await expect {
      try await self.repository.createPerson(parameters: mockParameterSuccessResult)
    }
    // Then the repository will return the same result as the API
    .to(beTrue())
  }
  
  // Test the create person functionality when it encounters an error and throws.
  func test_create_person_failed_case_throw() async {
    // Given a mock error which will be thrown
    // Given the expected mock success and fail results
    let mockParameterSuccessResult = MockAPISolidPersonParameters.mockData
    let expectedError = TestError.fail("mock_error")
    self.api.createPersonParametersThrowableError = expectedError
    // When calling the createPerson function on the repository with parameters, it should throw an error as expected
    await expect {
      try await self.repository.createPerson(parameters: mockParameterSuccessResult)
    }
    // Then the description of the caught error is the one we expected
    .to(throwError(closure: { error in
      expect(expectedError).to(equal(error))
    }))
  }
  
}
