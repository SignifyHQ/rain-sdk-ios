import Foundation
import LFLocalizable

  // MARK: - MaxCharacterLimit
public enum Constants {
  public enum MaxCharacterLimit: Int {
    case email
    case address
    case city
    case state
    case zipcode
    case nameLimit
    case phoneNumber
    case password
    case verificationLimit
    case ssnLength
    case passportLength
    case fullSSNLength
    case cardLength
    case cardLast4Length
    case cardExpiryLength
    case cardExpiryMonthLength
    case cardExpiryYearLength
    case amountLimit
    case cryptoLimit
    case cvv
    case fullPassportLength
    case cvvCode
    case cardPinCode
    case backupPinCode
    case otpCode
    case mfaCode
    case recoveryCode
    case any
    
    public var value: Int {
      switch self {
      case .email:
        return 40
      case .address:
        return 50
      case .city:
        return 25
      case .state:
        return 25
      case .zipcode:
        return 15
      case .nameLimit:
        return 20
      case .phoneNumber:
        return 14
      case .password:
        return 50
      case .verificationLimit:
        return 6
      case .ssnLength:
        return 4
      case .passportLength:
        return 5
      case .fullSSNLength:
        return 9
      case .cardLength:
        return 19
      case .cardLast4Length:
        return 4
      case .cardExpiryLength:
        return 5 // ...MM/YY
      case .cardExpiryMonthLength:
        return 2
      case .cardExpiryYearLength:
        return 4
      case .amountLimit:
        return 6 // main 5 + comma, $, decimal point and 2 decimal values
      case .cryptoLimit:
        return 16
      case .cvv:
        return 4
      case .fullPassportLength:
        return 20
      case .cvvCode:
        return 3
      case .backupPinCode:
        return 4
      case .cardPinCode:
        return 4
      case .otpCode:
        return 6
      case .mfaCode:
        return 6
      case .recoveryCode:
        return 50
      case .any:
        return 200
      }
    }
  }
  
  public enum MinCharacterLimit: Int {
    case phoneNumber
    
    public var value: Int {
      switch self {
      case .phoneNumber:
        return 7
      }
    }
  }
}



  // MARK: - FontSize
public extension Constants {
  enum FontSize {
    case main
    case medium
    case small
    case ultraSmall
    case large
    case navigationBar
    case textFieldHeader
    case buttonTextSize
    case regular
    case custom(size: CGFloat)
    
    public var value: CGFloat {
      switch self {
      case .main:
        return 18
      case .medium:
        return 16
      case .small:
        return 14
      case .textFieldHeader:
        return 12
      case .ultraSmall:
        return 12
      case .buttonTextSize:
        return 16
      case .navigationBar:
        return 20
      case .large:
        return 24
      case .regular:
        return 13
      case let .custom(size):
        return size
      }
    }
  }
}

// MARK: - FractionDigitsLimit
public extension Constants {
  enum FractionDigitsLimit {
    case fiat
    case crypto
    
    public var maxFractionDigits: Int {
      switch self {
      case .fiat: return 2
      case .crypto: return 8
      }
    }
    
    public var minFractionDigits: Int {
      switch self {
      case .fiat: return 2
      case .crypto: return 2
      }
    }
  }
}

  // MARK: - Currency
public extension Constants {
  enum CurrencyUnit: String {
    case usd = "$"
    
    public var symbol: String {
      rawValue
    }
    
    public var description: String {
      switch self {
      case .usd:
        return "USD"
      }
    }
    
    public var maxFractionDigits: Int {
      switch self {
      case .usd:
        return 2
      }
    }
  }
  
  enum CurrencyType: String {
    case fiat = "FIAT"
    case crypto = "CRYPTO"
  }
  
  enum CurrencyList {
    public static let fiats = ["USD"]
  }
}

  // MARK: TransactionType
public extension Constants {
  enum TransactionType: String {
    case ach = "ACH"
  }
}

// MARK: ErrorCode
public extension Constants {
  enum ErrorCode: String {
    case userInactive = "user_inactive"
    case credentialsInvalid = "credentials_invalid"
    case invalidSSN = "invalid_ssn"
    case invalidTOTP = "invalid_totp"
    case ticketExisted = "increase_limit_ticket_existed"
    case transferLimitExceeded = "transfer_limit_exceeded"
    case bankTransferRequestLimitReached = "bank_transfer_request_limit_reached"
    case amountTooLow = "amount_too_low"
    case insufficientFunds = "insufficient_funds"
    case accountCreationInProgress = "crypto_account_creation_in_progress"
    case duplicatedWalletNickname = "duplicated_wallet_nickname"
    case cardNameConflict = "card_name_conflict"
    case questionsNotAvailable = "identity_verification_questions_not_available"
    case portalBackupShareNotFound = "portal_backup_share_not_found"
    
