import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import SolidDomain
import XCTest
import Nimble

@testable import SolidData

// MARK: - CreateCardPinToken Tests
extension SolidCardDataTests {
  /// Test  createCardPinToken  functionality under normal conditions
  func test_createCardPinToken_shouldReturnSuccessResponse() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling createCardPinToken function on the repository and it should return a success response
    await expect {
      try await self.repository.createCardPinToken(cardID: self.mockExistCardID).solidCardId
    }
    // Then the status received matches our expectation
    .to(equal(self.mockCardPinTokenResponse.solidCardId))
  }
  
  /// Test createCardPinToken functionality when it encounters an API error
  func test_createCardPinToken_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.createCardPinTokenCardIDThrowableError = expectedThrowableError
    
    // When calling createCardPinToken function on the repository
    await expect {
      try await self.repository.createCardPinToken(cardID: self.mockExistCardID)

    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_api_error'
        expect(error).to(equal(self.expectedThrowableError))
      }
    )
  }
  
  /// Test createCardPinToken functionality with not exist CardID when it encounters an API error
  func test_createCardPinToken_withNotExistCardID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // When calling createCardPinToken function on the repository
    await expect {
      try await self.repository.createCardPinToken(cardID: self.mockNotExistCardID)
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
private extension SolidCardDataTests {
  /// Function to configure the API behaviour which should be consistent across all tests
  func configureAPIBehaviour() {
    api.createCardPinTokenCardIDClosure = { cardID async throws in
      
      if self.mockExistCardID.contains(cardID) {
        // Return a success mock response
        return self.mockCardPinTokenResponse
      } else {
        // Throw 'mock_card_notFound_error' if the cardID is empty or cardID is not exist in database
        throw self.mockCardNotFoundError
      }
    }
  }
}
