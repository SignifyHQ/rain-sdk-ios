import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidActivePhysicalCardUseCaseTests
final class SolidActivePhysicalCardUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidActiveCardUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidActiveCardUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidActivePhysicalCardUseCaseTests {
  // Test activePhysicalCard functionality under normal conditions.
  func test_activePhysicalCard_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockSolidCardEntity()
    mockSuccessResult.id = "mock_cardID"
    // And a pre-set API return success value
    self.repository.activeCardCardIDParametersReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockParameters = MockSolidActiveCardParametersEntity()
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
  
  // Test activePhysicalCard functionality when it encounters an error.
  func test_activePhysicalCard_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.activeCardCardIDParametersThrowableError = expectedError
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockParameters = MockSolidActiveCardParametersEntity()
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
