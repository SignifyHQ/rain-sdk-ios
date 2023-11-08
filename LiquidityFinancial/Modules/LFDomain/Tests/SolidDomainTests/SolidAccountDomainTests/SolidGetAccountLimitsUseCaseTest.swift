import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class SolidGetAccountLimitsUseCaseTest: XCTestCase {
  
  var repository: MockSolidAccountRepositoryProtocol!
  var usecase: SolidGetAccountLimitsUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidAccountRepositoryProtocol()
    usecase = SolidGetAccountLimitsUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
  
  // Test the getAccounts functionality under normal conditions.
  func test_happy_case() async {
    // Given the expected mock success
    self.repository.getAccountLimitsReturnValue = [MockSolidAccountLimitsEntity.mockData]
    
    // When calling getAccounts function on the repository should return an value successfully
    await expect {
      try await self.usecase.execute()?.depositTotalDaily
    }
    // Then the repository will returns the same result as the api
    .to(equal("10.00"))
  }
  
  // Test the getAccount functionality when it encounters an error.
  func test_failed_case_throw() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.repository.getAccountLimitsThrowableError = expectedError
    
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
