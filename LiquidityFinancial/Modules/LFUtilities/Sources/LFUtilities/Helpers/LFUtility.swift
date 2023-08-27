import UIKit
import StoreKit

// swiftlint: disable force_try fallthrough force_cast
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
  public static var cryptoFractionDigits: Int = try! LFConfiguration.value(for: "CRYPTO_FRACTION_DIGITS")
  public static var pathwardUserAgreement: String = try! LFConfiguration.value(for: "PATHWARD_USER_URL")
  public static var pathwardPrivacyPolicy: String = try! LFConfiguration.value(for: "PATHWARD_PRIVACY_URL")
  public static var pathwardRegulatoryDisclosure: String = try! LFConfiguration.value(for: "PATHWARD_DISCLOSURE_URL")
  public static let marketingVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
  public static let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
  public static let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "unkwnown"

}

public enum LFConfiguration {
  public enum Error: Swift.Error {
    case missingKey
    case invalidValue
  }
  
  //IT SUPPORT FOR RUN CODE UI IN PREVIEWS
  static var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
  }
  
  public static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
    if LFConfiguration.isPreview {
      return String(describing: "XCODE_PREVIEWS") as! T
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
// Helpers
extension LFUtility {
  public static func showRatingAlert() {
    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
      DispatchQueue.main.async {
        SKStoreReviewController.requestReview(in: scene)
      }
    }
  }
}

// Navigation
extension LFUtility {
  public static var rootViewController: UIViewController? {
    UIApplication
      .shared
      .connectedScenes
      .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
      .first(where: \.isKeyWindow)?
      .rootViewController
  }
  
  public static var visibleViewController: UIViewController? {
    UIApplication
      .shared
      .connectedScenes
      .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
      .first(where: \.isKeyWindow)?
      .visibleViewController
  }
  
  public static func popToRootView() {
    popToRootModalView()
    popToRootNavigationView()
  }
  
  private static func popToRootModalView() {
    rootViewController?.dismiss(animated: true)
  }
  
  private static func popToRootNavigationView() {
    findNavigationController(viewController: rootViewController)?.popToRootViewController(animated: true)
  }
  
  private static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
    guard let viewController = viewController else {
      return nil
    }
    if let navigationController = viewController as? UINavigationController {
      return navigationController
    }
    for childViewController in viewController.children {
      return findNavigationController(viewController: childViewController)
    }
    return nil
  }
}

extension LFUtility {
  public static var cryptoCurrency: String {
    switch LFUtilities.target {
    case .DogeCard:
      return "Doge"
    case .Avalanche:
      return "AVAX"
    case .Cardano:
      return "ADA"
    default:
      return .empty
    }
  }
  
  public static var cardName: String {
    switch LFUtilities.target {
    case .DogeCard:
      return "Doge"
    case .Avalanche:
      return "Avalanche"
    case .Cardano:
      return "Cardano"
    case .CauseCard:
      return "Cause"
    case .PrideCard:
      return "Pride"
    default:
      return .empty
    }
  }
}

extension LFUtility {
  
  public static var deviceId: String {
    UIDevice.current.identifierForVendor?.uuidString ?? .empty
  }
}
