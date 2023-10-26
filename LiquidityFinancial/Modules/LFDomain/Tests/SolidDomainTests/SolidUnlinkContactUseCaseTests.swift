import XCTest
import DomainTestHelpers
import TestHelpers
import Nimble

@testable import SolidDomain

final class SolidUnlinkContactUseCaseTests: XCTestCase {
  
  var repository: MockSolidExternalFundingRepositoryProtocol!
  var usecase: SolidUnlinkContactUseCase!
  
  override func setUp() {
    super.setUp()
    
    repository = MockSolidExternalFundingRepositoryProtocol()
    usecase = SolidUnlinkContactUseCase(repository: repository)
  }
  
  override func tearDown() {
    usecase = nil
    repository = nil
    super.tearDown()
  }
  
  // Test the unlinkContact functionality under normal conditions.
  func test_happy_case() {
    runAsyncTest {
      // Given the expected mock success
      let mockId = "mock_id"
      let mockSuccessResult = MockSolidUnlinkContactResponseEntity()
      mockSuccessResult.success = true
      self.repository.unlinkContactIdReturnValue = mockSuccessResult
      
      // When calling unlinkContact function on the repository should return an value successfully
      let resultExpectUseCase = try await self.usecase.execute(id: mockId)
      // Then the repository will returns the same result as the api
      expect(resultExpectUseCase.success).to(equal(true))
    }
  }
  
  // Test the unlinkContact functionality when it encounters an error.
  func test_failed_case_throw() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.repository.unlinkContactIdThrowableError = expectedError
    let mockId = "mock_id"
    
    // When calling unlinkContact function on the repository should throw an error as the same
    await expect {
      _ = try await self.usecase.execute(id: mockId)
    }
    .to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
