import CoreNetwork
import DataTestHelpers
import ZerohashDomain
import Foundation
import Nimble
import XCTest
import TestHelpers

@testable import ZerohashData

// Test cases for the DevicesData module.
final class ZerohashRepositoryTests: XCTestCase {
  
  var api: MockZerohashAPIProtocol!
  var repository: ZerohashRepository!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the repository before each test. Inject mock objects into the repository
    api = MockZerohashAPIProtocol()
    repository = ZerohashRepository(zerohashAPI: api)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    api = nil
    repository = nil
    
    super.tearDown()
  }
  
  // Test the functionality of `getSellCryptoQoute` under expected conditions.
  func test_getSellCryptoQoute_happy_case() async {
    // Given the expected mock success and fail results
    var mockSuccessResult = APIGetSellQuote()
    mockSuccessResult.id = "mock_id"
    self.api.getSellQuoteAccountIdAmountQuantityReturnValue = mockSuccessResult
    
    await expect {
      // When calling `getSellCryptoQoute` function with parameters which should return `id` successfully
      try await self.repository.getSellQuote(accountId:"mock_account_id", amount: "mock_amount", quantity: "mock_quantity").id
    }
    // Then the `getSellCryptoQoute` received matches our expectation
    .to(equal(mockSuccessResult.id))
  }

  // Test the `getSellCryptoQoute` functionality when it encounters an error.
  func test_getSellCryptoQoute_failed_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    
    self.api.getSellQuoteAccountIdAmountQuantityThrowableError = expectedError
    // When calling the `getSellCryptoQoute` functionality on the repository with parameters which should throw an error
    await expect {
      try await self.repository.getSellQuote(accountId:"mock_account_id", amount: "mock_amount", quantity: "mock_quantity")
    }
    .to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
  
  // Test the functionality of `sellCrypto` under expected conditions.
  func test_SellCrypto_happy_case() async {
    // Given the expected mock success and fail results
    var mockSuccessResult = APISellCrypto()
    mockSuccessResult.id = "mock_id"
    self.api.sellCryptoAccountIdQuoteIdReturnValue = mockSuccessResult
    
    await expect {
      // When calling `sellCrypto` function with parameters which should return `id` successfully
      try await self.repository.sellCrypto(accountId: "mock_account_id", quoteId: "mock_qoute_id").id
    }
    // Then the `sellCrypto` received matches our expectation
    .to(equal(mockSuccessResult.id))
  }
  
  // Test the `sellCrypto` functionality when it encounters an error.
  func test_SellCrypto_failed_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    
    self.api.sellCryptoAccountIdQuoteIdThrowableError = expectedError
    // When calling the `getSellCryptoQoute` functionality on the repository with parameters which should throw an error
    await expect {
      try await self.repository.sellCrypto(accountId: "mock_account_id", quoteId: "mock_qoute_id")
    }
    .to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
