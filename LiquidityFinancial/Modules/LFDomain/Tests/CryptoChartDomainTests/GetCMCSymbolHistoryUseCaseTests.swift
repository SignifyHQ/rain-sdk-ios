import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import CryptoChartDomain

// Test cases for the CryptoChartDomain module.
final class GetCMCSymbolHistoryUseCaseTests: XCTestCase {
  
  var repository: MockCryptoChartRepositoryProtocol!
  var useCase: GetCMCSymbolHistoriesUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockCryptoChartRepositoryProtocol()
    useCase = GetCMCSymbolHistoriesUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Tests
extension GetCMCSymbolHistoryUseCaseTests {
  // Test GetCMCSymbolHistoriesUseCase functionality under normal conditions.
  func test_getCMCSymbolHistory_happy_case() async {
    // Given The expected mock success response
    let mockCMCSymbolHistory = MockCMCSymbolHistoriesEntity()
    mockCMCSymbolHistory.currency = "mock_currency"
    mockCMCSymbolHistory.interval = "mock_interval"
    let mockSuccessResult = [mockCMCSymbolHistory]
    // And a pre-set API return success value
    self.repository.getCMCSymbolHistoriesSymbolPeriodReturnValue = mockSuccessResult
    // And a set of mock symbol and mock period
    let mockSymbol = "mock_symbol"
    let mockperiod = "mock_period"
    // When calling execute function on the use case which should return a value successfully
    await expect {
      try await self.useCase
        .execute(
          symbol: mockSymbol,
          period: mockperiod
        ).first?.currency
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.first?.currency))
  }
  
  // Test get GetCMCSymbolHistoriesUseCase functionality when it encounters an error.
  func test_getCMCSymbolHistory_failed_case_throw() async {
    // Given The expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.getCMCSymbolHistoriesSymbolPeriodThrowableError = expectedError
    // And a set of mock symbol and mock period
    let mockSymbol = "mock_symbol"
    let mockperiod = "mock_period"
    // When calling execute function on the use case which throws an error
    await expect {
      try await self.repository.getCMCSymbolHistories(symbol: mockSymbol, period: mockperiod)
    }
    // Then The error is the one we expected
    .to(
      throwError { error in
        expect(error).to(equal(expectedError))
      }
    )
  }
}
