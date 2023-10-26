import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class SolidGetLinkedSourcesUseCaseTests: XCTestCase {
  
  var repository: MockSolidExternalFundingRepositoryProtocol!
  var usecase: SolidGetLinkedSourcesUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidExternalFundingRepositoryProtocol()
    usecase = SolidGetLinkedSourcesUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
  
  // Test the getLinkedSources functionality under normal conditions.
  func test_happy_case() async {
    let mockSuccessResult = MockAPISolidContactParameters.mockData
    self.repository.getLinkedSourcesAccountIDReturnValue = [mockSuccessResult]
    
    // When calling getLinkedSources function on the repository should throw an error as the same
    await expect {
      try await self.usecase.execute(accountID: "mock_account_id").first?.solidContactId
    }.to(equal(mockSuccessResult.solidContactId))
  }
  
  // Test the getLinkedSources functionality when it encounters an error.
  func test_failed_case_throw() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.repository.getLinkedSourcesAccountIDThrowableError = expectedError
    
    // When calling getLinkedSources function on the repository should throw an error as the same
    await expect {
      _ = try await self.usecase.execute(accountID: "mock_account_id")
    }
    .to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
