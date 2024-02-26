import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import SolidDomain
import XCTest
import Nimble

@testable import SolidData

// MARK: - CreateVirtualCard Tests
extension SolidCardDataTests {
  /// Test  createVirtualCard  functionality under normal conditions
  func test_createVirtualCard_shouldReturnSuccessResponse() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling createVirtualCard function on the repository and it should return a success response
    await expect {
      try await self.repository.createVirtualCard(
        accountID: self.mockExistAccountID,
        parameters: self.mockCreateVirtualCardParameters
      ).id
    }
    // Then the status received matches our expectation
    .to(equal(self.mockCardResponse.id))
  }
  
  /// Test createVirtualCard functionality when it encounters an API error
  func test_createVirtualCard_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.createVirtualCardAccountIDParametersThrowableError = expectedThrowableError
    
    // When calling createVirtualCard function on the repository
    await expect {
      try await self.repository.createVirtualCard(
        accountID: self.mockExistAccountID,
        parameters: self.mockCreateVirtualCardParameters
      )
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_api_error'
        expect(error).to(equal(self.expectedThrowableError))
      }
    )
  }
  
  /// Test createVirtualCard functionality with not exist accountID when it encounters an API error
  func test_createVirtualCard_withNotExistAccountID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // When calling createVirtualCard function on the repository
    await expect {
      try await self.repository.createVirtualCard(
        accountID: self.mockNotExistAccountID,
        parameters: self.mockCreateVirtualCardParameters
      )
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_account_notFound_error'
        expect(error).to(equal(self.mockAccountNotFoundError))
      }
    )
  }
}

// MARK: - Helpers Function
private extension SolidCardDataTests {
  /// Function to configure the API behaviour which should be consistent across all tests
  func configureAPIBehaviour() {
    api.createVirtualCardAccountIDParametersClosure = { accountID, _ async throws in
      
      if self.mockExistAccountIDs.contains(accountID) {
        // Return a success mock response
        return self.mockCardResponse
      } else {
        // Throw 'mock_account_notFound_error' if the accountID is empty or accountID is not exist in database
        throw self.mockAccountNotFoundError
      }
    }
  }
}
