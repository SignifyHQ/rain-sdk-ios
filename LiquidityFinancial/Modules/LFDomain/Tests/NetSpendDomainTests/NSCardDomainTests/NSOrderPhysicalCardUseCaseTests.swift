import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import NetspendDomain

// MARK: - NSOrderPhysicalCardUseCaseTests
final class NSOrderPhysicalCardUseCaseTests: XCTestCase {
  
  var repository: MockNSCardRepositoryProtocol!
  var useCase: NSOrderPhysicalCardUseCase!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the use case before each test. Inject mock objects into the use case
    repository = MockNSCardRepositoryProtocol()
    useCase = NSOrderPhysicalCardUseCase(repository: repository)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    useCase = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Test Functions
extension NSOrderPhysicalCardUseCaseTests {
  // Test orderPhysicalCard functionality under normal conditions.
  func test_orderPhysicalCard_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockNSCardEntity()
    mockSuccessResult.netspendCardId = "mock_cardID"
    // And a pre-set API return success value
    self.repository.orderPhysicalCardAddressSessionIDReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockAddress = MockAddressCardParametersEntity()
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        address: mockAddress,
        sessionID: mockSessionID
      ).netspendCardId
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.netspendCardId))
  }
  
  // Test orderPhysicalCard functionality when it encounters an error.
  func test_orderPhysicalCard_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.orderPhysicalCardAddressSessionIDThrowableError = expectedError
    // And a set of mock parameters
    let mockAddress = MockAddressCardParametersEntity()
    let mockSessionID = "mock_sessionID"
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        address: mockAddress,
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
