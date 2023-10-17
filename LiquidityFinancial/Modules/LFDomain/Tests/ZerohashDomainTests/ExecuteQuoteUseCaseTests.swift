import XCTest
import Foundation
import AccountDomain
import DomainTestHelpers
import TestHelpers

@testable import ZerohashDomain

final class ExecuteQuoteUseCaseTests: XCTestCase {
  
  var repository: MockZerohashRepositoryProtocol!
  var usecase: ExecuteQuoteUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockZerohashRepositoryProtocol()
    usecase = ExecuteQuoteUseCase(repository: repository)
  }
  
  func test_happy_case() {
    runAsyncTest {
      let mockSuccessResult = MockTransactionEntity()
      mockSuccessResult.accountId = "mock_accountID"
      mockSuccessResult.amount = 999
      
      let mockFailedResult = MockTransactionEntity()
      
      self.repository.executeAccountIdQuoteIdClosure = { accountID, quoteId async throws -> TransactionEntity in
        if accountID == "mock_accountId" && quoteId == "mock_quoteId" {
          return mockSuccessResult
        }
        return mockFailedResult
      }
      
      let result = try await self.usecase.execute(accountId: "mock_accountId", quoteId: "mock_quoteId")
      
      XCTAssertEqual(mockSuccessResult.accountId, result.accountId)
      XCTAssertEqual(mockSuccessResult.amount, result.amount)
    }
  }
  
  func test_failed_case() async {
    do {
      let mockSuccessResult = MockTransactionEntity()
      mockSuccessResult.accountId = "mock_accountID"
      mockSuccessResult.amount = 999
      
      let mockFailedResult = MockTransactionEntity()
      
      self.repository.executeAccountIdQuoteIdClosure = { accountID, quoteId async throws -> TransactionEntity in
        if accountID == "mock_accountId" && quoteId == "mock_quoteId" {
          return mockSuccessResult
        }
        self.repository.executeAccountIdQuoteIdThrowableError = "something wrong"
        return mockFailedResult
      }
      
      _ = try await self.usecase.execute(accountId: "", quoteId: "")
      
    } catch {
      XCTAssertEqual(self.repository.executeAccountIdQuoteIdThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
}
