import CoreNetwork
import XCTest
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import SolidDomain

@testable import SolidData

final class SolidCardDataTests: XCTestCase {
  
  var api: MockSolidCardAPIProtocol!
  var repository: SolidCardRepository!
  
  // Defining mock parameters
  let mockExistCardIDs = ["mock_cardID_1", "mock_cardID_2"]
  let mockExistCardID = "mock_cardID_1"
  let mockNotExistCardID = "mock_cardID_4"
  let mockCardStatusParameter = APISolidCardStatusParameters(cardStatus: "mock_status")
  
  // Defining mock success response
  let mockCardResponse = APISolidCard(
    id: "mock_id",
    expirationMonth: "10",
    expirationYear: "2024",
    panLast4: "mock_panLast4",
    type: "mock_type",
    cardStatus: "mock_status",
    createdAt: "mock_createAt"
  )
  
  let mockListCardResponse = [
    APISolidCard(
      id: "mock_id",
      expirationMonth: "10",
      expirationYear: "2024",
      panLast4: "mock_panLast4",
      type: "mock_type",
      cardStatus: "mock_status",
      createdAt: "mock_createAt"
    )
  ]
  
  // Defining mock API errors
  let expectedThrowableError = TestError.fail("mock_api_error")
  let mockCardNotFoundError = TestError.fail("mock_card_notFound_error")
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the repository before each test. Inject mock objects into the repository
    api = MockSolidCardAPIProtocol()
    repository = SolidCardRepository(cardAPI: api)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    api = nil
    repository = nil
    
    super.tearDown()
  }
}
