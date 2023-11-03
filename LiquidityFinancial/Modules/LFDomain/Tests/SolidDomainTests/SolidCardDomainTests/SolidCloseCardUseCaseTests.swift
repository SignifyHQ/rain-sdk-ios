import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidCloseCardUseCaseTests
final class SolidCloseCardUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidCloseCardUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidCloseCardUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidCloseCardUseCaseTests {
  // Test closeCard functionality under normal conditions.
  func test_closeCard_shouldReturnSuccessResponse() async {
    // Given a pre-set API return success value
    self.repository.closeCardCardIDReturnValue = true
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(cardID: mockCardID)
    }
    // Then response should be the one we expect
    .to(equal(true))
  }
  
  // Test closeCard functionality when it encounters an error.
  func test_closeCard_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.closeCardCardIDThrowableError = expectedError
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
