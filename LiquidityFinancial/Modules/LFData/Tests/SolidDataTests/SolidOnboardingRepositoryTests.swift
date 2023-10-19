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
  func test_getOnboardingStep_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockSuccessResult = APISolidOnboardingStep(processSteps: ["solid_create_account", "solid_account_rejected", "solid_in_review"])
      self.api.getOnboardingStepReturnValue = mockSuccessResult
      // When calling getOnboardingStep function on the repository should return an value successfully
      let resultExpectUseCase = try await self.repository.getOnboardingStep()
      // Then the repository will returns the same result as the api
      expect(resultExpectUseCase.processSteps).to(equal(mockSuccessResult.processSteps))
    }
  }
  
  // Test the getOnboardingStep functionality when it encounters an error.
  func test_getOnboardingStep_failed_case_not_throw() async {
    // Given the expected mock success and fail results
    let mockSuccessResult = APISolidOnboardingStep(processSteps: ["solid_create_account", "solid_account_rejected", "solid_in_review"])
    let mockFailedResult = APISolidOnboardingStep(processSteps: [])
    // And give to repository should return a mockFailedResult
    self.api.getOnboardingStepReturnValue = mockFailedResult
    // When calling getOnboardingStep function on the usecase should return an value not equal mockSuccessResult
    let resultExpectUseCase = try? await self.repository.getOnboardingStep()
    //Then the repository will returns the another result as compared to the repository
      expect(resultExpectUseCase?.processSteps).toNot(equal(mockSuccessResult.processSteps))
  }
  
  // Test the getOnboardingStep functionality when it encounters an error.
  func test_getOnboardingStep_failed_case_throw() async {
    do {
      // And expected description of the error which will be thrown
      self.api.getOnboardingStepThrowableError = "Can't create a person"
      
      // When calling getOnboardingStep function on the repository should throw an error as the same
      _ = try await self.repository.getOnboardingStep()
      
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.api.getOnboardingStepThrowableError?.localizedDescription).to(equal(error.localizedDescription))
    }
  }
  
  // Test the create person functionality under normal conditions.
  func test_create_person_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockParameterSuccessResult = MockAPISolidPersonParameters.mockData
      
      self.api.createPersonParametersClosure = { parameter async throws -> Bool in
        if parameter.solidCreatePersonRequest.phone == "mock_phone" {
          return true
        }
        return false
      }
      // When calling create a person function on the usecase with parameters which should return an value successfully
      let resultExpectRepository = try await self.repository.createPerson(parameters: mockParameterSuccessResult)
      // Then the repository will returns the same result as the api
      expect(resultExpectRepository).to(equal(try await self.api.createPerson(parameters: mockParameterSuccessResult)))
    }
  }
  
  // Test the create person functionality when it encounters an error.
  func test_create_person_failed_case_not_throw() async {
    // Given the expected mock success and fail results
    let mockParameterSuccessResult = MockAPISolidPersonParameters.mockData
    let mockParameterFailedResult = MockAPISolidPersonParameters.mockEmptyData
    self.api.createPersonParametersClosure = { parameter async throws -> Bool in
      if parameter.solidCreatePersonRequest.phone == "mock_phone" {
        return true
      }
      return false
    }
    // And give mock fail to API compare to repository
    let resultExpectAPI = try? await self.api.createPerson(parameters: mockParameterFailedResult)
    // When calling create person function on the repository with parameters which should an false value
    let resultExpectRepository = try? await self.repository.createPerson(parameters: mockParameterSuccessResult)
    //Then the repository will returns the another result as compared to the API
    expect(resultExpectAPI).toNot(equal(resultExpectRepository))
  }
  
  // Test the create person functionality when it encounters an error.
  func test_create_person_failed_case_throw() async {
    do {
      // Given the expected mock success and fail results
      let mockParameterSuccessResult = MockAPISolidPersonParameters.mockData
      // And expected description of the error which will be thrown
      self.api.createPersonParametersThrowableError = "Can't create a person"
      
      // When calling createPerson function on the repository with parameters which should throw an error as the same
      _ = try await self.repository.createPerson(parameters: mockParameterSuccessResult)
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.api.createPersonParametersThrowableError?.localizedDescription).to(equal(error.localizedDescription))
    }
  }
}
