import CoreNetwork
import DataTestHelpers
import TestHelpers
import NetworkTestHelpers
import NetspendDomain
import Foundation
import Nimble
import XCTest

@testable import NetSpendData

final class NSCardDataTests: XCTestCase {
  
  var api: MockNSCardAPIProtocol!
  var repository: NSCardRepository!
  
  // Defining mock parameters
  let mockValidNetSpendSessionID = "mock_valid_netspendSessionID"
  let mockInvalidNetSpendSessionID = "mock_invalid_netspendSessionID"
  let mockExistCardIDs = ["mock_cardID_1", "mock_cardID_2"]
  let mockExistCardID = "mock_cardID_1"
  let mockNotExistCardID = "mock_cardID_4"
  let mockSupportedCloseCardReasons = [CloseCardReasonParameters(reason: "mock_reason1")]
  let mockSupportedCloseCardReason = CloseCardReasonParameters(reason: "mock_reason1")
  let mockUnSupportedCloseCardReason = CloseCardReasonParameters(reason: "mock_reason2")

  let mockAddressOrderCard = AddressCardParameters(
    line1: "mock_line1",
    line2: "mock_line2",
    city: "mock_city",
    state: "mock_state",
    country: "mock_country",
    postalCode: "mock_postalCode"
  )
  let mockVerifyCode = VerifyCVVCodeParameters(
    verificationType: "mock_verificationType",
    encryptedData: "mock_encryptedData"
  )
  let mockSetPin = APISetPinRequest(verifyId: "mock_verifyId", encryptedData: "mock_encryptedData")
  let mockApplePayToken = [
    "certificates": "mock_certificates",
    "nonce": "mock_nonce",
    "nonceSignature": "mock_nonceSignature"
  ]

  // Defining mock success response
  let mockCardResponse = NSAPICard(
    netspendCardId: "mock_netspendCardId",
    liquidityCardId: "mock_liquidityCardId",
    expirationMonth: 10,
    expirationYear: 2024,
    panLast4: "mock_panLast4",
    encryptedData: nil,
    type: "mock_type",
    status: "mock_status",
    statusReason: "mock_statusReason",
    lockStatus: "mock_lockStatus",
    unlockTime: nil,
    shippingAddress: nil
  )
  let mockListCardResponse = [
    NSAPICard(
      netspendCardId: "mock_netspendCardId",
      liquidityCardId: "mock_liquidityCardId",
      expirationMonth: 10,
      expirationYear: 2024,
      panLast4: "mock_panLast4",
      encryptedData: nil,
      type: "mock_type",
      status: "mock_status",
      statusReason: "mock_statusReason",
      lockStatus: "mock_lockStatus",
      unlockTime: nil,
      shippingAddress: nil
    )
  ]
  let mockVerifyCVVCodeResponse = APIVerifyCVVCode(id: "mock_id")
  let mockGetApplePayTokenResponse = APIGetApplePayToken(
    tokens: [APIApplePayToken(
      cardId: "mock_cardId",
      walletProvider: "mock_walletProvider",
      panReferenceId: "mock_panReferenceId",
      tokenReferenceId: "mock_tokenReferenceId",
      tokenStatus: "mock_tokenStatus"
    )]
  )
  let mockPostApplePayTokenResponse = APIPostApplePayToken(
    activationData: "mock_activationData",
    ephemeralPublicKey: "mock_ephemeralPublicKey",
    encryptedCardData: "mock_encryptedCardData"
  )

  // Defining mock API errors
  let expectedThrowableError = TestError.fail("mock_api_error")
  let mockInvalidNetSpendSessionError = TestError.fail("mock_invalid_netspendSession_error")
  let mockCardNotFoundError = TestError.fail("mock_card_notFound_error")
  let mockUnSupportedCardCloseReasonError = TestError.fail("mock_unSupported_closeCardReason_error")
  
  override func setUp() {
    super.setUp()
    // Initialize mock objects and the repository before each test. Inject mock objects into the repository
    api = MockNSCardAPIProtocol()
    repository = NSCardRepository(cardAPI: api)
  }
  
  override func tearDown() {
    // Clean up any resources that don't need to persist.
    api = nil
    repository = nil
    
    super.tearDown()
  }
}
