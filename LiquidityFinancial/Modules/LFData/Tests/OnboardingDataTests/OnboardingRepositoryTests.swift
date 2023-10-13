import AuthorizationManager
import Mockingbird
import NetworkMocks
import OnboardingDataMocks
import TestHelpers
import XCTest

@testable import OnboardingData

final class OnboardingRepositoryTests: XCTestCase {
  
  var repository: OnboardingRepository!
  var mockAPI: OnboardingAPIProtocolMock!
  var authMock: AuthorizationManagerProtocolMock!
  
  override func setUp() {
    super.setUp()
    // Initializing mocks of OnboardingAPI and AuthorizationManager protocols
    mockAPI = mock(OnboardingAPIProtocol.self)
    authMock = mock(AuthorizationManagerProtocol.self)
    
    // Initializing OnboardingRepository instance and injecting mocks into it
    repository = OnboardingRepository(onboardingAPI: mockAPI, auth: authMock)
  }
  
  override func tearDown() {
    super.tearDown()
    //Teardown method called after the invocation of each test method in the class
    //We can clear some thing if need
  }
  
  // Note: This is a sample test just to verify Mockingbird integration
  func test_requestOTP() {
    runAsyncTest {
      // Given OnboardingAPI returns a certain requiredAuth data when requesting an OTP
      let mockResult = APIOtp(requiredAuth: ["mock_data_test_OTP"])
      await given(self.mockAPI.requestOTP(phoneNumber: "+380667312746")).willReturn(mockResult)
      
      // When request OTP function is called on repository
      let result = try await self.repository.requestOTP(phoneNumber:"+380667312746")
      
      // Then the repository should pass the data it received from OnboardingAPI to the caller
      XCTAssertEqual(result.requiredAuth, mockResult.requiredAuth)
    }
  }
}
