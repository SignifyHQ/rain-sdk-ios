import Foundation
import XCTest
import DataTestHelpers
import NetworkTestHelpers
import TestHelpers

@testable import OnboardingData

final class OnboardingDataTests: XCTestCase {
  
  var auth: MockAuthorizationManagerProtocol!
  var api: MockOnboardingAPIProtocol!
  var repository: OnboardingRepository!
  
  override func setUp() {
    super.setUp()
    auth = MockAuthorizationManagerProtocol()
    api = MockOnboardingAPIProtocol()
    repository = OnboardingRepository(onboardingAPI: api, auth: auth)
  }
  
  // Note: This is a sample test just to verify Mockingbird integration
  func test_login_happy_case() {
    runAsyncTest {
      let mockResult = APIAccessTokens(accessToken: "mock_accesstoken", tokenType: "mock_tokenType", refreshToken: "mock_refreshToken", expiresIn: 123456789)
      let mockfailedResult = APIAccessTokens(accessToken: "", tokenType: "", refreshToken: "", expiresIn: 0)
      
      self.api.loginPhoneNumberOtpCodeLastIDClosure = { phoneNumber, otpCode, lastID async throws -> APIAccessTokens in
        if phoneNumber == "123456789" && otpCode == "1234" {
          return mockResult
        }
        return mockfailedResult
      }
      
      let result = try await self.repository.login(phoneNumber: "123456789", otpCode: "1234", lastID: "0000")
      
      XCTAssertEqual(result.accessToken, mockResult.accessToken)
      
      XCTAssertEqual(self.auth.refreshWithApiTokenReceivedApiToken?.accessToken, mockResult.accessToken)
    }
  }
  
  func test_login_failed_case() async {
    do {
      let mockResult = APIAccessTokens(accessToken: "mock_accesstoken", tokenType: "mock_tokenType", refreshToken: "mock_refreshToken", expiresIn: 123456789)
      let mockfailedResult = APIAccessTokens(accessToken: "", tokenType: "", refreshToken: "", expiresIn: 0)
      
      self.api.loginPhoneNumberOtpCodeLastIDClosure = { phoneNumber, otpCode, lastID async throws -> APIAccessTokens in
        if phoneNumber == "123456789" && otpCode == "1234" {
          return mockResult
        }
        self.api.loginPhoneNumberOtpCodeLastIDThrowableError = "User is enter wrong phone number or otpCode"
        return mockfailedResult
      }
      
      _ = try await self.repository.login(phoneNumber: "0123456789", otpCode: "", lastID: "0000")
      
    } catch {
      XCTAssertEqual(self.api.loginPhoneNumberOtpCodeLastIDThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
  
  func test_request_otp_happy_case() {
    runAsyncTest {
      let mockResult = APIOtp(requiredAuth: ["mock_requiredAuth_1", "mock_requiredAuth_2"])
      let mockfailedResult = APIOtp(requiredAuth: [])
      self.api.requestOTPPhoneNumberClosure = { phoneNumber async throws -> APIOtp in
        if phoneNumber == "123456789" {
          return mockResult
        }
        return mockfailedResult
      }
      let result = try await self.repository.requestOTP(phoneNumber: "123456789")
      XCTAssertEqual(result.requiredAuth, mockResult.requiredAuth)
    }
  }
  
  func test_request_otp_failed_case() async {
    do {
      let mockResult = APIOtp(requiredAuth: ["mock_requiredAuth_1", "mock_requiredAuth_2"])
      let mockfailedResult = APIOtp(requiredAuth: [])
      self.api.requestOTPPhoneNumberClosure = { phoneNumber async throws -> APIOtp in
        if phoneNumber == "123456789" {
          return mockResult
        }
        self.api.requestOTPPhoneNumberThrowableError = "The phone number is invalid"
        return mockfailedResult
      }
      _ = try await self.repository.requestOTP(phoneNumber: "012345678900")
    } catch {
      XCTAssertEqual(self.api.requestOTPPhoneNumberThrowableError?.localizedDescription, error.localizedDescription)
    }
  }

  func test_get_onboarding_state_happy_case() {
    runAsyncTest {
      let mockResult = APIOnboardingState(missingSteps: ["mock_missingSteps_1", "mock_missingSteps_2"])
      let mockfailedResult = APIOnboardingState(missingSteps: [""])
      let sessionID = UUID().uuidString
      self.api.getOnboardingStateSessionIdClosure = { sessionId async throws -> APIOnboardingState in
        if sessionId == sessionID {
          return mockResult
        }
        return mockfailedResult
      }
      let result = try await self.repository.onboardingState(sessionId: sessionID)
      XCTAssertEqual(result.missingSteps, mockResult.missingSteps)
    }
  }
  
  func test_get_onboarding_state_failed_case() async {
    do {
      let mockResult = APIOnboardingState(missingSteps: ["mock_missingSteps_1", "mock_missingSteps_2"])
      let mockfailedResult = APIOnboardingState(missingSteps: [""])
      let sessionID = UUID().uuidString
      self.api.getOnboardingStateSessionIdClosure = { sessionId async throws -> APIOnboardingState in
        if sessionId == UUID().uuidString {
          return mockResult
        }
        self.api.getOnboardingStateSessionIdThrowableError = "The session ID is invalid"
        return mockfailedResult
      }
      _ = try await self.repository.onboardingState(sessionId: sessionID)
    } catch {
      XCTAssertEqual(self.api.getOnboardingStateSessionIdThrowableError?.localizedDescription, error.localizedDescription)
    }
  }
}
