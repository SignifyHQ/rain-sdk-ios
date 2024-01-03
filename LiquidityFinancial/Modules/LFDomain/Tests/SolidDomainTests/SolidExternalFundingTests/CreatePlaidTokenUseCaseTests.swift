import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class CreatePlaidTokenUseCaseTests: XCTestCase {
  
  var repository: MockSolidExternalFundingRepositoryProtocol!
  var usecase: CreatePlaidTokenUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockSolidExternalFundingRepositoryProtocol()
    usecase = CreatePlaidTokenUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
  
  // Test the createPlaidToken functionality under normal conditions.
  func test_happy_case() {
    runAsyncTest {
      // Given the expected mock success
      let mockSuccessResult = MockCreatePlaidTokenResponseEntity()
      mockSuccessResult.linkToken = "mock_link_token"
      let accountIdSuccess = "mock_account_id"
      self.repository.createPlaidTokenAccountIDReturnValue = mockSuccessResult
      
      // When calling createPlaidToken function on the repository should return an value successfully
      let resultExpectUseCase = try await self.usecase.execute(accountId: accountIdSuccess)
      // Then the repository will returns the same result as the api
      expect(resultExpectUseCase.linkToken).to(equal(mockSuccessResult.linkToken))
    }
  }
  
  // Test the createPlaidToken functionality when it encounters an error.
  func test_failed_case_throw() async {
    do {
      // And expected description of the error which will be thrown
      self.repository.createPlaidTokenAccountIDThrowableError = "Can't create a token"
      
      // When calling createPlaidToken function on the repository should throw an error as the same
      _ = try await self.repository.createPlaidToken(accountID: "")
      
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.repository.createPlaidTokenAccountIDThrowableError?.localizedDescription).to(equal(error.userFriendlyMessage))
    }
  }
}
