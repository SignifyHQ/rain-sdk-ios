import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import NetspendDomain

// MARK: - NSCreateCardUseCaseTests
final class NSCreateCardUseCaseTests: XCTestCase {
  
  var repository: MockNSCardRepositoryProtocol!
  var useCase: NSCreateCardUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockNSCardRepositoryProtocol()
    useCase = NSCreateCardUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Test Functions
extension NSCreateCardUseCaseTests {
  // Test createCard functionality under normal conditions.
  func test_createCard_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockNSCardEntity()
    mockSuccessResult.netspendCardId = "mock_cardID"
    // And a pre-set API return success value
    self.repository.createCardSessionIDReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(sessionID: mockSessionID).netspendCardId
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.netspendCardId))
  }
  
  // Test createCard functionality when it encounters an error.
  func test_createCard_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.createCardSessionIDThrowableError = expectedError
    // And a set of mock parameters
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(sessionID: mockSessionID).netspendCardId
    }
    // Then the error is the one we expected
    .to(
      throwError { error in
        expect(error).to(equal(expectedError))
      }
    )
  }
}
