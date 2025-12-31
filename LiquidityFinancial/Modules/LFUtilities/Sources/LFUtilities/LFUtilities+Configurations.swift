import Foundation

// swiftlint: disable force_try fallthrough force_cast
extension LFUtilities {
  public static var personaCallback = "https://personacallback"
  public static var termsURL: String = try! LFConfiguration.value(for: "TERMS_URL")
  public static var cardTermsURLUs: String = try! LFConfiguration.value(for: "CARD_TERMS_URL_US")
  public static var cardTermsURLInt: String = try! LFConfiguration.value(for: "CARD_TERMS_URL_INT")
  public static var accountDisclosureURL: String = try! LFConfiguration.value(for: "ACCOUNT_DISCLOSURE_URL")
  public static var issuerPrivacyPolicyURL: String = try! LFConfiguration.value(for: "ISSUER_PRIVACY_POLICY_URL")
  public static var accountAgreementURL: String = try! LFConfiguration.value(for: "ACCOUNT_AGREEMENT_URL")
  public static var privacyURL: String = try! LFConfiguration.value(for: "PRIVACY_URL")
  public static var portalTermsURL: String = try! LFConfiguration.value(for: "PORTAL_TERMS_URL")
  public static var portalPrivacyURL: String = try! LFConfiguration.value(for: "PORTAL_PRIVACY_URL")
  public static var portalSecurityURL: String = try! LFConfiguration.value(for: "PORTAL_SECURITY_URL")
  public static var consentURL: String = try! LFConfiguration.value(for: "CONSENT_URL")
  public static var zerohashURL: String = try! LFConfiguration.value(for: "ZEROHASH_URL")
  public static var disclosureURL: String = try! LFConfiguration.value(for: "DISCLOSURE_URL")
  public static var termsservice: String = try! LFConfiguration.value(for: "TERMS_SERVICE_URL")
  public static var bankTrustConsumerURL: String = try! LFConfiguration.value(for: "BANK_TRUST_CONSUMER_URL")
  public static var bankTrustPolicyURL: String = try! LFConfiguration.value(for: "BANK_TRUST_POLICY_URL")
  public static var shareAppUrl: String = try! LFConfiguration.value(for: "SHARE_APP_URL")
  public static var rewardsVideoUrl: String = try! LFConfiguration.value(for: "REWARDS_VIDEO_URL")
  public static var appName: String = try! LFConfiguration.value(for: "APP_NAME")
  public static var stablecoinSymbol: String = try! LFConfiguration.value(for: "STABLECOIN_SYMBOL")
  public static var cryptoEnabled: Bool = try! LFConfiguration.value(for: "CRYPTO_ENABLED")
  public static var charityEnabled: Bool = try! LFConfiguration.value(for: "CHARITY_ENABLED")
  public static var cryptoFractionDigits: Int = try! LFConfiguration.value(for: "CRYPTO_FRACTION_DIGITS")
  public static var pathwardUserAgreement: String = try! LFConfiguration.value(for: "PATHWARD_USER_URL")
  public static var pathwardPrivacyPolicy: String = try! LFConfiguration.value(for: "PATHWARD_PRIVACY_URL")
  public static var pathwardRegulatoryDisclosure: String = try! LFConfiguration.value(for: "PATHWARD_DISCLOSURE_URL")
  public static let marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
  public static let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
  public static let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "unkwnown"
  public static let referrallinkDev: String = try! LFConfiguration.value(for: "REFERRALLINK_DEV")
  public static let referrallinkProd: String = try! LFConfiguration.value(for: "REFERRALLINK_PRO")
  public static let universalLink: String = try! LFConfiguration.value(for: "UNIVERSAL_LINK")
  public static let appStoreLink: String? = try? LFConfiguration.value(for: "APPSTORE_URL")
  public static let googleInfoFileNameProd: String = try! LFConfiguration.value(for: "GOOGLE_PROD_INFO_FILE_NAME")
  public static let googleInfoFileNameDev: String = try! LFConfiguration.value(for: "GOOGLE_DEV_INFO_FILE_NAME")
}

public enum LFConfiguration {
  public enum Error: Swift.Error {
    case missingKey
    case invalidValue
  }
  
  // Support for running code in previews
  public static var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }
  // Support for running code as a part of a test
  static var isRunningTests: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_TESTS"] != nil
  }
  
  public static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible & HasDefaultValue {
    if LFConfiguration.isRunningTests {
      if T.self == String.self {
        return key as! T
      }
      
      return T.defaultValue
    } else {
      guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
        throw Error.missingKey
      }
      switch object {
      case let value as T:
        return value
      case let string as String:
        guard let value = T(string) else { fallthrough }
        return value
      default:
        throw Error.invalidValue
      }
    }
  }
}

public protocol HasDefaultValue {
  static var defaultValue: Self { get }
}

extension Int: HasDefaultValue {
  public static let defaultValue = 0
}

extension Bool: HasDefaultValue {
  public static let defaultValue = false
}

extension String: HasDefaultValue {
  public static  let defaultValue = ""
}
