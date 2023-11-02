import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class SolidDebitCardTokenUseCaseTests: XCTestCase {
  
  var repository: MockSolidExternalFundingRepositoryProtocol!
  var usecase: SolidDebitCardTokenUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockSolidExternalFundingRepositoryProtocol()
    usecase = SolidDebitCardTokenUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
}

// MARK: - Tests
extension SolidDebitCardTokenUseCaseTests {
  /// Test the createDebitCardToken functionality under normal conditions.
  func test_createDebitCardToken_happy_case() async {
    // Given: The expected mock success
    let mockSuccessResult = MockSolidDebitCardTokenEntity()
    mockSuccessResult.linkToken = "mock_link_token"
    mockSuccessResult.solidContactId = "mock_solid_contact_id"
    let accountIDSuccess = "mock_account_id"
    self.repository.createDebitCardTokenAccountIDReturnValue = mockSuccessResult
    
    // When: Calling createPlaidToken function on the repository should return an value successfully
    await expect {
      try await self.usecase
        .execute(accountID: accountIDSuccess)
        .linkToken
    }
    // Then: The repository will returns the same result as the api
    .to(equal(mockSuccessResult.linkToken))
  }
  
  /// Test the createDebitCardToken functionality when it encounters an error.
  func test_createDebitCardToken_failed_case_throw() async {
    let expectedError = TestError.fail("mock_error")
    self.repository.createDebitCardTokenAccountIDThrowableError = expectedError
    
    // When: Calling createDebitCardToken function on the repository should throw an error as the same
    await expect {
      try await self.repository.createDebitCardToken(accountID: "").linkToken
    }
    .to(throwError { error in
      // Then: The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
