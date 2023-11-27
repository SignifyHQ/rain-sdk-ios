import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import NetspendDomain
import Foundation
import Nimble
import XCTest

@testable import NetSpendData

// MARK: - GetListCard Tests
extension NSCardDataTests {
  /// Test  getListCard functionality under normal conditions
  func test_getListCard_shouldReturnSuccessResponse() async {
    // Given a mock success response will be return
    self.api.getListCardReturnValue = mockListCardResponse
    
    // When calling getListCard function on the repository and it should return a success response
    await expect {
      let response = try await self.repository.getListCard()
      return response.first?.liquidityCardId
    }
    /* Then the first element in the response received from repository
      should contain the first element's id of mock success response
     */
    .to(equal(mockListCardResponse.first?.liquidityCardId))
  }
  
  /// Test getListCard functionality when it encounters an API error
  func test_getListCard_shouldThrowError() async {
    // Given a mock error which will be thrown
    self.api.getListCardThrowableError = expectedThrowableError
    
    // When calling getListCard function on the repository and it throws an error
    await expect {
      try await self.repository.getListCard()
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
