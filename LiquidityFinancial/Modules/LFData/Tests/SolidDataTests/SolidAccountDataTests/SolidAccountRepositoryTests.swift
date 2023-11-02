import DataTestHelpers
import NetworkTestHelpers
import Nimble
import TestHelpers
import XCTest

@testable import SolidData

// Test cases for the SolidData module.
final class SolidAccountRepositoryTests: XCTestCase {
  
  var api: MockSolidAccountAPIProtocol!
  var repository: SolidAccountRepository!
  
  override func setUp() {
    super.setUp()
    api = MockSolidAccountAPIProtocol()
    repository = SolidAccountRepository(accountAPI: api)
  }
  
  override func tearDown() {
    api = nil
    repository = nil
    
    super.tearDown()
  }
  
  // Test the get account functionality under normal conditions.
  func test_get_account_happy_case() async {
    // Given the expected mock success
    let mockSuccessResult = APISolidAccount(id: "", externalAccountId: "mock_external_account_id", currency: "", availableBalance: 10, availableUsdBalance: 10)
    self.api.getAccountsReturnValue = [mockSuccessResult]
    //When calling the getAccounts function on the repository, it should return a value successfully.
    await expect {
      try await self.repository.getAccounts().first?.externalAccountId
    }
    // Then the result is the one we expected
    .to(equal(mockSuccessResult.externalAccountId))
  }
  
  // Test the getAccount functionality when it encounters an error.
  func test_get_account_failed_case_throw() async {
    // Given a mock error that will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.getAccountsThrowableError = expectedError
    
    // When calling the getAccounts function on the repository, it should throw an error as expected
    await expect {
      _ = try await self.repository.getAccounts()
    }
    .to(throwError { error in
      // Then the error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
  
}
