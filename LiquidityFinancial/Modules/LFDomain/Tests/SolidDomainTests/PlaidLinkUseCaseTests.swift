import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class PlaidLinkUseCaseTests: XCTestCase {
  
  var repository: MockLinkSourceRepositoryProtocol!
  var usecase: PlaidLinkUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockLinkSourceRepositoryProtocol()
    usecase = PlaidLinkUseCase(repository: repository)
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
      let mockSuccessResult = MockSolidContactEntity()
      mockSuccessResult.last4 = "mock_last4"
      
      self.repository.linkPlaidAccountIdTokenPlaidAccountIdReturnValue = mockSuccessResult
      // When calling plaid link function on the usecase with parameters which should return an value successfully
      let resultExpectRepository = try await self.usecase.execute(accountId: "", token: "", plaidAccountId: "")
      // Then the repository will returns the same result as the api
      expect(resultExpectRepository.last4).to(equal(mockSuccessResult.last4))
    }
  }
  
  // Test the createPlaidToken functionality when it encounters an error.
  func test_failed_case_throw() async {
    do {
      // And expected description of the error which will be thrown
      self.repository.linkPlaidAccountIdTokenPlaidAccountIdThrowableError = "Can't link"
      
      // When calling createPlaidToken function on the repository should throw an error as the same
      _ = try await self.usecase.execute(accountId: "", token: "", plaidAccountId: "")
      
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.repository.linkPlaidAccountIdTokenPlaidAccountIdThrowableError?.localizedDescription).to(equal(error.localizedDescription))
    }
  }
}
