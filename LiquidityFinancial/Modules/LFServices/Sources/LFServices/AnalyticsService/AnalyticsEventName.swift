import Foundation

//swiftlint:disable all
// MARK: - LogType
public enum LogType: String {
  case navigation
  case analytics
  case user
  case http
}

// MARK: - EventType
public protocol EventType {
  var name: String { get }
  var params: [String: Any] { get }
}

public struct AnalyticsEvent: EventType {
  public let name: String
  public let params: [String: Any]
  
  public init(name: String, params: [String: Any] = [:]) {
    self.name = name
    self.params = params
  }
  
  public init(name: AnalyticsEventName, params: [String: Any] = [:]) {
    self.name = name.rawValue
    self.params = params
  }
}

  // MARK: - EventName

public enum AnalyticsEventName: String {
    // *** AO Screens
  case appLaunch = "app launch"
  case viewSignUpLogin = "viewed signup login"
  case signedUp = "signed up"
  case phoneVerified = "phone verified"
  case phoneVerificationError = "phone verification error"
  case viewedPersonalInfo = "viewed personal info"
  case personalInfoCompleted = "personal info completed"
  case viewedAddress = "viewed address"
  case rewardTermsAccepted = "reward terms accepted"
  case rewardTermsViewed = "reward terms viewed"
  case rewardTermsClosed = "reward terms closed"
  case addressCompleted = "address completed"
  case viewedSSN = "viewed SSN"
  case ssnCompleted = "SSN completed"
  case kycStatusViewPass = "kyc status view pass"
  case idVerificationStart = "ID verification start"
  case idVerificationFail = "ID verification fail"
  case idVerificationSuccess = "ID verification success"
  case kycNeedsMoreInfo = "kyc needs more info"
  case viewsWalletSetup = "views wallet setup"
  case walletSetupSuccess = "wallet setup success"
  
  case loggedIn = "logged in"
  case loggedOut = "logout"
  case deleteAccount = "deleted account"
  case viewedHome = "viewed home"
  case viewCryptoWalletSetup = "views crypto wallet setup"
  case viewsShortcuts = "views shortcuts"
  case accountBalance = "account balance"
  
  case inboundTransferInitiated = "inbound transfer initiated"
  case inboundTransferSuccess = "inbound transfer success"
  case inbountTransferError = "Inbount transfer error"
  case outboundTransferInitiated = "outbound transfer initiated"
  case outboundTransferSuccess = "outbound transfer success"
  case conditionalReviewPrompt = "conditionally review prompted"
  
  case bankAccountConnectFail = "bank account connect fail"
  case bankAccountConnectSuccess = "bank account connect success"
  case bankAccountConnectStart = "bank account connect start"
  
  case viewsAddDebitCardScreen = "views add debit card screen"
  case debitCardConnectionSuccess = "debit card connection success"
  case debitCardFail = "debit card fail"
  
  case viewsDirectDepositReady = "views direct deposit ready"
  
  case createCardSuccess = "create card success"
  case createCardError = "create card error"
  
  case tapsBuyCrypto = "taps buy crypto"
  case tapsAmountBuyCrypto = "taps amount buy crypto"
  case tapsEnterCustomAmountBuyCrypto = "taps enter custom amount buy crypto"
  case tapsConfirmBuy = "taps confirm buy"
  case buyCryptoSuccess = "buy crypto success"
  case buyCryptoError = "buy crypto error"
  
  case tapsSellCrypto = "taps sell crypto"
  case tapsAmountSellCrypto = "taps amount sell crypto"
  case tapsEnterCustomAmountSellCrypto = "taps enter custom amount sell crypto"
  case tapsConfirmSell = "taps confirm sell"
  case sellCryptoSuccess = "sell crypto success"
  case sellCryptoError = "sell crypto error"
  
  case tapsTransferCrypto = "taps transfer crypto"
  case tapsSendCrypto = "taps send crypto"
  case tapsRecieveCrypto = "taps recieve crypto"
  case tapsSendToExternalWallet = "taps send to external wallet"
  case viewsWalletAddress = "views wallet address"
  case tapsCopyWalletAddress = "taps copy wallet address"
  case tapsShareWalletAddress = "taps share wallet address"
  
  case viewedTransactionList = "viewed transaction list"
  case viewedTransactionDetail = "viewed transaction detail"
  case tapsCryptoTransaction = "taps crypto transaction"
  
  case sendMoneySuccess = "send money success"
  case viewedAccounts = "viewed accounts"
  case viewsAccountAndRouting = "views account and routing #"
  
  case openDeals = "opened deals"
  
  case viewsWelcome = "views welcome"
  case viewsInviteFriends = "views invite friends"
  case tapsLockCard = "taps lock card"
  case tapsUnlockCard = "taps unlock card"
  case tapsConnectPlaid = "taps connect plaid"
  case openIntercom = "open intercom"
  case viewsSelectFundraiserCategories = "views select fundraiser categories"
  case selectedFundraiserSuccess = "selected fundraiser success"
  case viewsInReviewSSN = "views in review ssn"
  
  case selectedCashbackReward = "selected cashback reward"
  case selectedDonationReward = "selected donation reward"
  case selectedCryptoReward = "selected crypto reward"
  case selectedUnspecifiedReward = "selected unspecified reward"
  
  case viewsAddApplePay = "views add to apple pay"
  case tapsAddApplePay = "taps add to apple pay"
  case applePayConnectSuccess = "apple pay connect success"
  case applePayConnectError = "apple pay connect error"
  
  case viewsRoundUp = "views round up"
  case updatesRoundUp = "updates round up"
  case platform = "iOS"
}

  // MARK: - PropertiesName

public enum PropertiesName: String {
  case id
  case segmentOS = "os"
  case segmentName = "name"
  case cashBalance
  case cryptoBalance
  case appName
  case cardName
  case modeRun
  case lastUsedApp
  case phone
  case phoneVerified
  case personID
  case Name
  case Email
  case emailVerified
  case signupTimeStamp
  case cryptoCurrency
  case cards
  case CardanoCryptoBalance
  case DogeCryptoBalance
  case CardanoRewardsBalance
  case DogeRewardsBalance
}
