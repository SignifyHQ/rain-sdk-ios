import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import NetspendDomain

// MARK: - NSVerifyCVVCodeUseCaseTests
final class NSVerifyCVVCodeUseCaseTests: XCTestCase {
  
  var repository: MockNSCardRepositoryProtocol!
  var useCase: NSVerifyCVVCodeUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockNSCardRepositoryProtocol()
    useCase = NSVerifyCVVCodeUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Test Functions
extension NSVerifyCVVCodeUseCaseTests {
  // Test verifyCVVCode functionality under normal conditions.
  func test_verifyCVVCode_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockVerifyCVVCodeEntity()
    mockSuccessResult.id = "mock_cardID"
    // And a pre-set API return success value
    self.repository.verifyCVVCodeVerifyRequestCardIDSessionIDReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockRequestParam = MockVerifyCVVCodeParametersEntity()
    let mockCardID = "mock_cardID"
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        requestParam: mockRequestParam,
        cardID: mockCardID,
        sessionID: mockSessionID
      ).id
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.id))
  }
  
  // Test verifyCVVCode functionality when it encounters an error.
  func test_verifyCVVCode_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.verifyCVVCodeVerifyRequestCardIDSessionIDThrowableError = expectedError
    // And a set of mock parameters
    let mockRequestParam = MockVerifyCVVCodeParametersEntity()
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
