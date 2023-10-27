import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import NetspendDomain
import Foundation
import Nimble
import XCTest

@testable import NetSpendData

// MARK: - GetApplePayToken Tests
extension NSCardDataTests {
  /// Test  getApplePayToken  functionality under normal conditions
  func test_getApplePayToken_shouldReturnSuccessResponse() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling getApplePayToken function on the repository and it should return a success response
    await expect {
      try await self.repository.getApplePayToken(
        sessionId: self.mockValidNetSpendSessionID,
        cardId: self.mockExistCardID
      ).tokenEntities.first?.cardId
    }
    // Then the cardId received matches our expectation
    .to(equal(mockGetApplePayTokenResponse.tokens.first?.cardId))
  }
  
  /// Test getApplePayToken functionality when it encounters an API error
  func test_getApplePayToken_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.getApplePayTokenSessionIdCardIdThrowableError = expectedThrowableError
    
    // When calling getApplePayToken function on the repository
    await expect {
      try await self.repository.getApplePayToken(
        sessionId: self.mockValidNetSpendSessionID,
        cardId: self.mockExistCardID
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
  
  /// Test getApplePayToken functionality with invalid netspendSessionID when it encounters an API error
  func test_getApplePayToken_withInvalidNetSpendSessionID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling getApplePayToken function on the repository
    await expect {
      try await self.repository.getApplePayToken(
        sessionId: self.mockInvalidNetSpendSessionID,
        cardId: self.mockExistCardID
      )
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_invalid_netspendSession_error'
        expect(error).to(equal(self.mockInvalidNetSpendSessionError))
      }
    )
  }
  
  /// Test getApplePayToken functionality with not exist CardID when it encounters an API error
  func test_getApplePayToken_withNotExistCardID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling getApplePayToken function on the repository
    await expect {
      try await self.repository.getApplePayToken(
        sessionId: self.mockValidNetSpendSessionID,
        cardId: self.mockNotExistCardID
      )
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_card_notFound_error'
        expect(error).to(equal(self.mockCardNotFoundError))
      }
    )
  }
}

// MARK: - Helpers Function
private extension NSCardDataTests {
  /// Function to configure the API behaviour which should be consistent across all tests
  func configureAPIBehaviour() {
    api.getApplePayTokenSessionIdCardIdClosure = { netspendSessionID, cardID async throws in
      let isValidNetSpendSessionID = netspendSessionID == self.mockValidNetSpendSessionID
      let isFoundCardID = self.mockExistCardID.contains(cardID)
      
      switch (isValidNetSpendSessionID, isFoundCardID) {
        // Throw 'mock_invalid_netspendSession_error' if the sessionID is empty or sessionID is invalid
      case (false, _):
        throw self.mockInvalidNetSpendSessionError
        // Throw 'mock_card_notFound_error' if the cardID is empty or cardID is not exist in database
      case (_, false):
        throw self.mockCardNotFoundError
        // Return a success mock response
      default:
        return self.mockGetApplePayTokenResponse
      }
    }
  }
}
