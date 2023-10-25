import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import CryptoChartDomain
import Foundation
import Nimble
import XCTest

@testable import CryptoChartData

// Test cases for the DevicesData module.
final class CryptoChartDataTests: XCTestCase {
  
  var auth: MockAuthorizationManagerProtocol!
  var api: MockCryptoChartAPIProtocol!
  var repository: CryptoChartRepository!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the repository before each test. Inject mock objects into the repository
    auth = MockAuthorizationManagerProtocol()
    api = MockCryptoChartAPIProtocol()
    repository = CryptoChartRepository(cryptoChartAPI: api, auth: auth)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    auth = nil
    api = nil
    repository = nil
    
    super.tearDown()
  }
  
  /// Test get CMCSymbolHistorySymbolPeriod and token functionality under normal conditions.
  func test_getCMCSymbolHistorySymbolPeriod_happy_case() async {
    // Given the expected mock success and fail responses
    let mockSuccessResponse = [
      APICMCSymbolHistories(
        currency: "mock_currency",
        interval: "mock_interval",
        timestamp: "mock_timestamp",
        open: nil,
        close: nil,
        high: nil,
        low: nil,
        value: nil,
        volume: nil
      )
    ]
    
    // And a randomly generated mockSymbol and mockPeriod
    let mockSymbol = "mock_symbol"
    let mockPeriod = "mock_period"
    
    // And a mock API behaviour based on the mock input
    self.api.getCMCSymbolHistoriesSymbolPeriodReturnValue = mockSuccessResponse
    
    // When calling getCMCSymbolHistories function on the repository with parameters which should return a success response
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockSymbol, period: mockPeriod).count
    }
    // Then the first element in the response received from repository should be equal to that in the first element in mock response
    .to(equal(1))
    
    // And verify the input parameter should be correctly
    expect(self.api.getCMCSymbolHistoriesSymbolPeriodReceivedArguments)
    .to(equal((symbol: mockSymbol, period: mockPeriod)))
  }
  
  // Test get CMCSymbolHistorySymbolPeriod functionality with wrong symbol.
  func test_getCMCSymbolHistorySymbolPeriod_api_wrong_symbol_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    api.getCMCSymbolHistoriesSymbolPeriodThrowableError = expectedError
    
    // And a randomly generated mockWrongSymbol and mockPeriod
    let mockWrongSymbol = "mock_wrong_symbol"
    let mockPeriod = "mock_period"
    
    await expect {
      // When calling getCMCSymbolHistory function on the repository with parameter which should throw an error
      try await self.repository.getCMCSymbolHistories(symbol: mockWrongSymbol, period: mockPeriod).count
    }.to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
  
  // Test get CMCSymbolHistorySymbolPeriod functionality with wrong period.
  func test_getCMCSymbolHistorySymbolPeriod_api_wrong_period_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    api.getCMCSymbolHistoriesSymbolPeriodThrowableError = expectedError
    
    // And a randomly generated mockSymbol and mockWrongPeriod
    let mockSymbol = "mock_symbol"
    let mockWrongPeriod = "mock_wrong_period"
    
    await expect {
      // When calling getCMCSymbolHistory function on the repository with parameter which should throw an error
      try await self.repository.getCMCSymbolHistories(symbol: mockSymbol, period: mockWrongPeriod).count
    }.to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }

  
  // Test get CMCSymbolHistorySymbolPeriod functionality when it encounters an API error.
  func test_getCMCSymbolHistorySymbolPeriod_api_failed_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    api.getCMCSymbolHistoriesSymbolPeriodThrowableError = expectedError
    
    // And a randomly generated mockSymbol and mockPeriod
    let mockSymbol = "mock_symbol"
    let mockPeriod = "mock_period"
    
    await expect {
      // When calling getCMCSymbolHistories function on the repository with parameter which should throw an error
      try await self.repository.getCMCSymbolHistories(symbol: mockSymbol, period: mockPeriod).count
    }.to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
