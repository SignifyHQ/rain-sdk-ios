import XCTest
import Foundation
import AccountDomain
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import ZerohashDomain

final class SendCryptoUseCaseTests: XCTestCase {
  
  var repository: MockZerohashRepositoryProtocol!
  var usecase: SendCryptoUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockZerohashRepositoryProtocol()
    usecase = SendCryptoUseCase(repository: repository)
  }
  
  func test_happy_case() async {
    // Given: Set up a mock success result.
    let mockSuccessResult = MockTransactionEntity()
    mockSuccessResult.accountId = "mock_accountID"
    mockSuccessResult.amount = 999
    self.repository.sendCryptoAccountIdDestinationAddressAmountReturnValue = mockSuccessResult
    // When: Call the 'execute' method on the use case with specific parameters and retrieve the result.
    await expect {
      let result = try await self.usecase.execute(accountId: "mock_accountID", destinationAddress: "mock_destinationAddress", amount: 999)
      return (result.accountId, result.amount)
    }
    // Then: Ensure that the result matches the mock success result.
    .to(equal((mockSuccessResult.accountId, mockSuccessResult.amount)))
  }
  
  func test_failed_case() async {
    // Given: Set up a mock error.
    let mockError = TestError.fail("mock_error")
    self.repository.sendCryptoAccountIdDestinationAddressAmountThrowableError = mockError
    // When: Call the 'execute' method on the use case, which triggers an error.
    await expect {
      try await self.usecase.execute(accountId: "", destinationAddress: "mock_destinationAddress", amount: 999)
    }
    // Then: Ensure that the use case throws the expected error.
    .to(
      throwError(closure: { error in
        expect(error).to(equal(mockError))
      })
    )
  }
}
