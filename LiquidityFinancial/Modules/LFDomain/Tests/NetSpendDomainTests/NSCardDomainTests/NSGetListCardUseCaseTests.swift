import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import NetspendDomain

// MARK: - NSGetListCardUseCaseTests
final class NSGetListCardUseCaseTests: XCTestCase {
  
  var repository: MockNSCardRepositoryProtocol!
  var useCase: NSGetListCardUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockNSCardRepositoryProtocol()
    useCase = NSGetListCardUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Test Functions
extension NSGetListCardUseCaseTests {
  // Test getListCard functionality under normal conditions.
  func test_getListCard_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockCardEntity = MockNSCardEntity()
    mockCardEntity.netspendCardId = "mock_cardID"
    let mockSuccessResult = [mockCardEntity]
    // And a pre-set API return success value
    self.repository.getListCardReturnValue = mockSuccessResult
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute().first?.netspendCardId
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.first?.netspendCardId))
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
