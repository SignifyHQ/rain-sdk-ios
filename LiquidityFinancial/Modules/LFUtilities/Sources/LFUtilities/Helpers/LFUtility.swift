import UIKit

// swiftlint: disable force_try
public enum LFUtility {
  public static var personaCallback = "https://personacallback"
  public static var termsURL: String = try! LFConfiguration.value(for: "TERMS_URL")
  public static var accountAgreementURL: String = try! LFConfiguration.value(for: "ACCOUNT_AGREEMENT_URL")
  public static var privacyURL: String = try! LFConfiguration.value(for: "PRIVACY_URL")
  public static var walletPrivacyURL: String = try! LFConfiguration.value(for: "WALLET_PRIVACY_URL")
  public static var consentURL: String = try! LFConfiguration.value(for: "CONSENT_URL")
  public static var zerohashURL: String = try! LFConfiguration.value(for: "ZEROHASH_URL")
  public static var disclosureURL: String = try! LFConfiguration.value(for: "DISCLOSURE_URL")
  public static var termsservice: String = try! LFConfiguration.value(for: "TERMS_SERVICE_URL")
  public static var bankTrustConsumerURL: String = try! LFConfiguration.value(for: "BANK_TRUST_CONSUMER_URL")
  public static var bankTrustPolicyURL: String = try! LFConfiguration.value(for: "BANK_TRUST_POLICY_URL")
  public static var shareAppUrl: String = try! LFConfiguration.value(for: "SHARE_APP_URL")
  public static var rewardsVideoUrl: String = try! LFConfiguration.value(for: "REWARDS_VIDEO_URL")
  public static var appName: String = try! LFConfiguration.value(for: "APP_NAME")
  public static var cryptoEnabled: Bool = try! LFConfiguration.value(for: "CRYPTO_ENABLED")
  public static var charityEnabled: Bool = try! LFConfiguration.value(for: "CHARITY_ENABLED")
  public static var cryptoCurrency: String = try! LFConfiguration.value(for: "CRYPTO_CURRENCY")
  public static var cryptoFractionDigits: Int = try! LFConfiguration.value(for: "CRYPTO_FRACTION_DIGITS")
}

public enum LFConfiguration {
  public enum Error: Swift.Error {
    case missingKey
    case invalidValue
  }
  
  public static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
    guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
      throw Error.missingKey
    }
    switch object {
    case let value as T:
      return value
    case let string as String:
      guard let value = T(string) else { fatalError("Required configuration should match") }
      return value
    default:
      throw Error.invalidValue
    }
  }
}
