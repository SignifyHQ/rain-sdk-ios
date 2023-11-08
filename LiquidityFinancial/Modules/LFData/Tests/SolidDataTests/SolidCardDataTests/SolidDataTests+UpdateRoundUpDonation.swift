import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import SolidDomain
import XCTest
import Nimble

@testable import SolidData

// MARK: - UpdateRoundUpDonation Tests
extension SolidCardDataTests {
  /// Test  updateRoundUpDonation  functionality under normal conditions
  func test_updateRoundUpDonation_shouldReturnSuccessResponse() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    
    // When calling updateRoundUpDonation function on the repository and it should return a success response
    await expect {
      try await self.repository.updateRoundUpDonation(
        cardID: self.mockExistCardID,
        parameters: self.mockRoundUpDonationParameter
      ).id
    }
    // Then the status received matches our expectation
    .to(equal(self.mockCardResponse.id))
  }
  
  /// Test updateRoundUpDonation functionality when it encounters an API error
  func test_updateRoundUpDonation_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.updateRoundUpDonationCardIDParametersThrowableError = expectedThrowableError
    
    // When calling updateRoundUpDonation function on the repository
    await expect {
      try await self.repository.updateRoundUpDonation(
        cardID: self.mockExistCardID,
        parameters: self.mockRoundUpDonationParameter
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
  
  /// Test updateRoundUpDonation functionality with not exist CardID when it encounters an API error
  func test_updateRoundUpDonation_withNotExistCardID_shouldThrowError() async {
    // Given the expected API behaviour
    configureAPIBehaviour()
    // When calling closeCard function on the repository
    await expect {
      try await self.repository.updateRoundUpDonation(
        cardID: self.mockNotExistCardID,
        parameters: self.mockRoundUpDonationParameter
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
    api.updateRoundUpDonationCardIDParametersClosure = { cardID, parammeters async throws in
      
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
