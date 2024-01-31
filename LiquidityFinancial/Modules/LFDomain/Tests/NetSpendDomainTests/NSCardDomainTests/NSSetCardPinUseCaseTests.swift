import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import NetspendDomain

// MARK: - NSSetCardPinUseCaseTests
final class NSSetCardPinUseCaseTests: XCTestCase {
  
  var repository: MockNSCardRepositoryProtocol!
  var useCase: NSSetCardPinUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockNSCardRepositoryProtocol()
    useCase = NSSetCardPinUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Test Functions
extension NSSetCardPinUseCaseTests {
  // Test setPin functionality under normal conditions.
  func test_setPin_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockNSCardEntity()
    mockSuccessResult.netspendCardId = "mock_cardID"
    // And a pre-set API return success value
    self.repository.setPinRequestParamCardIDSessionIDReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockRequestParam = MockSetPinRequestEntity()
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        requestParam: mockRequestParam,
        cardID: mockCardID,
        sessionID: mockSessionID
      ).netspendCardId
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.netspendCardId))
  }
  
  // Test setPin functionality when it encounters an error.
  func test_setPin_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.setPinRequestParamCardIDSessionIDThrowableError = expectedError
    // And a set of mock parameters
    let mockRequestParam = MockSetPinRequestEntity()
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        requestParam: mockRequestParam,
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
