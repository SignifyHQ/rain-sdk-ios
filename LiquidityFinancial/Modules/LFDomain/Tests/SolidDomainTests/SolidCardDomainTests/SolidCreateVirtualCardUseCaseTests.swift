import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidCreateVirtualCardUseCaseTests
final class SolidCreateVirtualCardUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidCreateVirtualCardUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidCreateVirtualCardUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidCreateVirtualCardUseCaseTests {
  // Test createVirtualCard functionality under normal conditions.
  func test_createVirtualCard_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockSolidCardEntity()
    mockSuccessResult.id = "mock_cardID"
    // And a pre-set API return success value
    self.repository.createVirtualCardAccountIDParametersReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockAccountID = "mockAccountID"
    let mockCreateVirtualCardParameters = MockSolidCreateVirtualCardParametersEntity()
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(accountID: mockAccountID, parameters: mockCreateVirtualCardParameters).id
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.id))
  }
  
  // Test createVirtualCard functionality when it encounters an error.
  func test_createVirtualCard_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.createVirtualCardAccountIDParametersThrowableError = expectedError
    // And a set of mock parameters
    // And a set of mock parameters
    let mockAccountID = "mockAccountID"
    let mockCreateVirtualCardParameters = MockSolidCreateVirtualCardParametersEntity()
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(accountID: mockAccountID, parameters: mockCreateVirtualCardParameters)
    }
    // Then the error is the one we expected
    .to(
      throwError { error in
        expect(error).to(equal(expectedError))
      }
    )
  }
}
