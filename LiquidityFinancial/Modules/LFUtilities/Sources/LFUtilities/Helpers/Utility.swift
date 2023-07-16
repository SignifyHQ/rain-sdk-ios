import UIKit

public enum Utility {
  public static var personaCallback = "https://personacallback"
  public static var termsURL: String = try! Configuration.value(for: "TERMS_URL")
  public static var accountAgreementURL: String = try! Configuration.value(for: "ACCOUNT_AGREEMENT_URL")
  public static var privacyURL: String = try! Configuration.value(for: "PRIVACY_URL")
  public static var walletPrivacyURL: String = try! Configuration.value(for: "WALLET_PRIVACY_URL")
  public static var consentURL: String = try! Configuration.value(for: "CONSENT_URL")
  public static var zerohashURL: String = try! Configuration.value(for: "ZEROHASH_URL")
  public static var disclosureURL: String = try! Configuration.value(for: "DISCLOSURE_URL")
  public static var termsservice: String = try! Configuration.value(for: "TERMS_SERVICE_URL")
  public static var bankTrustConsumerURL: String = try! Configuration.value(for: "BANK_TRUST_CONSUMER_URL")
  public static var bankTrustPolicyURL: String = try! Configuration.value(for: "BANK_TRUST_POLICY_URL")
  public static var shareAppUrl: String = try! Configuration.value(for: "SHARE_APP_URL")
  public static var rewardsVideoUrl: String = try! Configuration.value(for: "REWARDS_VIDEO_URL")
  public static var appName: String = try! Configuration.value(for: "APP_NAME")
  public static var cryptoEnabled: Bool = try! Configuration.value(for: "CRYPTO_ENABLED")
  public static var charityEnabled: Bool = try! Configuration.value(for: "CHARITY_ENABLED")
  public static var cryptoCurrency: String = try! Configuration.value(for: "CRYPTO_CURRENCY")
  public static var cryptoFractionDigits: Int = try! Configuration.value(for: "CRYPTO_FRACTION_DIGITS")
}

enum Configuration {
  enum Error: Swift.Error {
    case missingKey
    case invalidValue
  }
  
  static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
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
