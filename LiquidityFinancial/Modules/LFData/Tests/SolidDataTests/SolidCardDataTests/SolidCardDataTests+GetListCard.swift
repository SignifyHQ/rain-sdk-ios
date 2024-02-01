import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import SolidDomain
import XCTest
import Nimble

@testable import SolidData

// MARK: - GetListCard Tests
extension SolidCardDataTests {
  /// Test  getListCard functionality under normal conditions
  func test_getListCard_shouldReturnSuccessResponse() async {
    // Given a mock success response will be return
    self.api.getListCardIsContainClosedCardReturnValue = mockListCardResponse
    
    // When calling getListCard function on the repository and it should return a success response
    await expect {
      let response = try await self.repository.getListCard(isContainClosedCard: false)
      return response.first?.id
    }
    /* Then the first element in the response received from repository
      should contain the first element's id of mock success response
     */
    .to(equal(mockListCardResponse.first?.id))
  }
  
  /// Test getListCard functionality when it encounters an API error
  func test_getListCard_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.getListCardIsContainClosedCardThrowableError = expectedThrowableError
    
    // When calling getListCard function on the repository and it throws an error
    await expect {
      try await self.repository.getListCard(isContainClosedCard: false)
    }
    // Then an error should be thrown
    .to(
      throwError { error in
        // And the error should be 'mock_api_error'
        expect(error).to(equal(self.expectedThrowableError))
      }
    )
  }
}
