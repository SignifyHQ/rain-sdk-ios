import DataTestHelpers
import Foundation
import NetworkTestHelpers
import Nimble
import TestHelpers
import XCTest

@testable import SolidData

// Test cases for the SolidData Module.
final class SolidExternalFundingDataTests: XCTestCase {
  
  var api: MockSolidExternalFundingAPIProtocol!
  var repository: SolidExternalFundingRepository!
  
  override func setUp() {
    super.setUp()
    api = MockSolidExternalFundingAPIProtocol()
    repository = SolidExternalFundingRepository(solidExternalFundingAPI: api)
  }
  
  override func tearDown() {
    api = nil
    repository = nil
    
    super.tearDown()
  }
}

// MARK: - Create PlaidToken Tests
extension SolidExternalFundingDataTests {
  // Test the createPlaidToken functionality under normal conditions.
  func test_createPlaidToken_happy_case() async {
    // Given the expected mock success
    let mockSuccessResult = APICreatePlaidTokenResponse(linkToken: "mock_link_token")
    let accountIdSuccess = "mock_account_id"
    self.api.createPlaidTokenAccountIdReturnValue = mockSuccessResult
    // When calling createPlaidToken function on the repository should return an value successfully
    await expect {
      try await self.repository.createPlaidToken(accountID: accountIdSuccess).linkToken
    }
    // Then the repository will returns the same result as the api
    .to(equal(mockSuccessResult.linkToken))
  }
  
  // Test the createPlaidToken functionality when it encounters an error.
  func test_createPlaidToken_failed_case_throw() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.createPlaidTokenAccountIdThrowableError = expectedError
    // When calling createPlaidToken function on the repository should throw an error as the same
    await expect {
      try await self.repository.createPlaidToken(accountID: "")
    }
    // Then the description of the caught error is the one we expected
    .to(throwError(closure: { error in
      expect(expectedError).to(equal(error))
    }))
  }
}

// MARK: - PlaidLink Tests
extension SolidExternalFundingDataTests {
  // Test the plaid link functionality under normal conditions.
  func test_plaid_link_happy_case() async {
    // Given the expected mock success and fail results
    let mockSuccessResult = MockAPISolidContact.mockSuccessData
    self.api.plaidLinkAccountIdTokenPlaidAccountIdReturnValue = mockSuccessResult
    // When calling plaid link function on the usecase with parameters which should return an value successfully
    await expect {
      try await self.repository.linkPlaid(accountId: "", token: "mock_token", plaidAccountId: "").last4
    }
    // Then the repository will returns the same result as the api
    .to(equal(mockSuccessResult.last4))
  }
  
  // Test the plaid link functionality when it encounters an error.
  func test_plaid_link_failed_case_throw() async {
    // Given a mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.plaidLinkAccountIdTokenPlaidAccountIdThrowableError = expectedError
    // When calling plaid link function on the repository should throw an error as the same
    await expect {
      try await self.repository.linkPlaid(accountId: "", token: "", plaidAccountId: "")
    }
    // Then the description of the caught error is the one we expected
    .to(throwError(closure: { error in
      expect(expectedError).to(equal(error))
    }))
  }
}

// MARK: - Create DebitCardToken Tests
extension SolidExternalFundingDataTests {
  /// Test the createDebitCardToken functionality under normal conditions.
  func test_createDebitCardToken_happy_case() async {
    // Given: The expected mock success
    let mockSuccessResult = APISolidDebitCardToken(
      linkToken: "mock_link_token",
      solidContactId: "mock_solid_contact_id"
    )
    let accountIDSuccess = "mock_account_id"
    
    self.api.createDebitCardTokenAccountIDReturnValue = mockSuccessResult
    
    // When: Calling createDebitCardToken function on the repository should return an value successfully
    await expect {
      try await self.repository
        .createDebitCardToken(accountID: accountIDSuccess)
        .linkToken
    }
    // Then: The repository will returns the same result as the api
    .to(equal(mockSuccessResult.linkToken))
    
    // And verify the input parameter should be correctly
    expect(self.api.createDebitCardTokenAccountIDReceivedAccountID).to(equal(accountIDSuccess))
  }
  
