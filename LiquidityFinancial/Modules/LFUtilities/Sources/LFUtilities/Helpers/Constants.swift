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
    case cardPinCode
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
    case rewardCashBack
    case rewardCryptoBack
    
    public var types: String {
      switch self {
      case .fiat:
        return "PURCHASE,DEPOSIT,WITHDRAW,SYSTEM_FEE,REFUND,CRYPTO_BUY,CRYPTO_SELL,DONATION,OTHER,REWARD_CASHBACK,REWARD_CASHBACK_REVERSE"
      case .crypto:
        return "CRYPTO_BUY,CRYPTO_SELL,CRYPTO_WITHDRAW,CRYPTO_DEPOSIT,CRYPTO_GAS_DEDUCTION,CRYPTO_BUY_REFUND,REWARD_CRYPTOBACK,REWARD_CRYPTOBACK_DOSH,REWARD_CRYPTOBACK_REVERSE"
      case .rewardCashBack:
        return "REWARD_CASHBACK,REWARD_CASHBACK_REVERSE"
      case .rewardCryptoBack:
        return "REWARD_CRYPTOBACK,REWARD_CRYPTOBACK_DOSH,REWARD_CRYPTOBACK_REVERSE"
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
    case dotSymbol = "•"
    case pinCodeDigits = "4"
    case cvvCodeDigits = "3"
    case zeroAmount = "0"
    case expirationDatePlaceholder = "••/••"
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

public extension Constants {
  static let lowBalanceThreshold = 5.0
  
  static let kycQuestionTimeOut = 600
  
  static let withdrawalMFAThreshold = 1_000.0
  
  static let hiddenPassword = "*********"
  
  static var supportedStates: [String] = ["NY", "New York", "HI", "Hawaii"]
  
  static let netSpendSDKLinkBankErrors = ["error", "failedToLinkBank", "externalLinkBankError"]
  
  static let pathwardAttributeInformation = [
    LFLocalizable.Question.PathwardCondition.userAgreement: LFUtilities.pathwardUserAgreement,
    LFLocalizable.Question.PathwardCondition.privacyPolicy: LFUtilities.pathwardPrivacyPolicy,
    LFLocalizable.Question.PathwardCondition.regulatoryDisclosures: LFUtilities.pathwardRegulatoryDisclosure
  ]
  
  static let identifyVerification = [
    LFLocalizable.UploadDocument.IdentifyRequirement.idCard,
    LFLocalizable.UploadDocument.IdentifyRequirement.greenCard,
    LFLocalizable.UploadDocument.IdentifyRequirement.usPassport,
    LFLocalizable.UploadDocument.IdentifyRequirement.driverLicense,
    LFLocalizable.UploadDocument.IdentifyRequirement.govermentOrMilitaryCard,
    LFLocalizable.UploadDocument.IdentifyRequirement.foreignPassport,
    LFLocalizable.UploadDocument.IdentifyRequirement.visa,
    LFLocalizable.UploadDocument.IdentifyRequirement.matriculaConsular
  ]
  
  static let addressVerification = [
    LFLocalizable.UploadDocument.AddressRequirement.utility,
    LFLocalizable.UploadDocument.AddressRequirement.payStub,
    LFLocalizable.UploadDocument.AddressRequirement.bankStatement,
    LFLocalizable.UploadDocument.AddressRequirement.idMatching,
    LFLocalizable.UploadDocument.AddressRequirement._401Statement,
    LFLocalizable.UploadDocument.AddressRequirement.mortgae
  ]
  
  static let secondaryDocument = [
    LFLocalizable.UploadDocument.SecondaryRequirement.utility,
    LFLocalizable.UploadDocument.SecondaryRequirement.earnings,
    LFLocalizable.UploadDocument.SecondaryRequirement.cellPhone,
    LFLocalizable.UploadDocument.SecondaryRequirement.creditCard,
    LFLocalizable.UploadDocument.SecondaryRequirement.bankStatement,
    LFLocalizable.UploadDocument.SecondaryRequirement.collectionsLetter,
    LFLocalizable.UploadDocument.SecondaryRequirement.schoolRecords,
    LFLocalizable.UploadDocument.SecondaryRequirement.insurance,
    LFLocalizable.UploadDocument.SecondaryRequirement.medical,
    LFLocalizable.UploadDocument.SecondaryRequirement.mortgae,
    LFLocalizable.UploadDocument.SecondaryRequirement._401Statement,
    LFLocalizable.UploadDocument.SecondaryRequirement.medicaid
  ]
  
  static let proofOfNameChange = [
    LFLocalizable.UploadDocument.ProofRequirement.oldLicense,
    LFLocalizable.UploadDocument.ProofRequirement.newStateID,
    LFLocalizable.UploadDocument.ProofRequirement.oldLicense,
    LFLocalizable.UploadDocument.ProofRequirement.newLicense
  ]
  
  static let ssnDocument = [
    LFLocalizable.UploadDocument.SsnRequirement.socialSecurity
  ]
}

public extension Constants {
  
  static var smartyStreetsHostName = "www.smartystreets.com"
  static var smartyStreetsId = "105107630856945597"
  static var smartyStreetsLicense = "us-autocomplete-pro-cloud"
  
}
