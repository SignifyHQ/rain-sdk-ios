import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class SolidCreatePersonUseCaseTests: XCTestCase {
  
  var repository: MockSolidOnboardingRepositoryProtocol!
  var usecase: SolidCreatePersonUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockSolidOnboardingRepositoryProtocol()
    usecase = SolidCreatePersonUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
  
  // Test the create person functionality under normal conditions.
  func test_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockParameterSuccessResult = MockAPISolidPersonParameters.mockData
      
      self.repository.createPersonParametersClosure = { parameter async throws -> Bool in
        if let parameter = parameter as? MockAPISolidPersonParameters, parameter.phone == "mock_phone" {
          return true
        }
        return false
      }
      
      let resultExpectRepository = try await self.repository.createPerson(parameters: mockParameterSuccessResult)
      // When calling create a person function on the usecase with parameters which should return an value successfully
      let resultExpectUseCase = try await self.usecase.execute(parameters: mockParameterSuccessResult)
      // Then the usecase will returns the same result as the repository
      expect(resultExpectRepository).to(equal(resultExpectUseCase))
    }
  }
  
  // Test the create person functionality when it encounters an error.
  func test_failed_case_not_throw() async {
    // Given the expected mock success and fail results
    let mockParameterSuccessResult = MockAPISolidPersonParameters.mockData
    let mockParameterFailedResult = MockAPISolidPersonParameters.mockEmptyData
    self.repository.createPersonParametersClosure = { parameter async throws -> Bool in
      if let parameter = parameter as? MockAPISolidPersonParameters, parameter.phone == "mock_phone" {
        return true
      }
      return false
    }
    // And give mock fail to repository compare to usecase
    let resultExpectRepository = try? await self.repository.createPerson(parameters: mockParameterFailedResult)
    // When calling create person function on the usecase with parameters which should an false value
    let resultExpectUseCase = try? await self.usecase.execute(parameters: mockParameterSuccessResult)
    //Then the use case will returns the another result as compared to the repository
    expect(resultExpectRepository).toNot(equal(resultExpectUseCase))
  }
  
  // Test the create person functionality when it encounters an error.
  func test_failed_case_throw() async {
    do {
      // Given the expected mock success and fail results
      let mockParameterSuccessResult = MockAPISolidPersonParameters.mockData
      let mockParameterFailedResult = MockAPISolidPersonParameters.mockEmptyData
      // And expected description of the error which will be thrown
      self.repository.createPersonParametersThrowableError = "Can't create a person"
      
      // When calling createPerson function on the repository and usecase with parameters which should throw an error as the same
      _ = try await self.repository.createPerson(parameters: mockParameterFailedResult)
      _ = try await self.usecase.execute(parameters: mockParameterSuccessResult)
      
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.repository.createPersonParametersThrowableError?.localizedDescription).to(equal(error.userFriendlyMessage))
    }
  }
}
