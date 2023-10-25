import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import CryptoChartDomain
import Foundation
import Nimble
import XCTest

@testable import CryptoChartData

// Test cases for the CryptoChartData module.
final class CryptoChartDataTests: XCTestCase {
  
  var auth: MockAuthorizationManagerProtocol!
  var api: MockCryptoChartAPIProtocol!
  var repository: CryptoChartRepository!
  
  // Defining mock API errors
  let mockUnsupportedSymbolError = TestError.fail("mock_unsupported_symbol_error")
  let mockMissingSymbolError = TestError.fail("mock_missing_symbol_error")
  let mockUnsupportedPeriodError = TestError.fail("mock_unsupported_period_error")
  let mockMissingPeriodError = TestError.fail("mock_missing_period_error")
  
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
  
  // Function to configure the API behaviour which should be consistent across all tests
  func configureAPIBehaviour() {
    // Define an array of supported currency symbols
    let supportedMockSymbols = [
      "mock_supported_symbol_1",
      "mock_supported_symbol_2",
      "mock_supported_symbol_3"
    ]
    // Define an array of supported periods
    let supportedMockPeriods = [
      "mock_supported_period_1",
      "mock_supported_period_2",
      "mock_supported_period_3"
    ]
    
    api.getCMCSymbolHistoriesSymbolPeriodClosure = { symbol, period async throws in
      // Check if symbol and period are supported by the API
      let isSymbolSupported = supportedMockSymbols.contains(symbol)
      let isPeriodSupported = supportedMockPeriods.contains(period)
      
      switch (isSymbolSupported, isPeriodSupported) {
        // Throw 'mock_missing_symbol_error' if the symbol is empty or 'mock_unsupported_symbol_error' if the symbol is not supported by the API
      case (false, _):
        throw symbol.isEmpty ? self.mockMissingSymbolError : self.mockUnsupportedSymbolError
        // Throw 'mock_missing_period_error' if the period is empty or 'mock_unsupported_period_error' if the period is not supported by the API
      case (_, false):
        throw period.isEmpty ? self.mockMissingPeriodError : self.mockUnsupportedPeriodError
        // Return a success mock response with the corresponding symbol and period
      default:
        let mockSuccessResponse = [
          APICMCSymbolHistories(
            currency: symbol,
            interval: period,
            timestamp: "mock_timestamp",
            open: nil,
            close: nil,
            high: nil,
            low: nil,
            value: nil,
            volume: nil
          )
        ]
        
        return mockSuccessResponse
      }
    }
  }
  
  // Test get CMCSymbolHistorySymbolPeriod functionality under normal conditions
  func test_getCMCSymbolHistorySymbolPeriod_happy_case() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // And a set of supported mock symbol and mock period
    let mockSupportedSymbol = "mock_supported_symbol_1"
    let mockSupportedPeriod = "mock_supported_period_1"
    // And an expectation predicate with expected symbol and period
    let expectationPredicate: (symbol: String?, period: String?) = (symbol: mockSupportedSymbol, period: mockSupportedPeriod)
    // When calling getCMCSymbolHistories function on the repository with parameters which should return a success response
    await expect {
      let response = try await self.repository.getCMCSymbolHistories(symbol: mockSupportedSymbol, period: mockSupportedPeriod)
      return (symbol: response.first?.currency, period: response.first?.interval)
    }
    // Then the first element in the response received from repository should contain the symbol and period we passed to the API
    .to(equal(expectationPredicate))
  }
  
  // Test get CMCSymbolHistorySymbolPeriod functionality when it encounters an API error
  func test_getCMCSymbolHistorySymbolPeriod_api_failed_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_api_error")
    api.getCMCSymbolHistoriesSymbolPeriodThrowableError = expectedError
    
    // And a set of supported mock symbol and mock period
    let mockSymbol = "mock_symbol"
    let mockPeriod = "mock_period"
    
    await expect {
      // When calling getCMCSymbolHistories function on the repository and it throws an error
      try await self.repository.getCMCSymbolHistories(symbol: mockSymbol, period: mockPeriod).count
    }
    // Then the error is the one we expected
    .to(
      throwError { error in
        expect(error).to(equal(expectedError))
      }
    )
  }
  
  // Test get CMCSymbolHistorySymbolPeriod functionality with wrong symbol
  func test_getCMCSymbolHistorySymbolPeriod_api_wrong_symbol_case() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // And a set of unsupported mock symbol and supported mock period
    let mockUnsupportedSymbol = "mock_unsupported_symbol_2"
    let mockSupportedPeriod = "mock_supported_period_2"
    // When calling getCMCSymbolHistory function on the repository
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockUnsupportedSymbol, period: mockSupportedPeriod)
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_unsupported_symbol_error'
        expect(error).to(equal(self.mockUnsupportedSymbolError))
      }
    )
  }
  
  // Test get CMCSymbolHistorySymbolPeriod functionality with missing symbol
  func test_getCMCSymbolHistorySymbolPeriod_api_missing_symbol_case() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // And a set of empty mock symbol and supported mock period
    let mockEmptySymbol = ""
    let mockSupportedPeriod = "mock_supported_period_3"
    // When calling getCMCSymbolHistory function on the repository
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockEmptySymbol, period: mockSupportedPeriod)
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_missing_symbol_error'
        expect(error).to(equal(self.mockMissingSymbolError))
      }
    )
  }
  
  // Test get CMCSymbolHistorySymbolPeriod functionality with wrong period
  func test_getCMCSymbolHistorySymbolPeriod_api_wrong_period_case() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // And a set of supported mock symbol and unsupported mock period
    let mockSupportedSymbol = "mock_supported_symbol_2"
    let mockUnsupportedPeriod = "mock_unsupported_period_2"
    // When calling getCMCSymbolHistory function on the repository
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockSupportedSymbol, period: mockUnsupportedPeriod)
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_unsupported_period_error'
        expect(error).to(equal(self.mockUnsupportedPeriodError))
      }
    )
  }
  
  // Test get CMCSymbolHistorySymbolPeriod functionality with missing symbol
  func test_getCMCSymbolHistorySymbolPeriod_api_missing_period_case() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // And a set of supported mock symbol and empty mock period
    let mockSupportedSymbol = "mock_supported_symbol_3"
    let mockEmptyPeriod = ""
    // When calling getCMCSymbolHistory function on the repository
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockSupportedSymbol, period: mockEmptyPeriod)
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_missing_period_error'
        expect(error).to(equal(self.mockMissingPeriodError))
      }
    )
  }
}
