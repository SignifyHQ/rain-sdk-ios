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
  let mockExistAccountIDs = ["mock_accountID_1", "mock_accountID_2"]
  let mockExistAccountID = "mock_accountID_1"
  let mockExistCardID = "mock_cardID_1"
  let mockNotExistCardID = "mock_cardID_4"
  let mockNotExistAccountID = "mock_accountID_4"
  let mockCardStatusParameter = APISolidCardStatusParameters(cardStatus: "mock_status")
  let mockRoundUpDonationParameter = APISolidRoundUpDonationParameters(roundUpDonation: false)
  let mockActivePhysicalParameter = APISolidActiveCardParameters(
    expiryMonth: "mock_expiryMonth",
    expiryYear: "mock_expiryYear",
    last4: "mock_last4"
  )
  let mockApplePayWalletParameters = APISolidApplePayWalletParameters(
    deviceCert: "mock_deviceCert",
    nonceSignature: "mock_nonceSignature",
    nonce: "mock_nonce"
  )

  // Defining mock success response
  let mockCardResponse = APISolidCard(
    id: "mock_id",
    expirationMonth: "10",
    expirationYear: "2024",
    panLast4: "mock_panLast4",
    type: "mock_type",
    cardStatus: "mock_status",
    createdAt: "mock_createAt",
    isRoundUpDonationEnabled: true
  )
  let mockListCardResponse = [
    APISolidCard(
      id: "mock_id",
      expirationMonth: "10",
      expirationYear: "2024",
      panLast4: "mock_panLast4",
      type: "mock_type",
      cardStatus: "mock_status",
      createdAt: "mock_createAt",
      isRoundUpDonationEnabled: true
    )
  ]
  let mockShowTokenResponse = APISolidCardShowToken(solidCardId: "mock_id", showToken: "mock_showToken")
  let mockCardPinTokenResponse = APISolidCardPinToken(solidCardId: "mock_id", pinToken: "mock_cardPinToken")
  let mockDigitalWalletResponse = APISolidDigitalWallet(
    wallet: "mock_wallet",
    applePay: APISolidApplePay(
      paymentAccountReference: "mock_paymentAccountReference",
      activationData: "mock_activationData",
      encryptedPassData: "mock_encryptedPassData",
      ephemeralPublicKey: "mock_ephemeralPublicKey"
    )
  )
  
  // Defining mock API errors
  let expectedThrowableError = TestError.fail("mock_api_error")
  let mockCardNotFoundError = TestError.fail("mock_card_notFound_error")
  let mockAccountNotFoundError = TestError.fail("mock_account_notFound_error")

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
