import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class SolidGetWireTranferUseCaseTest: XCTestCase {
  
  var repository: MockSolidExternalFundingRepositoryProtocol!
  var usecase: SolidGetWireTranferUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockSolidExternalFundingRepositoryProtocol()
    usecase = SolidGetWireTranferUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
  
  // Test the getWireTransfer functionality under normal conditions.
  func test_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockSuccessResult = MockSolidWireTransferResponseEntity()
      mockSuccessResult.accountNumber = "mock_account_number"
      mockSuccessResult.routingNumber = "mock_routing_number"
      let mockAccountId = "mock_account_id"
      self.repository.getWireTransferReturnValue = mockSuccessResult
      // When calling getWireTransfer function on the usecase should return an value successfully
      let resultExpectUseCase = try await self.usecase.execute(accountId: mockAccountId)
      // Then the usecase will returns the same result as the repository
      expect(resultExpectUseCase.accountNumber).to(equal(mockSuccessResult.accountNumber))
      expect(resultExpectUseCase.routingNumber).to(equal(mockSuccessResult.routingNumber))
    }
  }
  
  // Test the getWireTransfer functionality when it encounters an error.
  func test_failed_case_throw() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.repository.getWireTransferThrowableError = expectedError
    let mockAccountId = "mock_account_id"
    
    // When calling getWireTransfer function on the repository should throw an error as the same
    await expect {
      _ = try await self.usecase.execute(accountId: mockAccountId)
    }
    .to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
