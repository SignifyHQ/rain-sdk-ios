import XCTest
import Foundation
import DomainTestHelpers
import TestHelpers
import XCTest

@testable import OnboardingDomain

final class RequestOTPUseCaseTests: XCTestCase {
  var repository: MockOnboardingRepositoryProtocol!
  var usecase: RequestOTPUseCase!
  
  override func setUp() {
    super.setUp()
    repository = MockOnboardingRepositoryProtocol()
    usecase = RequestOTPUseCase(repository: repository)
  }
  
  func test_happy_case() {
    runAsyncTest {
      let mockSuccessResult = MockOtpEntity()
      mockSuccessResult.requiredAuth = ["mock_requiredAuth", "mock_requiredAuth_1"]
      
      let mockFailedResult = MockOtpEntity()
      
      self.repository.requestOTPPhoneNumberClosure = { phoneNumber async throws -> OtpEntity in
        if phoneNumber == "123456789" {
          return mockSuccessResult
        }
        return mockFailedResult
      }
      
      let result = try await self.usecase.execute(phoneNumber: "123456789")
      
      XCTAssertEqual(mockSuccessResult.requiredAuth, result.requiredAuth)
    }
  }
  
  func test_failed_case() async {
    do {
      let mockSuccessResult = MockOtpEntity()
      mockSuccessResult.requiredAuth = ["mock_requiredAuth", "mock_requiredAuth_1"]
      
      let mockFailedResult = MockOtpEntity()
      
      self.repository.requestOTPPhoneNumberClosure = { phoneNumber async throws -> OtpEntity in
        if phoneNumber == "123456789" {
          return mockSuccessResult
        }
        self.repository.requestOTPPhoneNumberThrowableError = "wrong the phone number"
        return mockFailedResult
      }
      
      _ = try await self.usecase.execute(phoneNumber: "")
      
    } catch {
      XCTAssertEqual(self.repository.requestOTPPhoneNumberThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
}