    public var value: String {
      rawValue
    }
  }
}

// MARK: SupportTicket
public extension Constants {
  enum SupportTicket: String {
    case increaseLimit = "increase_limit"
    
    public var value: String {
      rawValue
    }
  }
}

// MARK: - TransactionTypes
public extension Constants {
  enum TransactionTypesRequest {
    case fiat
    case crypto
    case reward
    
    public var types: [String] {
      switch self {
      case .fiat:
        return [
          "PURCHASE",
          "DEPOSIT",
          "WITHDRAW",
          "SYSTEM_FEE",
          "REFUND",
          "CRYPTO_BUY",
          "CRYPTO_SELL",
          "DONATION",
          "OTHER",
          "REWARD_CASHBACK",
          "REWARD_CASHBACK_REVERSE"
        ]
      case .crypto:
        return [
          //"CRYPTO_BUY",
          //"CRYPTO_SELL",
          "CRYPTO_WITHDRAW",
          "CRYPTO_DEPOSIT",
          //"CRYPTO_GAS_DEDUCTION",
          //"CRYPTO_BUY_REFUND"
          //"REWARD_CRYPTOBACK",
          //"REWARD_CRYPTOBACK_DOSH",
          //"REWARD_CRYPTOBACK_REVERSE"
        ]
      case .reward:
        return [
          "REWARD_CRYPTOBACK",
          "REWARD_CRYPTOBACK_DOSH",
          "REWARD_CRYPTOBACK_REVERSE",
          "REWARD_CASHBACK",
          "REWARD_CASHBACK_REVERSE",
          "REWARD_REFERRAL",
          "REWARD_WITHDRAWAL"
        ]
      }
    }
  }
}

  // MARK: - Default
public extension Constants {
  enum Default: String {
    case undefined = "Undefined"
    case undefinedSymbol = "--"
    case region = "US"
    case regionCode = "+1"
    case numberCharacters = "0123456789"
    case ssnPlaceholder = "* * * *"
    case maxSize = "20"
    case capacityUnit = "Mb"
    case asterisk = "*"
    case dotSymbol = "•"
    case zeroAmount = "0"
    case cardNumberPattern = "(\\d{4})(\\d{4})(\\d{4})(\\d{4})"
    case cardNumberTemplate = "$1 $2 $3 $4"
    case expirationDatePlaceholder = "••/••"
    case expirationDateAsteriskPlaceholder = "**/**"
    case fullCardNumberPlaceholder = "•••• •••• •••• ••••"
    case cardNumberPlaceholder = "••••  ••••  ••••  "
    case physicalCardNumberPlaceholder = "••••  "
    case cvvPlaceholder = "•••"
    case decimalSeparator = "."
    case percentage = "%"
    case currencyDefaultAmount = "$0.00"
    case companyInformation = "10573 West Pico Blvd. #186, Los Angeles, CA 90064 \n Questions? Contact"
    case accountCardSecurity = "XXXXXXXXXX XXXXXXXXX XXX"
    case currencyDescription = "Dollars"
    case documentName = "document.pdf"
    case walletAddressPlaceholder = "************"
    case statementFromMonth = "1"
    case statementFromYear = "2023"
    case cvvContentPath = "cvv"
    case cardNumberContentPath = "cardNumber"
    case localTransactionID = "localTransactionID"
  }
}

// MARK: - NetSpendKey
public extension Constants {
  enum NetSpendKey: String {
    case verificationValue = "verification_value"
    case cvc = "cvc"
    case pin = "pin"
    case cvv2 = "cvv2"
    case pan = "pan"
  }
}

// MARK: - Notification
public extension Constants {
  enum UserInfoKey: String {
    case cards
    case card
  }
}

public extension Constants {
  static let defaultLimit = 20
  
  static let lowBalanceThreshold = 5.0
  
  static let kycQuestionTimeOut = 600
  
  static let withdrawalMFAThreshold = 1_000.0
  
  static let maxVirtualCard = 2
  
  static let hiddenPassword = "*********"
  
  static var unSupportedStates: [String] = ["NY", "New York", "HI", "Hawaii"]
  
  static let netSpendSDKLinkBankErrors = ["error", "failedToLinkBank", "externalLinkBankError"]
  
  static let pathwardAttributeInformation = [
    L10N.Common.Question.PathwardCondition.userAgreement: LFUtilities.pathwardUserAgreement,
    L10N.Common.Question.PathwardCondition.privacyPolicy: LFUtilities.pathwardPrivacyPolicy,
    L10N.Common.Question.PathwardCondition.regulatoryDisclosures: LFUtilities.pathwardRegulatoryDisclosure
  ]
  
