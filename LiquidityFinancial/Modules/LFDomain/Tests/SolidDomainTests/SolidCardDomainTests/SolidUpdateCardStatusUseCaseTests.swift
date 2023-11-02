import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidUpdateCardStatusUseCaseTests
final class SolidUpdateCardStatusUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidUpdateCardStatusUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidUpdateCardStatusUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidUpdateCardStatusUseCaseTests {
  // Test updateCardStatus functionality under normal conditions.
  func test_updateCardStatus_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockSolidCardEntity()
    mockSuccessResult.id = "mock_cardID"
    // And a pre-set API return success value
    self.repository.updateCardStatusCardIDParametersReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockParameters = MockSolidCardStatusParametersEntity()
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        cardID: mockCardID,
        parameters: mockParameters
      ).id
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.id))
  }
  
  // Test updateCardStatus functionality when it encounters an error.
  func test_updateCardStatus_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.updateCardStatusCardIDParametersThrowableError = expectedError
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockParameters = MockSolidCardStatusParametersEntity()
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        cardID: mockCardID,
        parameters: mockParameters
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
