// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum LFLocalizable {
  public enum Button {
    public enum Continue {
      /// Continue
      public static let title = LFLocalizable.tr("Localizable", "button.continue.title", fallback: "Continue")
    }
    public enum Title {
      /// Trade Now and Get
      /// Your Life
      public static let text = LFLocalizable.tr("Localizable", "button.title.text", fallback: "Trade Now and Get\nYour Life")
    }
  }
  public enum PhoneNumber {
    public enum Environment {
      /// Environment
      public static let title = LFLocalizable.tr("Localizable", "phoneNumber.environment.title", fallback: "Environment")
    }
    public enum TextField {
      /// Phone Number
      public static let description = LFLocalizable.tr("Localizable", "phoneNumber.textField.description", fallback: "Phone Number")
      /// Phone Number
      public static let title = LFLocalizable.tr("Localizable", "phoneNumber.textField.title", fallback: "Phone Number")
    }
  }
  public enum Screen {
    public enum Title {
      /// Hello i live in Package LFLocalizable
      public static let text = LFLocalizable.tr("Localizable", "screen.title.text", fallback: "Hello i live in Package LFLocalizable")
    }
  }
  public enum Term {
    public enum EsignConsent {
      /// E-sign consent
      public static let attributeText = LFLocalizable.tr("Localizable", "term.esignConsent.attributeText", fallback: "E-sign consent")
    }
    public enum PrivacyPolicy {
      /// Privacy Policy
      public static let attributeText = LFLocalizable.tr("Localizable", "term.privacyPolicy.attributeText", fallback: "Privacy Policy")
      /// By tapping ‘Continue’, you agree to our Terms, E-sign consent and Privacy Policy.
      public static let description = LFLocalizable.tr("Localizable", "term.privacyPolicy.description", fallback: "By tapping ‘Continue’, you agree to our Terms, E-sign consent and Privacy Policy.")
    }
    public enum Terms {
      /// Terms
      public static let attributeText = LFLocalizable.tr("Localizable", "term.terms.attributeText", fallback: "Terms")
    }
    public enum TermsVoip {
      /// Using VOIP or Google Voice numbers can result in onboarding delays. We NEVER share your phone number with third parties for marketing, per our Privacy Policy.
      public static let description = LFLocalizable.tr("Localizable", "term.termsVoip.description", fallback: "Using VOIP or Google Voice numbers can result in onboarding delays. We NEVER share your phone number with third parties for marketing, per our Privacy Policy.")
    }
  }
  public enum Wellcome {
    /// HOW IT WORKS:
    public static let howItWorks = LFLocalizable.tr("Localizable", "wellcome.how_it_works", fallback: "HOW IT WORKS:")
    public enum Button {
      /// Order Card
      public static let orderCard = LFLocalizable.tr("Localizable", "wellcome.button.order_card", fallback: "Order Card")
    }
    public enum Header {
      /// The AvalancheCard is an easy way to earn Avalanche with everyday purchases.  You can also buy, sell and spend Avalanche with the AvalancheCard app.
      public static let desc = LFLocalizable.tr("Localizable", "wellcome.header.desc", fallback: "The AvalancheCard is an easy way to earn Avalanche with everyday purchases.  You can also buy, sell and spend Avalanche with the AvalancheCard app.")
      /// WELLCOME!
      public static let title = LFLocalizable.tr("Localizable", "wellcome.header.title", fallback: "WELLCOME!")
    }
    public enum HowItWorks {
      /// Create a AvalancheCard account
      public static let item1 = LFLocalizable.tr("Localizable", "wellcome.how_it_works.item1", fallback: "Create a AvalancheCard account")
      /// Use your AvalancheCard for everyday purchases
      public static let item2 = LFLocalizable.tr("Localizable", "wellcome.how_it_works.item2", fallback: "Use your AvalancheCard for everyday purchases")
      /// Give more by rounding up your purchases.
      public static let item3 = LFLocalizable.tr("Localizable", "wellcome.how_it_works.item3", fallback: "Give more by rounding up your purchases.")
    }
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension LFLocalizable {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.main.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
