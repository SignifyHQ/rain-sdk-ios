import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidCreateCardPinTokenUseCaseTests
final class SolidCreateCardPinTokenUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidCreateCardPinTokenUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidCreateCardPinTokenUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidCreateCardPinTokenUseCaseTests {
  // Test updateRoundUpPurchase functionality under normal conditions.
  func test_updateRoundUpPurchase_shouldReturnSuccessResponse() async {
    // Given a pre-set API return success value
    let mockSuccessResult = MockSolidCardPinTokenEntity()
    mockSuccessResult.solidCardId = "mock_solidCardId"
    self.repository.createCardPinTokenCardIDReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(cardID: mockCardID).solidCardId
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.solidCardId))
  }
  
  // Test updateRoundUpPurchase functionality when it encounters an error.
  func test_updateRoundUpPurchase_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.createCardPinTokenCardIDThrowableError = expectedError
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