  static let identifyVerification = [
    L10N.Common.UploadDocument.IdentifyRequirement.idCard,
    L10N.Common.UploadDocument.IdentifyRequirement.greenCard,
    L10N.Common.UploadDocument.IdentifyRequirement.usPassport,
    L10N.Common.UploadDocument.IdentifyRequirement.driverLicense,
    L10N.Common.UploadDocument.IdentifyRequirement.govermentOrMilitaryCard,
    L10N.Common.UploadDocument.IdentifyRequirement.foreignPassport,
    L10N.Common.UploadDocument.IdentifyRequirement.visa,
    L10N.Common.UploadDocument.IdentifyRequirement.matriculaConsular
  ]
  
  static let addressVerification = [
    L10N.Common.UploadDocument.AddressRequirement.utility,
    L10N.Common.UploadDocument.AddressRequirement.payStub,
    L10N.Common.UploadDocument.AddressRequirement.bankStatement,
    L10N.Common.UploadDocument.AddressRequirement.idMatching,
    L10N.Common.UploadDocument.AddressRequirement._401Statement,
    L10N.Common.UploadDocument.AddressRequirement.mortgae
  ]
  
  static let secondaryDocument = [
    L10N.Common.UploadDocument.SecondaryRequirement.utility,
    L10N.Common.UploadDocument.SecondaryRequirement.earnings,
    L10N.Common.UploadDocument.SecondaryRequirement.cellPhone,
    L10N.Common.UploadDocument.SecondaryRequirement.creditCard,
    L10N.Common.UploadDocument.SecondaryRequirement.bankStatement,
    L10N.Common.UploadDocument.SecondaryRequirement.collectionsLetter,
    L10N.Common.UploadDocument.SecondaryRequirement.schoolRecords,
    L10N.Common.UploadDocument.SecondaryRequirement.insurance,
    L10N.Common.UploadDocument.SecondaryRequirement.medical,
    L10N.Common.UploadDocument.SecondaryRequirement.mortgae,
    L10N.Common.UploadDocument.SecondaryRequirement._401Statement,
    L10N.Common.UploadDocument.SecondaryRequirement.medicaid
  ]
  
  static let proofOfNameChange = [
    L10N.Common.UploadDocument.ProofRequirement.oldLicense,
    L10N.Common.UploadDocument.ProofRequirement.newStateID,
    L10N.Common.UploadDocument.ProofRequirement.oldLicense,
    L10N.Common.UploadDocument.ProofRequirement.newLicense
  ]
  
  static let ssnDocument = [
    L10N.Common.UploadDocument.SsnRequirement.socialSecurity
  ]
  
  static let shortTransactionLimit = 20
  static let transactionOffset = 0
  static let transactionsTypeKey = "transactionTypes"
  static let transactionsTypes = [
    "PURCHASE", "DEPOSIT", "WITHDRAW",
    "SYSTEM_FEE", "REFUND", "CRYPTO_BUY",
    "CRYPTO_SELL", "DONATION", "OTHER",
    "REWARD_CASHBACK", "REWARD_CASHBACK_REVERSE"
  ]
}

public extension Constants {
  
  static var smartyStreetsHostName = "www.smartystreets.com"
  static var smartyStreetsId = "190944838438598167"
  static var smartyStreetsLicense = "us-autocomplete-pro-cloud"
  
}

// MARK: - Debug Log
public extension Constants {
  enum DebugLog {
    case setRoute(fromRoute: String, toRoute: String)
    case switchPhone
    case takeTime(time: CFAbsoluteTime)
    case missingAccountStatus(status: String)
    case unauthorized
    case dashboardApproved(statusCode: NSInteger)
    case cipherTextSavedSuccessfully
    
    public var value: String {
      switch self {
      case let .setRoute(fromRoute, toRoute):
        return "OnboardingFlowCoordinator will route to: \(toRoute), from current route: \(fromRoute)"
      case .switchPhone:
        return "The user switches from phone login to device login."
      case let .takeTime(time):
        return "Operation took \(time) seconds"
      case let .missingAccountStatus(status):
        return "Account status information is missing: \(status)"
      case .unauthorized:
        return "<<<<<<<<<<<<<< 401 Unauthorized: Clear user data and perform logout. >>>>>>>>>>>>>>>"
      case let .dashboardApproved(statusCode):
        return "Approved dashboard state: \(statusCode)"
      case .cipherTextSavedSuccessfully:
        return "Portal wallet cipher text saved successfully"
      }
    }
  }
}


// MARK: - DateTextField
public extension Constants {
  enum DateTextField {
    public static let placeholder = "mm / dd / yyyy"
    public static let maxYearOffset = -18
    public static let maxMonthOffset = -1
    public static let minYearOffset = -100
    public static let initialYearOffset = -20
  }
}
