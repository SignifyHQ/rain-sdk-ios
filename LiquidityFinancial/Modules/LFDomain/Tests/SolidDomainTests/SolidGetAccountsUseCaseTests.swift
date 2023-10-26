import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class SolidGetAccountsUseCaseTests: XCTestCase {
  
  var repository: MockSolidAccountRepositoryProtocol!
  var usecase: SolidGetAccountsUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidAccountRepositoryProtocol()
    usecase = SolidGetAccountsUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
  
  // Test the getAccounts functionality under normal conditions.
  func test_happy_case() {
    runAsyncTest {
      // Given the expected mock success
      let mockSuccessResult = MockAPISolidAccountParameters.mockData
      self.repository.getAccountsReturnValue = [mockSuccessResult]
      
      // When calling getAccounts function on the repository should return an value successfully
      let resultExpectUseCase = try await self.usecase.execute()
      // Then the repository will returns the same result as the api
      expect(resultExpectUseCase.count).to(equal(1))
      expect(resultExpectUseCase.first?.externalAccountId).to(equal(mockSuccessResult.externalAccountId))
    }
  }
  
  // Test the getAccount functionality when it encounters an error.
  func test_failed_case_throw() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.repository.getAccountsThrowableError = expectedError
    
    // When calling getAccounts function on the repository should throw an error as the same
    await expect {
      _ = try await self.usecase.execute()
    }
    .to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