  /// Test the createDebitCardToken functionality when it encounters an error.
  func test_createDebitCardToken_failed_case_throw() async {
    // Given: A mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.createDebitCardTokenAccountIDThrowableError = expectedError
    
    // When: Calling login function on the repository with parameters which should throw an error
    await expect {
      try await self.repository.createDebitCardToken(accountID: "").linkToken
    }
    .to(throwError { error in
      // Then: The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }

}

// MARK: - Create GetContacts Tests
extension SolidExternalFundingDataTests {
  /// Test the getLinkedSources  functionality under normal conditions.
  func test_getLinkedSources_happy_case() async {
    // Given: The expected mock success
    let mockSuccessResult = MockAPISolidContact.mockSuccessData
    let accountIDSuccess = "mock_account_id"
    
    self.api.getLinkedSourcesAccountIdReturnValue = [mockSuccessResult]
    
    // When: Calling getLinkedSources function on the repository should return an value successfully
    await expect {
      try await self.repository
        .getLinkedSources(accountID: accountIDSuccess).first?.solidContactId
    }
    // Then: The repository will returns the same result as the api
    .to(equal(mockSuccessResult.solidContactId))
  }
  
  /// Test the getLinkedSources functionality when it encounters an error.
  func test_getLinkedSource_failed_case_throw() async {
    // Given: A mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.getLinkedSourcesAccountIdThrowableError = expectedError
    
    // When: Calling login function on the repository with parameters which should throw an error
    await expect {
      try await self.repository.getLinkedSources(accountID: "")
    }
    .to(throwError { error in
      // Then: The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }

}

// MARK: - Create unlinkContact Tests
extension SolidExternalFundingDataTests {
  /// Test the unlinkContact  functionality under normal conditions.
  func test_unlinkContact_happy_case() async {
    // Given: The expected mock success
    let mockSuccessResult = APISolidUnlinkContactResponse(success: true)
    let accountIDSuccess = "mock_account_id"
    
    self.api.unlinkContactIdReturnValue = mockSuccessResult
    
    // When: Calling unlinkContact function on the repository should return an value successfully
    await expect {
      try await self.repository.unlinkContact(id: accountIDSuccess).success
    }
    // Then: The repository will returns the same result as the api
    .to(equal(true))
  }
  
  /// Test the unlinkContact functionality when it encounters an error.
  func test_unlinkContact_failed_case_throw() async {
    // Given: A mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.unlinkContactIdThrowableError = expectedError
    
    // When: Calling login function on the repository with parameters which should throw an error
    await expect {
      try await self.repository.unlinkContact(id: "")
    }
    .to(throwError { error in
      // Then: The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }

}

// MARK: - Create getWireTransfers Tests
extension SolidExternalFundingDataTests {
  /// Test the getWireTransfers  functionality under normal conditions.
  func test_getWireTransfers_happy_case() async {
    // Given: The expected mock success
    let mockSuccessResult = APISolidWireTransferResponse(accountNumber: "mock_account", routingNumber: "mock_routing")
    let accountIDSuccess = "mock_account_id"
    
    self.api.getWireTransferAccountIdReturnValue = mockSuccessResult
    
    // When: Calling getWireTransfers function on the repository should return an value successfully
    await expect {
      try await self.repository.getWireTransfer(accountId: accountIDSuccess).accountNumber
    }
    // Then: The repository will returns the same result as the api
    .to(equal(mockSuccessResult.accountNumber))
  }
  
  /// Test the getWireTransfers functionality when it encounters an error.
  func test_getWireTransfers_failed_case_throw() async {
    // Given: A mock error which will be thrown
    let expectedError = TestError.fail("mock_error")
    self.api.getWireTransferAccountIdThrowableError = expectedError
    
    // When: Calling login function on the repository with parameters which should throw an error
    await expect {
      try await self.repository.getWireTransfer(accountId: "")
    }
    .to(throwError { error in
      // Then: The error is the one we expected
      expect(expectedError).to(equal(error))
    })
  }

}
