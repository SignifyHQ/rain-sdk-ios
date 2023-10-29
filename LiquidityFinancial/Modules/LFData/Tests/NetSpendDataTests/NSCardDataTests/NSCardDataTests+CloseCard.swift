import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import NetspendDomain
import Foundation
import Nimble
import XCTest

@testable import NetSpendData

// MARK: - CloseCard Tests
extension NSCardDataTests {
  /// Test  closeCard functionality under normal conditions
  func test_closeCard_shouldReturnSuccessResponse() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling closeCard function on the repository and it should return a success response
    await expect {
      try await self.repository.closeCard(
        reason: self.mockSupportedCloseCardReason,
        cardID: self.mockExistCardID,
        sessionID: self.mockValidNetSpendSessionID
      ).status
    }
    // Then the status received matches our expectation
    .to(equal(mockCardResponse.status))
  }
  
  /// Test closeCard functionality when it encounters an API error
  func test_closeCard_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.closeCardReasonCardIDSessionIDThrowableError = expectedThrowableError
    
    // When calling closeCard function on the repository
    await expect {
      try await self.repository.closeCard(
        reason: self.mockSupportedCloseCardReason,
        cardID: self.mockExistCardID,
        sessionID: self.mockValidNetSpendSessionID
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
  
  /// Test closeCard functionality with invalid netspendSessionID when it encounters an API error
  func test_closeCard_withInvalidNetSpendSessionID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling closeCard function on the repository
    await expect {
      try await self.repository.closeCard(
        reason: self.mockSupportedCloseCardReason,
        cardID: self.mockExistCardID,
        sessionID: self.mockInvalidNetSpendSessionID
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
  
  /// Test closeCard functionality with not exist CardID when it encounters an API error
  func test_closeCard_withNotExistCardID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling closeCard function on the repository
    await expect {
      try await self.repository.closeCard(
        reason: self.mockSupportedCloseCardReason,
        cardID: self.mockNotExistCardID,
        sessionID: self.mockValidNetSpendSessionID
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
  
  /// Test closeCard functionality with UnSupported CardCloseReason when it encounters an API error
  func test_closeCard_withUnSupportedCardCloseReason_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling closeCard function on the repository
    await expect {
      try await self.repository.closeCard(
        reason: self.mockUnSupportedCloseCardReason,
        cardID: self.mockNotExistCardID,
        sessionID: self.mockValidNetSpendSessionID
      )
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_unSupported_closeCardReason_error'
        expect(error).to(equal(self.mockUnSupportedCardCloseReasonError))
      }
    )
  }
}

// MARK: - Helpers Function
private extension NSCardDataTests {
  /// Function to configure the API behaviour which should be consistent across all tests
  func configureAPIBehaviour() {
    api.closeCardReasonCardIDSessionIDClosure = { parameter, cardID, netspendSessionID async throws in
      let isSupportedCloseCardReason = self.mockSupportedCloseCardReasons.contains(where: { $0.reason == parameter.reason })
      let isValidNetSpendSessionID = netspendSessionID == self.mockValidNetSpendSessionID
      let isFoundCardID = self.mockExistCardID.contains(cardID)
      
      switch (isSupportedCloseCardReason, isValidNetSpendSessionID, isFoundCardID) {
        // Throw 'mock_unSupported_closeCardReason_error' if reason is unsupported
      case (false, _, _):
        throw self.mockUnSupportedCardCloseReasonError
        // Throw 'mock_invalid_netspendSession_error' if the sessionID is empty or sessionID is invalid
      case (_, false, _):
        throw self.mockInvalidNetSpendSessionError
        // Throw 'mock_card_notFound_error' if the cardID is empty or cardID is not exist in database
      case (_, _, false):
        throw self.mockCardNotFoundError
        // Return a success mock response
      default:
        return self.mockCardResponse
      }
    }
  }
}
