import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

// MARK: - SolidCreateDigitalWalletLinkUseCaseTests
final class SolidCreateDigitalWalletLinkUseCaseTests: XCTestCase {
  
  var repository: MockSolidCardRepositoryProtocol!
  var useCase: SolidCreateDigitalWalletUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidCardRepositoryProtocol()
    useCase = SolidCreateDigitalWalletUseCase(repository: repository)
  }
  
  override func tearDown() {
    useCase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Test Functions
extension SolidCreateDigitalWalletLinkUseCaseTests {
  // Test createDigitalWalletLink functionality under normal conditions.
  func test_createDigitalWalletLink_shouldReturnSuccessResponse() async {
    // Given the expected mock success response
    let mockSuccessResult = MockSolidDigitalWalletEntity()
    mockSuccessResult.wallet = "mock_wallet"
    // And a pre-set API return success value
    self.repository.createDigitalWalletLinkCardIDParametersReturnValue = mockSuccessResult
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockParameters = MockSolidApplePayParametersEntity()
    // When calling execute function on the use case
    await expect {
      try await self.useCase.execute(
        cardID: mockCardID,
        parameters: mockParameters
      ).wallet
    }
    // Then response should be the one we expect
    .to(equal(mockSuccessResult.wallet))
  }
  
  // Test createDigitalWalletLink functionality when it encounters an error.
  func test_createDigitalWalletLink_shouldThrowError() async {
    // Given the expected mock error
    let expectedError = TestError.fail("mock_error")
    // And a pre-set API throwable error
    self.repository.createDigitalWalletLinkCardIDParametersThrowableError = expectedError
    // And a set of mock parameters
    let mockCardID = "mock_cardID"
    let mockParameters = MockSolidApplePayParametersEntity()
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
