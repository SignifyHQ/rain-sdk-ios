import CoreNetwork
import DataTestHelpers
import DevicesDomain
import Foundation
import Nimble
import XCTest

@testable import DevicesData

// Test cases for the DevicesData module.
final class DevicesDataTests: XCTestCase {
  
  var api: MockDevicesAPIProtocol!
  var repository: DevicesRepository!
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the repository before each test. Inject mock objects into the repository
    api = MockDevicesAPIProtocol()
    repository = DevicesRepository(devicesAPI: api)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    api = nil
    repository = nil
    
    super.tearDown()
  }
  
  // Test the register deviceID and token functionality under normal conditions.
  func test_register_happy_case() async {
    // Given the expected mock success and fail responses
    let mockSuccessResponse = NotificationTokenResponse(success: true)
    let mockFailResponse = NotificationTokenResponse(success: false)
    // And a randomly generated deviceID and a token
    let mockDeviceID = UUID().uuidString
    let mockToken = "mock_token"
    // And a mock API behaviour based on the mock input
    self.api.registerDeviceIdTokenClosure = { deviceID, token async throws -> NotificationTokenResponse in
      if deviceID == mockDeviceID, token == mockToken {
        return mockSuccessResponse
      }
      
      return mockFailResponse
    }
    // When calling register function on the repository with parameters which should return a success response
    await expect {
      try await self.repository.register(deviceId: mockDeviceID, token: mockToken).success
    }
    // Then the success field in the response received from repository should be equal to that in the mock success response
    .to(equal(mockSuccessResponse.success))
    // When calling register function on the repository with parameters which should return a fail response
    await expect {
      try await self.repository.register(deviceId: "", token: "").success
    }
    // Then the success field in the response received from repository should be equal to that in the mock fail response
    .to(equal(mockFailResponse.success))
  }
  
  // Test the register deviceID and token functionality when it encounters an API error.
  func test_register_api_failed_case() async {
    // Given the expected mock success and fail responses
    let mockSuccessResponse = NotificationTokenResponse(success: true)
    let mockFailResponse = NotificationTokenResponse(success: false)
    // And a randomly generated deviceID and token
    let mockDeviceID = UUID().uuidString
    let mockToken = "mock_token"
    // And a mock API behaviour based on the mock input
    self.api.registerDeviceIdTokenClosure = { deviceID, token async throws -> NotificationTokenResponse in
      if deviceID == mockDeviceID, token == mockToken {
        return mockSuccessResponse
      }
      
      return mockFailResponse
    }
    // And a mock error which will be thrown
    let mockError = LFNetworkError.custom(message: "mock_api_error")
    self.api.registerDeviceIdTokenThrowableError = mockError
    // When calling register function on the repository which should throw an error
    await expect {
      try await self.repository.register(deviceId: mockDeviceID, token: mockToken)
    }
    // Then it will throw an error
    .to(
      throwError(
        closure: { error in
          // And the the error caught here is the one we expected
          expect(error).to(equal(mockError))
        }
      )
    )
  }
  
  // Test the deregister deviceID and token functionality under normal conditions.
  func test_deregister_happy_case() async {
    // Given the expected mock success and fail responses
    let mockSuccessResponse = NotificationTokenResponse(success: true)
    let mockFailResponse = NotificationTokenResponse(success: false)
    // And a randomly generated deviceID and a token
    let mockDeviceID = UUID().uuidString
    let mockToken = "mock_token"
    // And a mock API behaviour based on the mock input
    self.api.deregisterDeviceIdTokenClosure = { deviceID, token async throws -> NotificationTokenResponse in
      if deviceID == mockDeviceID, token == mockToken {
        return mockSuccessResponse
      }
      
      return mockFailResponse
    }
    // When calling deregister function on the repository with parameters which should return a success response
    await expect {
      try await self.repository.deregister(deviceId: mockDeviceID, token: mockToken).success
    }
    // Then the success field in the response received from repository should be equal to that in the mock success response
    .to(equal(mockSuccessResponse.success))
    // When calling deregister function on the repository with parameters which should return a fail response
    await expect {
      try await self.repository.deregister(deviceId: "", token: "").success
    }
    // Then the success field in the response received from repository should be equal to that in the mock fail response
    .to(equal(mockFailResponse.success))
  }
  
  // Test the deregister deviceID and token functionality when it encounters an API error.
  func test_deregister_api_failed_case() async {
    // Given the expected mock success and fail responses
    let mockSuccessResponse = NotificationTokenResponse(success: true)
    let mockFailResponse = NotificationTokenResponse(success: false)
    // And a randomly generated deviceID and token
    let mockDeviceID = UUID().uuidString
    let mockToken = "mock_token"
    // And a mock API behaviour based on the mock input
    self.api.deregisterDeviceIdTokenClosure = { deviceID, token async throws -> NotificationTokenResponse in
      if deviceID == mockDeviceID, token == mockToken {
        return mockSuccessResponse
      }
      
      return mockFailResponse
    }
    // And a mock error which will be thrown
    let mockError = LFNetworkError.custom(message: "mock_api_error")
    self.api.deregisterDeviceIdTokenThrowableError = mockError
    // When calling deregister function on the repository which should throw an error
    await expecta(try await self.repository.deregister(deviceId: mockDeviceID, token: mockToken))
    // Then it will throw an error
      .to(
        throwError(
          closure: { error in
            // And the the error caught here is the one we expected
            expect(error).to(equal(mockError))
          }
        )
      )
  }
}
