import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import NetspendDomain

// MARK: - NSGetApplePayTokenUseCaseTests
final class NSGetApplePayTokenUseCaseTests: XCTestCase {
  
  var repository: MockNSCardRepositoryProtocol!
  var useCase: NSGetApplePayTokenUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockNSCardRepositoryProtocol()
    useCase = NSGetApplePayTokenUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Test Functions
extension NSGetApplePayTokenUseCaseTests {
  // Test getApplePayToken functionality under normal conditions.
  func test_getApplePayToken_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockApplePayTokenEntity = MockApplePayTokenEntity()
    let mockSuccessResult = MockGetApplePayTokenEntity()
    mockApplePayTokenEntity.cardId = "mock_cardID"
    mockSuccessResult.tokenEntities = [mockApplePayTokenEntity]
    // And a pre-set API return success value
    self.repository.getApplePayTokenSessionIdCardIdReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        sessionId: mockSessionID,
        cardId: mockCardID
      ).tokenEntities.first?.cardId
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.tokenEntities.first?.cardId))
  }
  
  // Test getApplePayToken functionality when it encounters an error.
  func test_getApplePayToken_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.getApplePayTokenSessionIdCardIdThrowableError = expectedError
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        sessionId: mockSessionID,
        cardId: mockCardID
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
