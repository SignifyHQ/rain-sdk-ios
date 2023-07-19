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
    case verificationLimit
    case ssnLength
    case fullSSNLength
    case cardLength
    case cardLast4Length
    case cardExpiryLength
    case cardExpiryMonthLength
    case cardExpiryYearLength
    case amountLimit
    case cryptoLimit
    case cvv
    case passportLength
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
      case .verificationLimit:
        return 6
      case .ssnLength:
        return 4
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
      case .passportLength:
        return 20
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

  // MARK: - Default
public extension Constants {
  enum Default: String {
    case region = "US"
    case regionCode = "+1"
    case numberCharacters = "0123456789"
    case ssnPlaceholder = "* * * *"
    case maxSize = "20"
    case capacityUnit = "Mb"
  }
}

public extension Constants {
  
  static var supportedStates: [String] = ["NY", "New York", "HI", "Hawaii"]
  
  static let netspendAttributeInformation = [
    LFLocalizable.SetUpAccount.NetpendCondition.userAgreement: LFUtility.netspendUserAgreement,
    LFLocalizable.SetUpAccount.NetpendCondition.privacyPolicy: LFUtility.netspendPrivacyPolicy,
    LFLocalizable.SetUpAccount.NetpendCondition.regulatoryDisclosures: LFUtility.netspendRegulatoryDisclosure
  ]
  
  static let pathwardAttributeInformation = [
    LFLocalizable.SetUpAccount.PathwardCondition.userAgreement: LFUtility.pathwardUserAgreement,
    LFLocalizable.SetUpAccount.PathwardCondition.privacyPolicy: LFUtility.pathwardPrivacyPolicy,
    LFLocalizable.SetUpAccount.PathwardCondition.regulatoryDisclosures: LFUtility.pathwardRegulatoryDisclosure
  ]
}

public extension Constants {
  
  static var smartyStreetsHostName = "www.smartystreets.com"
  static var smartyStreetsId = "105107630856945597"
  static var smartyStreetsLicense = "us-autocomplete-pro-cloud"
  
}
