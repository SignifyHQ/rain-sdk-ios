import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import NetspendDomain

// MARK: - NSPostApplePayTokenUseCaseTests
final class NSPostApplePayTokenUseCaseTests: XCTestCase {
  
  var repository: MockNSCardRepositoryProtocol!
  var useCase: NSPostApplePayTokenUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockNSCardRepositoryProtocol()
    useCase = NSPostApplePayTokenUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Test Functions
extension NSPostApplePayTokenUseCaseTests {
  // Test postApplePayToken functionality under normal conditions.
  func test_postApplePayToken_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockPostApplePayTokenEntity()
    mockSuccessResult.activationData = "mock_activationData"
    // And a pre-set API return success value
    self.repository.postApplePayTokenSessionIdCardIdBodyDataReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockBodyData = ["mock_key": "mock_value"]
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        sessionId: mockSessionID,
        cardId: mockCardID,
        bodyData: mockBodyData
      ).activationData
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.activationData))
  }
  
  // Test postApplePayToken functionality when it encounters an error.
  func test_postApplePayToken_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.postApplePayTokenSessionIdCardIdBodyDataThrowableError = expectedError
    // And a set of mock parameters
    let mockBodyData = ["mock_key": "mock_value"]
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        sessionId: mockSessionID,
        cardId: mockCardID,
        bodyData: mockBodyData
      )
    }
    // Then the error is the one we expected
    .to(
      throwError { error in
        expect(error).to(equal(expectedError))
      }
    )
  }
}
