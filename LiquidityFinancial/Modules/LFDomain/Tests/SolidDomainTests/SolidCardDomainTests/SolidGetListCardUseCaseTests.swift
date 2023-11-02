import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidGetListCardUseCaseTests
final class SolidGetListCardUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidGetListCardUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidGetListCardUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidGetListCardUseCaseTests {
  // Test getListCard functionality under normal conditions.
  func test_getListCard_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockCardEntity = MockSolidCardEntity()
    mockCardEntity.id = "mock_cardID"
    let mockSuccessResult = [mockCardEntity]
    // And a pre-set API return success value
    self.repository.getListCardReturnValue = mockSuccessResult
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute().first?.id
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.first?.id))
  }
  
  // Test getListCard functionality when it encounters an error.
  func test_getListCard_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.getListCardThrowableError = expectedError
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute()
    }
    // Then the error is the one we expected
    .to(
      throwError { error in
        expect(error).to(equal(expectedError))
      }
    )
  }
}
