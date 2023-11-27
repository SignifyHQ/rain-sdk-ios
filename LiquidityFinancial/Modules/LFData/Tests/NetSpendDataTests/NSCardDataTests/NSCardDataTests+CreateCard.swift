import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import NetspendDomain
import Foundation
import Nimble
import XCTest

@testable import NetSpendData

// MARK: - CreateCard Tests
extension NSCardDataTests {
  /// Test  createCard  functionality under normal conditions
  func test_createCard_shouldReturnSuccessResponse() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling createCard function on the repository and it should return a success response
    await expect {
      try await self.repository.createCard(sessionID: self.mockValidNetSpendSessionID).liquidityCardId
    }
    // Then the id received matches our expectation
    .to(equal(mockCardResponse.liquidityCardId))
  }
  
  /// Test  createCard functionality when it encounters an API error
  func test_createCard_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.createCardSessionIDThrowableError = expectedThrowableError
    
    // When calling createCard function on the repository
    await expect {
      try await self.repository.createCard(sessionID: self.mockValidNetSpendSessionID)
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_api_error'
        expect(error).to(equal(self.expectedThrowableError))
      }
    )
  }
  
  /// Test  createCard functionality with invalid netspendSessionID when it encounters an API error
  func test_createCard_withInvalidNetSpendSessionID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling createCard function on the repository
    await expect {
      try await self.repository.createCard(sessionID: self.mockInvalidNetSpendSessionID)
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_invalid_netspendSession_error'
        expect(error).to(equal(self.mockInvalidNetSpendSessionError))
      }
    )
  }
}

// MARK: - Helpers Function
private extension NSCardDataTests {
  /// Function to configure the API behaviour which should be consistent across all tests
  func configureAPIBehaviour() {
    api.createCardSessionIDClosure = { netspendSessionID async throws in
      if netspendSessionID == self.mockValidNetSpendSessionID {
        return self.mockCardResponse
      }
      throw self.mockInvalidNetSpendSessionError
    }
  }
}
