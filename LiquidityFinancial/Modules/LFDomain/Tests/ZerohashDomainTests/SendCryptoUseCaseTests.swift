import XCTest
import Foundation
import AccountDomain
import DomainTestHelpers
import TestHelpers

@testable import ZerohashDomain

final class SendCryptoUseCaseTests: XCTestCase {
  
  var repository: MockZerohashRepositoryProtocol!
  var usecase: SendCryptoUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockZerohashRepositoryProtocol()
    usecase = SendCryptoUseCase(repository: repository)
  }
  
  func test_happy_case() {
    runAsyncTest {
      let mockSuccessResult = MockTransactionEntity()
      mockSuccessResult.accountId = "mock_accountID"
      mockSuccessResult.amount = 999
      
      let mockFailedResult = MockTransactionEntity()
      
      self.repository.sendCryptoAccountIdDestinationAddressAmountClosure = { accountID, destinationAddress, amount async throws -> TransactionEntity in
        if accountID == "mock_accountID" && destinationAddress == "mock_destinationAddress" && amount == 999 {
          return mockSuccessResult
        }
        return mockFailedResult
      }
      
      let result = try await self.usecase.execute(accountId: "mock_accountID", destinationAddress: "mock_destinationAddress", amount: 999)
      
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
      
      self.repository.sendCryptoAccountIdDestinationAddressAmountClosure = { accountID, destinationAddress, amount async throws -> TransactionEntity in
        if accountID == "mock_accountID" {
          return mockSuccessResult
        }
        self.repository.sendCryptoAccountIdDestinationAddressAmountThrowableError = "wrong account ID"
        return mockFailedResult
      }
      
      _ = try await self.usecase.execute(accountId: "", destinationAddress: "mock_destinationAddress", amount: 999)
      
    } catch {
      XCTAssertEqual(self.repository.sendCryptoAccountIdDestinationAddressAmountThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
}
