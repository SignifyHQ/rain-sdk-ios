import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import CryptoChartDomain

// Test cases for the CryptoChartDomain module.
final class GetCMCSymbolHistoryUseCaseTests: XCTestCase {
  
  var repository: MockCryptoChartRepositoryProtocol!
  var usecase: GetCMCSymbolHistoriesUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockCryptoChartRepositoryProtocol()
    usecase = GetCMCSymbolHistoriesUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Tests
extension GetCMCSymbolHistoryUseCaseTests {
  /// Test  get CMCSymbolHistory functionality under normal conditions.
  func test_getCMCSymbolHistory_happy_case() async {
    // Given The expected mock success
    let mockCMCSymbolHistory = MockCMCSymbolHistoriesEntity()
    mockCMCSymbolHistory.currency = "mock_currency"
    mockCMCSymbolHistory.interval = "mock_interval"
    let mockSuccessResult = [mockCMCSymbolHistory]
    
    self.repository.getCMCSymbolHistoriesSymbolPeriodReturnValue = mockSuccessResult
    
    // And generated mockSymbol and mockPeriod
    let mockSymbol = "mock_symbol"
    let mockperiod = "mock_period"

    // When calling getCMCSymbolHistories function on the repository should return an value successfully
    await expect {
      try await self.usecase
        .execute(symbol: mockSymbol, period: mockperiod)
        .count
    }
    // Then the repository will returns the same result as the api
    .to(equal(mockSuccessResult.count))
  }
  
  /// Test get CMCSymbolHistory functionality with wrong symbol.
  func test_getCMCSymbolHistory_wrongSymbol_case() async {
    // Given The expected mock error
    let expectedError = TestError.fail("mock_error")
    self.repository.getCMCSymbolHistoriesSymbolPeriodThrowableError = expectedError
    
    // And generated mockWrongSymbol and mockPeriod
    let mockWrongSymbol = "mock_wrong_symbol"
    let mockperiod = "mock_period"
    
    // When: Calling getCMCSymbolHistories function on the repository should throw an error as the same
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockWrongSymbol, period: mockperiod)
    }
    .to(throwError { error in
      // Then: The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
  
  /// Test get CMCSymbolHistory functionality with wrong period.
  func test_getCMCSymbolHistory_wrongPeriod_case() async {
    // Given The expected mock error
    let expectedError = TestError.fail("mock_error")
    self.repository.getCMCSymbolHistoriesSymbolPeriodThrowableError = expectedError
    
    // And generated mockSymbol and mockWrongperiod
    let mockSymbol = "mock_symbol"
    let mockWrongperiod = "mock_wrong_period"
    
    // When: Calling getCMCSymbolHistories function on the repository should throw an error as the same
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockSymbol, period: mockWrongperiod)
    }
    .to(throwError { error in
      // Then: The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }

  
  /// Test get CMCSymbolHistory functionality when it encounters an error.
  func test_getCMCSymbolHistory_failed_case_throw() async {
    // Given The expected mock error
    let expectedError = TestError.fail("mock_error")
    self.repository.getCMCSymbolHistoriesSymbolPeriodThrowableError = expectedError
    
    // And generated mockSymbol and mockPeriod
    let mockSymbol = "mock_symbol"
    let mockperiod = "mock_period"
    
    // When: Calling getCMCSymbolHistories function on the repository should throw an error as the same
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockSymbol, period: mockperiod)
    }
    .to(throwError { error in
      // Then: The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
