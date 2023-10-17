import XCTest
import Foundation
import AccountDomain
import DomainTestHelpers
import TestHelpers

@testable import ZerohashDomain

final class LockedNetworkFeeUseCaseTests: XCTestCase {
  
  var repository: MockZerohashRepositoryProtocol!
  var usecase: LockedNetworkFeeUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockZerohashRepositoryProtocol()
    usecase = LockedNetworkFeeUseCase(repository: repository)
  }
  
  func test_happy_case() {
    runAsyncTest {
      let mockSuccessResult = APILockedNetworkFeeResponse(quoteId: "123456789", amount: 111, maxAmount: true, fee: 999)
      
      let mockFailedResult = APILockedNetworkFeeResponse(quoteId: "", amount: 0, maxAmount: false, fee: 0)
      
      self.repository.lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountClosure = { accountID, destinationAddress, amount, maxAmount async throws -> APILockedNetworkFeeResponse in
        if accountID == "mock_accountID" && destinationAddress == "mock_destinationAddress" && amount == 999 {
          return mockSuccessResult
        }
        return mockFailedResult
      }
      
      let result = try await self.usecase.execute(accountId: "mock_accountID", destinationAddress: "mock_destinationAddress", amount: 999, maxAmount: true)
      
      XCTAssertEqual(mockSuccessResult.quoteId, result.quoteId)
      XCTAssertEqual(mockSuccessResult.fee, result.fee)
    }
  }
  
  func test_failed_case() async {
    do {
      let mockSuccessResult = APILockedNetworkFeeResponse(quoteId: "123456789", amount: 111, maxAmount: true, fee: 999)
      
      let mockFailedResult = APILockedNetworkFeeResponse(quoteId: "", amount: 0, maxAmount: false, fee: 0)
      
      self.repository.lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountClosure = { accountID, destinationAddress, amount, maxAmount async throws -> APILockedNetworkFeeResponse in
        if accountID == "mock_accountID" && destinationAddress == "mock_destinationAddress" && amount == 999 {
          return mockSuccessResult
        }
        self.repository.lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountThrowableError = "AccountId is not found"
        return mockFailedResult
      }
      
      _ = try await self.usecase.execute(accountId: "mock_accountID", destinationAddress: "mock_destinationAddress", amount: 999, maxAmount: true)
      
    } catch {
      XCTAssertEqual(self.repository.lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
}
