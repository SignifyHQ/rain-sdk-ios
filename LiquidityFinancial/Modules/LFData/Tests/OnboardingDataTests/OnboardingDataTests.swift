import DataTestHelpers
import Foundation
import NetworkTestHelpers
import Nimble
import TestHelpers
import XCTest

@testable import OnboardingData

// Test cases for the OnboardingData module.
final class OnboardingDataTests: XCTestCase {
  
  var auth: MockAuthorizationManagerProtocol!
  var api: MockOnboardingAPIProtocol!
  var repository: OnboardingRepository!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the repository before each test. Inject mock objects into the repository
    auth = MockAuthorizationManagerProtocol()
    api = MockOnboardingAPIProtocol()
    repository = OnboardingRepository(onboardingAPI: api, auth: auth)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    auth = nil
    api = nil
    repository = nil
    
    super.tearDown()
  }
  
  // Test the login functionality under normal conditions.
  func test_login_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockResult = APIAccessTokens(accessToken: "mock_accesstoken", tokenType: "mock_tokenType", refreshToken: "mock_refreshToken", expiresIn: 123456789)
      let mockfailedResult = APIAccessTokens(accessToken: "", tokenType: "", refreshToken: "", expiresIn: 0)
      
      self.api.loginPhoneNumberOtpCodeLastIDClosure = { phoneNumber, otpCode, lastID async throws -> APIAccessTokens in
        if phoneNumber == "123456789" && otpCode == "1234" {
          return mockResult
        }
        return mockfailedResult
      }
      // When calling login function on the repository with parameters which should return an access token successfully
      let result = try await self.repository.login(phoneNumber: "123456789", otpCode: "1234", lastID: "0000")
      // Then the token received is the one we expected
      expect(result.accessToken).to(equal(mockResult.accessToken))
      // And the repository successfully passes the token to Auth manager when token refresh is needed
      expect(self.auth.refreshWithApiTokenReceivedApiToken?.accessToken).to(equal(mockResult.accessToken))
    }
  }
  
  // Test the login functionality when it encounters an error.
  func test_login_failed_case() async {
    do {
      // Given the expected mock success and fail results
      let mockResult = APIAccessTokens(accessToken: "mock_accesstoken", tokenType: "mock_tokenType", refreshToken: "mock_refreshToken", expiresIn: 123456789)
      let mockfailedResult = APIAccessTokens(accessToken: "", tokenType: "", refreshToken: "", expiresIn: 0)
      
      self.api.loginPhoneNumberOtpCodeLastIDClosure = { phoneNumber, otpCode, lastID async throws -> APIAccessTokens in
        if phoneNumber == "123456789" && otpCode == "1234" {
          return mockResult
        }
        // And expected description of the error which will be thrown
        self.api.loginPhoneNumberOtpCodeLastIDThrowableError = "User entere a wrong phone number or OTP"
        return mockfailedResult
      }
      // When calling login function on the repository with parameters which should throw an error
      _ = try await self.repository.login(phoneNumber: "0123456789", otpCode: "", lastID: "0000")
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.api.loginPhoneNumberOtpCodeLastIDThrowableError?.localizedDescription).to(equal(error.localizedDescription))
    }
  }
  
  // Test the functionality of OTP request under expected conditions.
  func test_request_otp_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockResult = APIOtp(requiredAuth: ["mock_requiredAuth_1", "mock_requiredAuth_2"])
      let mockfailedResult = APIOtp(requiredAuth: [])
      self.api.requestOTPPhoneNumberClosure = { phoneNumber async throws -> APIOtp in
        if phoneNumber == "123456789" {
          return mockResult
        }
        return mockfailedResult
      }
      // When calling request OTP function with parameters which should return requiredAuth successfully
      let result = try await self.repository.requestOTP(phoneNumber: "123456789")
      // Then the requiredAuth received matches our expectation
      expect(result.requiredAuth).to(equal(mockResult.requiredAuth))
    }
  }
  
  // Test the OTP request functionality when it encounters an error.
  func test_request_otp_failed_case() async {
    do {
      // Given the expected mock success and fail results
      let mockResult = APIOtp(requiredAuth: ["mock_requiredAuth_1", "mock_requiredAuth_2"])
      let mockfailedResult = APIOtp(requiredAuth: [])
      
      self.api.requestOTPPhoneNumberClosure = { phoneNumber async throws -> APIOtp in
        if phoneNumber == "123456789" {
          return mockResult
        }
        // And expected description of the error which will be thrown
        self.api.requestOTPPhoneNumberThrowableError = "The phone number is invalid"
        return mockfailedResult
      }
      // When calling request OTP function on the repository with parameters which should throw an error
      _ = try await self.repository.requestOTP(phoneNumber: "012345678900")
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.api.requestOTPPhoneNumberThrowableError?.localizedDescription).to(equal(error.localizedDescription))
    }
  }
  
  // Test retrieving the onboarding state under normal conditions.
  func test_get_onboarding_state_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockResult = APIOnboardingState(missingSteps: ["mock_missingSteps_1", "mock_missingSteps_2"])
      let mockfailedResult = APIOnboardingState(missingSteps: [""])
      // And a random pre-set sessionID
      let sessionID = UUID().uuidString
      self.api.getOnboardingStateSessionIdClosure = { sessionId async throws -> APIOnboardingState in
        if sessionId == sessionID {
          return mockResult
        }
        
        return mockfailedResult
      }
      // When calling onboardingState function with parameter which should return missingSteps successfully
      let result = try await self.repository.onboardingState(sessionId: sessionID)
      // Then the missingSteps received are the ones we expected
      expect(result.missingSteps).to(equal(mockResult.missingSteps))
    }
  }
  
  // Test retrieving the onboarding state when an error condition is encountered.
  func test_get_onboarding_state_failed_case() async {
    do {
      // Given the expected mock success and fail results
      let mockResult = APIOnboardingState(missingSteps: ["mock_missingSteps_1", "mock_missingSteps_2"])
      let mockfailedResult = APIOnboardingState(missingSteps: [""])
      // And a random pre-set sessionID
      let sessionID = UUID().uuidString
      self.api.getOnboardingStateSessionIdClosure = { sessionId async throws -> APIOnboardingState in
        if sessionId == sessionID {
          return mockResult
        }
        // And expected description of the error which will be thrown if a wrong sessionID is passed
        self.api.getOnboardingStateSessionIdThrowableError = "The session ID is invalid"
        return mockfailedResult
      }
      // When calling onboardingState function on the repository with parameter which should throw an error
      _ = try await self.repository.onboardingState(sessionId: UUID().uuidString)
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.api.getOnboardingStateSessionIdThrowableError?.localizedDescription).to(equal(error.localizedDescription))
    }
  }
}
