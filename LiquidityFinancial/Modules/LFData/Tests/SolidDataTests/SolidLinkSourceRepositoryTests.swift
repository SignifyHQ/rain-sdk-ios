import DataTestHelpers
import Foundation
import NetworkTestHelpers
import Nimble
import TestHelpers
import XCTest

@testable import SolidData

// Test cases for the OnboardingData module.
final class SolidLinkSourceRepositoryTests: XCTestCase {
  
  var api: MockSolidAPIProtocol!
  var repository: SolidLinkSourceRepository!
  
  override func setUp() {
    super.setUp()
    api = MockSolidAPIProtocol()
    repository = SolidLinkSourceRepository(solidAPI: api)
  }
  
  override func tearDown() {
    api = nil
    repository = nil
    
    super.tearDown()
  }
  
  // Test the createPlaidToken functionality under normal conditions.
  func test_createPlaidToken_happy_case() {
    runAsyncTest {
      // Given the expected mock success
      let mockSuccessResult = APICreatePlaidTokenResponse(linkToken: "mock_link_token")
      let mockFailResult = APICreatePlaidTokenResponse(linkToken: "")
      let accountIdSuccess = "mock_account_id"
      self.api.createPlaidTokenAccountIdClosure = { accountId async throws -> APICreatePlaidTokenResponse in
        if accountId == accountIdSuccess {
          return mockSuccessResult
        }
        return mockFailResult
      }
      
      // When calling createPlaidToken function on the repository should return an value successfully
      let resultExpectUseCase = try await self.repository.createPlaidToken(accountID: accountIdSuccess)
      // Then the repository will returns the same result as the api
      expect(resultExpectUseCase.linkToken).to(equal(mockSuccessResult.linkToken))
    }
  }
  
  // Test the createPlaidToken functionality when it encounters an error.
  func test_createPlaidToken_failed_case_throw() async {
    do {
      // And expected description of the error which will be thrown
      self.api.createPlaidTokenAccountIdThrowableError = "Can't create a token"
      
      // When calling createPlaidToken function on the repository should throw an error as the same
      _ = try await self.repository.createPlaidToken(accountID: "")
      
    } catch {
      // Then the description of the caught error is the one we expected
      expect(self.api.createPlaidTokenAccountIdThrowableError?.localizedDescription).to(equal(error.localizedDescription))
    }
  }
  
  
  // Test the plaid link functionality under normal conditions.
  func test_plaid_link_happy_case() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockSuccessResult = MockSolidContact.mockSuccessData
      let mockFailResult = MockSolidContact.mockEmptyData
      
      self.api.plaidLinkAccountIdTokenPlaidAccountIdClosure = { accountId, token, plaidId in
        if token == "mock_token" {
          return mockSuccessResult
        }
        return mockFailResult
      }
      // When calling plaid link function on the usecase with parameters which should return an value successfully
      let resultExpectRepository = try await self.repository.linkPlaid(accountId: "", token: "mock_token", plaidAccountId: "")
      // Then the repository will returns the same result as the api
      expect(resultExpectRepository.last4).to(equal(mockSuccessResult.last4))
    }
  }
  
  // Test the plaid link functionality when it encounters an error.
  func test_plaid_link_failed_case_not_throw() {
    runAsyncTest {
      // Given the expected mock success and fail results
      let mockSuccessResult = MockSolidContact.mockSuccessData
      let mockFailResult = MockSolidContact.mockEmptyData
      
      self.api.plaidLinkAccountIdTokenPlaidAccountIdClosure = { accountId, token, plaidId in
        if token == "mock_token" {
          return mockSuccessResult
        }
        return mockFailResult
      }
      // When calling plaid link function on the usecase with parameters which should return an value successfully
      let resultExpectRepository = try await self.repository.linkPlaid(accountId: "", token: "", plaidAccountId: "")
      // Then the repository will returns the same result as the api
      expect(resultExpectRepository.last4).toNot(equal(mockSuccessResult.last4))
    }
  }
  
}
