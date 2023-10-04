import XCTest
import AuthorizationManager
import TestHelpers

@testable import OnboardingData

final class OnboardingRepositoryTests: XCTestCase {
  
  var repository: OnboardingRepository!
  var mockAPI: OnboardingAPIProtocolMock!
  var authMock: AuthorizationManagerProtocolMock!
  
  override func setUp() {
    super.setUp()
    //Setup method called before the invocation of each test method in the class
    mockAPI = OnboardingAPIProtocolMock()
    authMock = AuthorizationManagerProtocolMock()
    repository = OnboardingRepository(onboardingAPI: mockAPI, auth: authMock)
  }
  
  override func tearDown() {
    super.tearDown()
    //Teardown method called after the invocation of each test method in the class
    //We can clear some thing if need
  }
  
  func test_requestOTP() {
    runAsyncTest {
      let mockResult = APIOtp(requiredAuth: ["mock_data_test_OTP"])
      self.mockAPI.requestOTPPhoneNumberReturnValue = mockResult
      let result = try await self.repository.requestOTP(phoneNumber:"")
      XCTAssertEqual(result.requiredAuth, mockResult.requiredAuth)
    }
  }
}
