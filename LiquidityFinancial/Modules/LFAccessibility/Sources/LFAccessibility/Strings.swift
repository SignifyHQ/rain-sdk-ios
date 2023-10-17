// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum LFAccessibility {
  public enum AccountLockedScreen {
    /// contactSupportButton
    public static let contactSupportButton = LFAccessibility.tr("AccessibilityIdentifier", "accountLockedScreen.contactSupportButton", fallback: "contactSupportButton")
    /// contactSupportDescription
    public static let contactSupportDescription = LFAccessibility.tr("AccessibilityIdentifier", "accountLockedScreen.contactSupportDescription", fallback: "contactSupportDescription")
    /// contactSupportTitle
    public static let contactSupportTitle = LFAccessibility.tr("AccessibilityIdentifier", "accountLockedScreen.contactSupportTitle", fallback: "contactSupportTitle")
    /// lockedImage
    public static let lockedImage = LFAccessibility.tr("AccessibilityIdentifier", "accountLockedScreen.lockedImage", fallback: "lockedImage")
    /// logoutButton
    public static let logoutButton = LFAccessibility.tr("AccessibilityIdentifier", "accountLockedScreen.logoutButton", fallback: "logoutButton")
  }
  public enum HomeScreen {
    /// profileButton
    public static let profileButton = LFAccessibility.tr("AccessibilityIdentifier", "homeScreen.profileButton", fallback: "profileButton")
    /// Tab Bar
    public static let tabView = LFAccessibility.tr("AccessibilityIdentifier", "homeScreen.tabView", fallback: "Tab Bar")
  }
  public enum IdentityVerificationCode {
    /// continueButton
    public static let continueButton = LFAccessibility.tr("AccessibilityIdentifier", "identityVerificationCode.continueButton", fallback: "continueButton")
    /// identityVerificationCodeTitle
    public static let headerTitle = LFAccessibility.tr("AccessibilityIdentifier", "identityVerificationCode.headerTitle", fallback: "identityVerificationCodeTitle")
    /// ssnSecureField
    public static let ssnSecureField = LFAccessibility.tr("AccessibilityIdentifier", "identityVerificationCode.ssnSecureField", fallback: "ssnSecureField")
  }
  public enum PhoneNumber {
    /// conditionTextTappable
    public static let conditionTextTappable = LFAccessibility.tr("AccessibilityIdentifier", "phoneNumber.conditionTextTappable", fallback: "conditionTextTappable")
    /// continueButton
    public static let continueButton = LFAccessibility.tr("AccessibilityIdentifier", "phoneNumber.continueButton", fallback: "continueButton")
    /// phoneNumberTitle
    public static let headerTitle = LFAccessibility.tr("AccessibilityIdentifier", "phoneNumber.headerTitle", fallback: "phoneNumberTitle")
    /// icLogo
    public static let logoImage = LFAccessibility.tr("AccessibilityIdentifier", "phoneNumber.logoImage", fallback: "icLogo")
    /// phoneNumberTextField
    public static let textField = LFAccessibility.tr("AccessibilityIdentifier", "phoneNumber.textField", fallback: "phoneNumberTextField")
    /// voipTermTextTappable
    public static let voipTermTextTappable = LFAccessibility.tr("AccessibilityIdentifier", "phoneNumber.voipTermTextTappable", fallback: "voipTermTextTappable")
  }
  public enum Popup {
    /// popupMessage
    public static let message = LFAccessibility.tr("AccessibilityIdentifier", "popup.message", fallback: "popupMessage")
    /// popupPrimaryButton
    public static let primaryButton = LFAccessibility.tr("AccessibilityIdentifier", "popup.primaryButton", fallback: "popupPrimaryButton")
    /// popupSecondaryButton
    public static let secondaryButton = LFAccessibility.tr("AccessibilityIdentifier", "popup.secondaryButton", fallback: "popupSecondaryButton")
    /// AccessibilityIdentifier.strings
    public static let title = LFAccessibility.tr("AccessibilityIdentifier", "popup.title", fallback: "popupTitle")
  }
  public enum ProfileScreen {
    /// logoutButton
    public static let logoutButton = LFAccessibility.tr("AccessibilityIdentifier", "profileScreen.logoutButton", fallback: "logoutButton")
  }
  public enum VerificationCode {
    /// verificationCodeDescription
    public static let headerDescription = LFAccessibility.tr("AccessibilityIdentifier", "verificationCode.headerDescription", fallback: "verificationCodeDescription")
    /// verificationCodeTitle
    public static let headerTitle = LFAccessibility.tr("AccessibilityIdentifier", "verificationCode.headerTitle", fallback: "verificationCodeTitle")
    /// resendButton
    public static let resendButton = LFAccessibility.tr("AccessibilityIdentifier", "verificationCode.resendButton", fallback: "resendButton")
    /// resendTimer
    public static let resendTimerText = LFAccessibility.tr("AccessibilityIdentifier", "verificationCode.resendTimerText", fallback: "resendTimer")
    /// verificationCodeTextField
    public static let verificationCodeTextField = LFAccessibility.tr("AccessibilityIdentifier", "verificationCode.verificationCodeTextField", fallback: "verificationCodeTextField")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension LFAccessibility {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = Bundle.main.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
