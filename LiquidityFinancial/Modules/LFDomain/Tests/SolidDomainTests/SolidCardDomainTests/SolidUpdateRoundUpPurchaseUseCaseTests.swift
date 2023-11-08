import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidUpdateRoundUpPurchaseUseCaseTests
final class SolidUpdateRoundUpPurchaseUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidUpdateRoundUpDonationUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidUpdateRoundUpDonationUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidUpdateRoundUpPurchaseUseCaseTests {
  // Test updateRoundUpPurchase functionality under normal conditions.
  func test_updateRoundUpPurchase_shouldReturnSuccessResponse() async {
    // Given a pre-set API return success value
    let mockSuccessResult = MockSolidCardEntity()
    mockSuccessResult.id = "mock_cardID"
    self.repository.updateRoundUpDonationCardIDParametersReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockParameters = MockSolidRoundUpDonationParametersEntity()
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(cardID: mockCardID, parameters: mockParameters).id
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.id))
  }
  
  // Test updateRoundUpPurchase functionality when it encounters an error.
  func test_updateRoundUpPurchase_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.updateRoundUpDonationCardIDParametersThrowableError = expectedError
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockParameters = MockSolidRoundUpDonationParametersEntity()
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(cardID: mockCardID, parameters: mockParameters)
    }
    // Then the error is the one we expected
    .to(
      throwError { error in
        expect(error).to(equal(expectedError))
      }
    )
  }
}
