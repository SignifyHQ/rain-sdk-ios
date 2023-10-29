import XCTest
import Foundation
import AccountDomain
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import ZerohashDomain

final class LockedNetworkFeeUseCaseTests: XCTestCase {
  
  var repository: MockZerohashRepositoryProtocol!
  var usecase: LockedNetworkFeeUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockZerohashRepositoryProtocol()
    usecase = LockedNetworkFeeUseCase(repository: repository)
  }
  
  func test_happy_case() async {
    // Given: Set up a mock success result.
    let mockSuccessResult = APILockedNetworkFeeResponse(quoteId: "123456789", amount: 111, maxAmount: true, fee: 999)
    self.repository.lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountReturnValue = mockSuccessResult

    // When: Call the 'execute' method on the use case with specific parameters and retrieve the quoteId and fee.
    await expect {
        let result = try await self.usecase.execute(accountId: "mock_accountID", destinationAddress: "mock_destinationAddress", amount: 999, maxAmount: true)
        return (result.quoteId, result.fee)
    }
    // Then: Ensure that the returned quoteId and fee match the values set in the mock success result.
    .to(equal((mockSuccessResult.quoteId, mockSuccessResult.fee)))
  }
  
  func test_failed_case() async {
    // Given: Set up a mock error.
    let mockError = TestError.fail("mock_error")
    self.repository.lockedNetworkFeeAccountIdDestinationAddressAmountMaxAmountThrowableError = mockError

    // When: Call the 'execute' method on the use case with specific parameters, which triggers an error.
    await expect {
        try await self.usecase.execute(accountId: "mock_accountID", destinationAddress: "mock_destinationAddress", amount: 999, maxAmount: true)
    }
    // Then: Ensure that the use case throws the expected error.
    .to(
        throwError(closure: { error in
            expect(error).to(equal(mockError))
        })
    )
  }
}
