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
  func test_login_happy_case() async {
    // Given the expected mock success and fail results
    let mockResult = APIAccessTokens(accessToken: "mock_accesstoken", tokenType: "mock_tokenType", refreshToken: "mock_refreshToken", expiresIn: 123456789)
    self.api.loginPhoneNumberOtpCodeLastIDReturnValue = mockResult
    
    // When calling login function on the repository with parameters which should return an access token successfully
    await expect {
      try await self.repository.login(phoneNumber: "123456789", otpCode: "1234", lastID: "0000").accessToken
    }
    .to(equal(mockResult.accessToken))
    
    // And the repository successfully passes the token to Auth manager when token refresh is needed
    expect(self.auth.refreshWithApiTokenReceivedApiToken?.accessToken).to(equal(mockResult.accessToken))
  }
  
  // Test the login functionality when it encounters an error.
  func test_login_failed_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.loginPhoneNumberOtpCodeLastIDThrowableError = expectedError
    
    // When calling login function on the repository with parameters which should throw an error
    await expect {
      try await self.repository.login(phoneNumber: "123456789", otpCode: "1234", lastID: "0000").accessToken
    }
    .to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
  
  // Test the functionality of OTP request under expected conditions.
  func test_request_otp_happy_case() async {
    // Given the expected mock success and fail results
    let mockSuccessResult = APIOtp(requiredAuth: ["mock_requiredAuth_1", "mock_requiredAuth_2"])
    let mockPhoneNumber = "123456789"
    self.api.requestOTPPhoneNumberReturnValue = mockSuccessResult
    
    await expect {
      // When calling request OTP function with parameters which should return requiredAuth successfully
      try await self.repository.requestOTP(phoneNumber: mockPhoneNumber).requiredAuth
    }
    // Then the requiredAuth received matches our expectation
    .to(equal(mockSuccessResult.requiredAuth))
    // And verify the input parameter should be correctly
    expect(self.api.requestOTPPhoneNumberReceivedPhoneNumber).to(equal(mockPhoneNumber))
  }
  
  // Test the OTP request functionality when it encounters an error.
  func test_request_otp_failed_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    // When calling request OTP function on the repository with parameters which should throw an error
    self.api.requestOTPPhoneNumberThrowableError = expectedError
    await expect {
      // When calling request OTP function with parameters which should return requiredAuth successfully
      try await self.repository.requestOTP(phoneNumber: "123456789")
    }.to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
  
  // Test retrieving the onboarding state under normal conditions.
  func test_get_onboarding_state_happy_case() async {
    // Given the expected mock success and fail results
    let mockSuccessResult = APIOnboardingState(missingSteps: ["mock_missingSteps_1", "mock_missingSteps_2"])
    self.api.getOnboardingStateSessionIdReturnValue = mockSuccessResult
    let sessionID = UUID().uuidString
    // When calling onboardingState function with parameter which should return missingSteps successfully
    await expect {
      try await self.repository.onboardingState(sessionId: sessionID).missingSteps
    }
    // Then the missingSteps received are the ones we expected
    .to(equal(mockSuccessResult.missingSteps))
    // And verify the input parameter should be correctly
    expect(self.api.getOnboardingStateSessionIdReceivedSessionId).to(equal(sessionID))
  }
  
  // Test retrieving the onboarding state when an error condition is encountered.
  func test_get_onboarding_state_failed_case() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    api.getOnboardingStateSessionIdThrowableError = expectedError
    // And a random pre-set sessionID
    let sessionID = UUID().uuidString
    await expect {
      // When calling onboardingState function on the repository with parameter which should throw an error
      try await self.repository.onboardingState(sessionId: sessionID).missingSteps
    }.to(throwError { error in
      // The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }
}
