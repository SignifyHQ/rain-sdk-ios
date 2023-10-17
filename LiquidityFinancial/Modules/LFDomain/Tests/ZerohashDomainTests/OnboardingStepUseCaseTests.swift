import XCTest
import Foundation
import AccountDomain
import DomainTestHelpers
import TestHelpers

@testable import ZerohashDomain

final class OnboardingStepUseCaseTests: XCTestCase {
  
  var repository: MockZerohashRepositoryProtocol!
  var usecase: OnboardingStepUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockZerohashRepositoryProtocol()
    usecase = OnboardingStepUseCase(repository: repository)
  }
  
  func test_happy_case() {
    runAsyncTest {
      let mockSuccessResult = MockZHOnboardingStepEntity(missingSteps: ["mock_missingSteps_1", "mock_missingSteps_2"])
      
      self.repository.getOnboardingStepClosure = { () async throws -> ZHOnboardingStepEntity in
        return mockSuccessResult
      }
      
      let result = try await self.usecase.execute()
      
      XCTAssertEqual(mockSuccessResult.missingSteps, result.missingSteps)
    }
  }
  
  func test_failed_case() async {
    do {
      let mockSuccessResult = MockZHOnboardingStepEntity(missingSteps: ["mock_missingSteps_1", "mock_missingSteps_2"])
      
      self.repository.getOnboardingStepClosure = { () async throws -> ZHOnboardingStepEntity in
        return mockSuccessResult
      }
      
      self.repository.executeAccountIdQuoteIdThrowableError = "something wrong"
      
      _ = try await self.usecase.execute()
    } catch {
      XCTAssertEqual(self.repository.executeAccountIdQuoteIdThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
}
