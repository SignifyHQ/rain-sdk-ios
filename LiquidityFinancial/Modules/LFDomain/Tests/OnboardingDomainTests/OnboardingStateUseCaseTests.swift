import XCTest
import Foundation
import DomainTestHelpers
import TestHelpers
import XCTest

@testable import OnboardingDomain

final class OnboardingStateUseCaseTests: XCTestCase {
  var repository: MockOnboardingRepositoryProtocol!
  var usecase: OnboardingStateUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockOnboardingRepositoryProtocol()
    usecase = OnboardingStateUseCase(repository: repository)
  }
  
  func test_happy_case() {
    runAsyncTest {
      let mockSuccessResult = MockOnboardingStateEnity()
      mockSuccessResult.missingSteps = ["missingSteps_1", "missingSteps_2"]
      
      let mockFailedResult = MockOnboardingStateEnity()
      
      let mockSessionID = UUID().uuidString
      
      self.repository.onboardingStateSessionIdClosure = { sessionId async throws -> MockOnboardingStateEnity in
        if sessionId == mockSessionID {
          return mockSuccessResult
        }
        return mockFailedResult
      }
      
      let result = try await self.usecase.execute(sessionId: mockSessionID)
      
      XCTAssertEqual(mockSuccessResult.missingSteps, result.missingSteps)
    }
  }
  
  func test_failed_case() async {
    do {
      let mockSuccessResult = MockOnboardingStateEnity()
      mockSuccessResult.missingSteps = ["missingSteps_1", "missingSteps_2"]
      
      let mockFailedResult = MockOnboardingStateEnity()
      
      let mockSessionID = UUID().uuidString
      
      self.repository.onboardingStateSessionIdClosure = { sessionId async throws -> MockOnboardingStateEnity in
        if sessionId == mockSessionID {
          return mockSuccessResult
        }
        self.repository.onboardingStateSessionIdThrowableError = "Wrong sessionID"
        return mockFailedResult
      }
      
      _ = try await self.usecase.execute(sessionId: "")
      
    } catch {
      XCTAssertEqual(self.repository.onboardingStateSessionIdThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
}
