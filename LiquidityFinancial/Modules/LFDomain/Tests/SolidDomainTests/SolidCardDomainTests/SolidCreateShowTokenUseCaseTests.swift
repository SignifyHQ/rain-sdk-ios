import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidCreateShowTokenUseCaseTests
final class SolidCreateShowTokenUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidCreateVGSShowTokenUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidCreateVGSShowTokenUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidCreateShowTokenUseCaseTests {
  // Test createShowToken functionality under normal conditions.
  func test_createShowToken_shouldReturnSuccessResponse() async {
    // Given a pre-set API return success value
    let mockSuccessResult = MockSolidCardShowTokenEntity()
    mockSuccessResult.showToken = "mock_showToken"
    self.repository.createVGSShowTokenCardIDReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(cardID: mockCardID).showToken
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.showToken))
  }
  
  // Test createShowToken functionality when it encounters an error.
  func test_createShowToken_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.createVGSShowTokenCardIDThrowableError = expectedError
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(cardID: mockCardID)
    }
    // Then the error is the one we expected
    .to(
      throwError { error in
        expect(error).to(equal(expectedError))
      }
    )
  }
}
