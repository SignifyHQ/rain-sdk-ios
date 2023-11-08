import DataTestHelpers
import NetworkTestHelpers
import Nimble
import TestHelpers
import XCTest

@testable import NetSpendData

// Test cases for the SolidData module.
final class NSAccountRepositoryTests: XCTestCase {
  
  var api: MockNSAccountAPIProtocol!
  var repository: NSAccountRepository!
  
  override func setUp() {
    super.setUp()
    api = MockNSAccountAPIProtocol()
    repository = NSAccountRepository(accountAPI: api)
  }
  
  override func tearDown() {
    api = nil
    repository = nil
    
    super.tearDown()
  }
  
  // Test the get account limits functionality under normal conditions.
  func test_get_account_limits_happy_case() async {
    // Given the expected mock success
    let mockSuccessResult = APINetspendAccountLimits(
      spendingLimits: NetSpendData.SpendingLimits(),
      withdrawalLimits: NetSpendData.WithdrawalLimits(),
      depositLimits: NetSpendData.DepositLimits()
    )
    self.api.getAccountLimitsReturnValue = mockSuccessResult
    //When calling the getAccount limits function on the repository, it should return a value successfully.
    await expect {
      try await self.repository.getAccountLimits().depositLimits.externalCardLimits.isEmpty
    }
    // Then the result is the one we expected
    .to(equal(mockSuccessResult.depositLimits.externalCardLimits.isEmpty))
  }
  
  
  // Test the getAccount limits functionality when it encounters an error.
  func test_get_account_limits_failed_case_throw() async {
    // Given a mock error that will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.getAccountLimitsThrowableError = expectedError
    
    // When calling the getAccount limits function on the repository, it should throw an error as expected
    await expect {
      _ = try await self.repository.getAccountLimits()
    }
    .to(throwError { error in
      // Then the error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
