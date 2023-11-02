import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import SolidDomain
import XCTest
import Nimble

@testable import SolidData

// MARK: - UpdateCardStatus Tests
extension SolidCardDataTests {
  /// Test  updateCardStatus  functionality under normal conditions
  func test_updateCardStatus_shouldReturnSuccessResponse() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling updateCardStatus function on the repository and it should return a success response
    await expect {
      try await self.repository.updateCardStatus(
        cardID: self.mockExistCardID,
        parameters: self.mockCardStatusParameter
      ).cardStatus
    }
    // Then the status received matches our expectation
    .to(equal(mockCardResponse.cardStatus))
  }
  
  /// Test updateCardStatus functionality when it encounters an API error
  func test_updateCardStatus_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.updateCardStatusCardIDParametersThrowableError = expectedThrowableError
    
    // When calling updateCardStatus function on the repository
    await expect {
      try await self.repository.updateCardStatus(
        cardID: self.mockExistCardID,
        parameters: self.mockCardStatusParameter
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
  
  /// Test updateCardStatus functionality with not exist CardID when it encounters an API error
  func test_updateCardStatus_withNotExistCardID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // When calling updateCardStatus function on the repository
    await expect {
      try await self.repository.updateCardStatus(
        cardID: self.mockNotExistCardID,
        parameters: self.mockCardStatusParameter
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
private extension SolidCardDataTests {
  /// Function to configure the API behaviour which should be consistent across all tests
  func configureAPIBehaviour() {
    api.updateCardStatusCardIDParametersClosure = { cardID, parameters async throws in
      
      if self.mockExistCardID.contains(cardID) {
        // Return a success mock response
        return self.mockCardResponse
      } else {
        // Throw 'mock_card_notFound_error' if the cardID is empty or cardID is not exist in database
        throw self.mockCardNotFoundError
      }
    }
  }
}
