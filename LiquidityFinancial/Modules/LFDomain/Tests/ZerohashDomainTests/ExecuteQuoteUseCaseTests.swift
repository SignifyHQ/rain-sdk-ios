import XCTest
import Foundation
import AccountDomain
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import ZerohashDomain

final class ExecuteQuoteUseCaseTests: XCTestCase {
  
  var repository: MockZerohashRepositoryProtocol!
  var usecase: ExecuteQuoteUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockZerohashRepositoryProtocol()
    usecase = ExecuteQuoteUseCase(repository: repository)
  }
  
  func test_happy_case() async {
    // Given: Set up a mock success result with a specific accountId.
    let mockSuccessResult = MockTransactionEntity()
    mockSuccessResult.accountId = "mock_accountID"
    self.repository.executeAccountIdQuoteIdReturnValue = mockSuccessResult
    
    // When: Call the 'execute' method on the use case with specific accountId and quoteId.
    await expect {
      try await self.usecase.execute(accountId: "mock_accountId", quoteId: "mock_quoteId").accountId
    }
    // Then: Ensure that the returned accountId matches the one set in the mock success result.
    .to(equal(mockSuccessResult.accountId))
  }
  
  func test_failed_case() async {
    // Given: Set up a mock success result and a mock error.
    let mockSuccessResult = MockTransactionEntity()
    mockSuccessResult.accountId = "mock_accountID"
    mockSuccessResult.amount = 999
    let mockError = TestError.fail("mock_error")
    
    self.repository.executeAccountIdQuoteIdClosure = { accountID, quoteId async throws -> TransactionEntity in
      if accountID == "mock_accountId" && quoteId == "mock_quoteId" {
        return mockSuccessResult
      }
      throw mockError
    }
    // When: Call the 'execute' method on the use case with empty accountId and quoteId, which triggers an error.
    await expect {
      try await self.usecase.execute(accountId: "", quoteId: "")
    }.to(
      // Then: Ensure that the use case throws the expected error.
      throwError(closure: { error in
        expect(error).to(equal(mockError))
      })
    )
  }
}
