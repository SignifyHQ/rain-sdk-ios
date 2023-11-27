import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import NetspendDomain
import Foundation
import Nimble
import XCTest

@testable import NetSpendData

// MARK: - SetPin Tests
extension NSCardDataTests {
  /// Test  setPin functionality under normal conditions
  func test_setPin_shouldReturnSuccessResponse() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling setPin function on the repository and it should return a success response
    await expect {
      try await self.repository.setPin(
        requestParam: self.mockSetPin,
        cardID: self.mockExistCardID,
        sessionID: self.mockValidNetSpendSessionID
      ).liquidityCardId
    }
    // Then the id received matches our expectation
    .to(equal(mockCardResponse.liquidityCardId))
  }
  
  /// Test setPin  functionality when it encounters an API error
  func test_setPin_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.setPinRequestParamCardIDSessionIDThrowableError = expectedThrowableError
    
    // When calling setPin function on the repository
    await expect {
      try await self.repository.setPin(
        requestParam: self.mockSetPin,
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
  
  /// Test setPin functionality with invalid netspendSessionID when it encounters an API error
  func test_setPin_withInvalidNetSpendSessionID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling setPin function on the repository
    await expect {
      try await self.repository.setPin(
        requestParam: self.mockSetPin,
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
  
  /// Test setPin functionality with not exist CardID when it encounters an API error
  func test_setPin_withNotExistCardID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling setPin function on the repository
    await expect {
      try await self.repository.setPin(
        requestParam: self.mockSetPin,
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
}

// MARK: - Helpers Function
private extension NSCardDataTests {
  /// Function to configure the API behaviour which should be consistent across all tests
  func configureAPIBehaviour() {
    api.setPinRequestParamCardIDSessionIDClosure = { parameter, cardID, netspendSessionID async throws in
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
        return self.mockCardResponse
      }
    }
  }
}
