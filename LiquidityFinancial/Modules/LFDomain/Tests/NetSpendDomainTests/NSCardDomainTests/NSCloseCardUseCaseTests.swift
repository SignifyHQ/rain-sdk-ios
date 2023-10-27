import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import NetspendDomain

// MARK: - NSCloseCardUseCaseTests
final class NSCloseCardUseCaseTests: XCTestCase {
  
  var repository: MockNSCardRepositoryProtocol!
  var useCase: NSCloseCardUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockNSCardRepositoryProtocol()
    useCase = NSCloseCardUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Test Functions
extension NSCloseCardUseCaseTests {
  // Test closeCard functionality under normal conditions.
  func test_closeCard_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockCardEntity()
    mockSuccessResult.id = "mock_cardID"
    // And a pre-set API return success value
    self.repository.closeCardReasonCardIDSessionIDReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockReason = MockCloseCardReasonEntity()
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase
        .execute(
          reason: mockReason,
          cardID: mockCardID,
          sessionID: mockSessionID
        ).id
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.id))
  }
  
  // Test closeCard functionality when it encounters an error.
  func test_closeCard_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.closeCardReasonCardIDSessionIDThrowableError = expectedError
    // And a set of mock parameters
    let mockReason = MockCloseCardReasonEntity()
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase
        .execute(
          reason: mockReason,
          cardID: mockCardID,
          sessionID: mockSessionID
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
