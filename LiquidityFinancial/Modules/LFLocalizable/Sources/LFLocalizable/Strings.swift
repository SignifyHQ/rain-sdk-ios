// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum LFLocalizable {
  /// Date of birth
  public static let dob = LFLocalizable.tr("Localizable", "dob", fallback: "Date of birth")
  /// dd / mm / yyyy
  public static let dobFormat = LFLocalizable.tr("Localizable", "dob_format", fallback: "dd / mm / yyyy")
  /// Email
  public static let email = LFLocalizable.tr("Localizable", "email", fallback: "Email")
  /// Enter email address
  public static let enterEmailAddress = LFLocalizable.tr("Localizable", "enter_emailAddress", fallback: "Enter email address")
  /// Enter legal first name
  public static let enterFirstName = LFLocalizable.tr("Localizable", "enter_firstName", fallback: "Enter legal first name")
  /// Enter legal last name
  public static let enterLastName = LFLocalizable.tr("Localizable", "enter_lastName", fallback: "Enter legal last name")
  /// Legal first name
  public static let firstName = LFLocalizable.tr("Localizable", "first_name", fallback: "Legal first name")
  /// Legal last name
  public static let lastName = LFLocalizable.tr("Localizable", "last_name", fallback: "Legal last name")
  /// First name and Last name should not be more than 23 characters
  public static let nameExceedMessage = LFLocalizable.tr("Localizable", "name_exceed_message", fallback: "First name and Last name should not be more than 23 characters")
  /// Encrypted using 256-BIT SSL
  public static let passportEncryptInfo = LFLocalizable.tr("Localizable", "passport_encrypt_info", fallback: "Encrypted using 256-BIT SSL")
  /// ENTER PASSPORT NUMBER
  public static let passportHeading = LFLocalizable.tr("Localizable", "passport_heading", fallback: "ENTER PASSPORT NUMBER")
  /// No credit checks
  public static let passportNoCreditCheckInfo = LFLocalizable.tr("Localizable", "passport_noCreditCheck_info", fallback: "No credit checks")
  /// Passport number
  public static let passportPlaceholder = LFLocalizable.tr("Localizable", "passport_placeholder", fallback: "Passport number")
  /// Required to create %@
  public static func passportRequiredToCreateInfo(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "passport_requiredToCreate_info", String(describing: p1), fallback: "Required to create %@")
  }
  /// International Passport
  public static let passportTypeInternational = LFLocalizable.tr("Localizable", "passport_type_international", fallback: "International Passport")
  /// US Passport
  public static let passportTypeUs = LFLocalizable.tr("Localizable", "passport_type_us", fallback: "US Passport")
  public enum AddPersonalInformation {
    /// Add personal information
    public static let title = LFLocalizable.tr("Localizable", "addPersonalInformation.title", fallback: "Add personal information")
  }
  public enum Button {
    public enum Continue {
      /// Continue
      public static let title = LFLocalizable.tr("Localizable", "button.continue.title", fallback: "Continue")
    }
    public enum Logout {
      /// Log Out
      public static let title = LFLocalizable.tr("Localizable", "button.logout.title", fallback: "Log Out")
    }
    public enum Ok {
      /// OK
      public static let title = LFLocalizable.tr("Localizable", "button.ok.title", fallback: "OK")
    }
    public enum Title {
      /// Trade Now and Get
      /// Your Life
      public static let text = LFLocalizable.tr("Localizable", "button.title.text", fallback: "Trade Now and Get\nYour Life")
    }
  }
  public enum EnterSsn {
    /// Encrypted using 256-BIT SSL
    public static let bulletOne = LFLocalizable.tr("Localizable", "enter_ssn.bullet_one", fallback: "Encrypted using 256-BIT SSL")
    /// Required to create AvalancheCard
    public static let bulletThree = LFLocalizable.tr("Localizable", "enter_ssn.bullet_three", fallback: "Required to create AvalancheCard")
    /// No credit checks, doesn't impact credit score
    public static let bulletTwo = LFLocalizable.tr("Localizable", "enter_ssn.bullet_two", fallback: "No credit checks, doesn't impact credit score")
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "enter_ssn.continue", fallback: "Continue")
    /// No SSN? Tap here
    public static let noSsn = LFLocalizable.tr("Localizable", "enter_ssn.no_ssn", fallback: "No SSN? Tap here")
    /// Enter Social Security Number
    public static let placeholder = LFLocalizable.tr("Localizable", "enter_ssn.placeholder", fallback: "Enter Social Security Number")
    /// PLEASE ENTER YOUR SSN
    public static let title = LFLocalizable.tr("Localizable", "enter_ssn.title", fallback: "PLEASE ENTER YOUR SSN")
    /// Why do we need SSN?
    public static let why = LFLocalizable.tr("Localizable", "enter_ssn.why", fallback: "Why do we need SSN?")
    public enum Alert {
      /// A valid SSN or Passport is required by our bank, Evolve Bank and Trust, to create a FDIC insured checking account. Your SSN is only stored with the bank and not accessible through AvalancheCard.
      public static let message = LFLocalizable.tr("Localizable", "enter_ssn.alert.message", fallback: "A valid SSN or Passport is required by our bank, Evolve Bank and Trust, to create a FDIC insured checking account. Your SSN is only stored with the bank and not accessible through AvalancheCard.")
      /// Ok
      public static let ok = LFLocalizable.tr("Localizable", "enter_ssn.alert.ok", fallback: "Ok")
      /// WHY DO WE NEED SSN?
      public static let title = LFLocalizable.tr("Localizable", "enter_ssn.alert.title", fallback: "WHY DO WE NEED SSN?")
    }
  }
  public enum Kyc {
    public enum Question {
      /// Please answer the following questions to help us verify your information.
      public static let desc = LFLocalizable.tr("Localizable", "kyc.question.desc", fallback: "Please answer the following questions to help us verify your information.")
      /// Additional Security Questions
      public static let title = LFLocalizable.tr("Localizable", "kyc.question.title", fallback: "Additional Security Questions")
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
  public enum Popup {
    public enum Logout {
      /// No
      public static let primaryTitle = LFLocalizable.tr("Localizable", "popup.logout.primaryTitle", fallback: "No")
      /// Yes
      public static let secondaryTitle = LFLocalizable.tr("Localizable", "popup.logout.secondaryTitle", fallback: "Yes")
      /// Are you sure you want to log out?
      public static let title = LFLocalizable.tr("Localizable", "popup.logout.title", fallback: "Are you sure you want to log out?")
    }
    public enum UploadDocument {
      /// Thank you, we have received your document
      public static let description = LFLocalizable.tr("Localizable", "popup.uploadDocument.description", fallback: "Thank you, we have received your document")
      /// DOCUMENTS UPLOADED
      public static let title = LFLocalizable.tr("Localizable", "popup.uploadDocument.title", fallback: "DOCUMENTS UPLOADED")
    }
  }
  public enum Screen {
    public enum Title {
      /// Hello i live in Package LFLocalizable
      public static let text = LFLocalizable.tr("Localizable", "screen.title.text", fallback: "Hello i live in Package LFLocalizable")
    }
  }
  public enum SecurityCheck {
    public enum Encrypt {
      /// Encrypted using 256-BIT SSL
      public static let cellText = LFLocalizable.tr("Localizable", "securityCheck.encrypt.cellText", fallback: "Encrypted using 256-BIT SSL")
    }
    public enum Last4SSN {
      /// SECURITY CHECK: ENTER LAST 4 OF SSN
      public static let screenTitle = LFLocalizable.tr("Localizable", "securityCheck.last4SSN.screenTitle", fallback: "SECURITY CHECK: ENTER LAST 4 OF SSN")
      /// Last 4 digits of Social Security Number/Passport
      public static let textFieldTitle = LFLocalizable.tr("Localizable", "securityCheck.last4SSN.textFieldTitle", fallback: "Last 4 digits of Social Security Number/Passport")
    }
    public enum NoCreditCheck {
      /// No credit checks
      public static let cellText = LFLocalizable.tr("Localizable", "securityCheck.noCreditCheck.cellText", fallback: "No credit checks")
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
  public enum UploadDocument {
    public enum Button {
      /// Upload Documents
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.button.title", fallback: "Upload Documents")
    }
    public enum MaxSize {
      /// %@ MB max size
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "uploadDocument.maxSize.description", String(describing: p1), fallback: "%@ MB max size")
      }
    }
    public enum Screen {
      /// %@ has partnered with NetSpend and Pathward Bank, a trusted partner in banking.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "uploadDocument.screen.description", String(describing: p1), fallback: "%@ has partnered with NetSpend and Pathward Bank, a trusted partner in banking.")
      }
      /// SET UP YOUR ACCOUNT
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.screen.title", fallback: "SET UP YOUR ACCOUNT")
    }
    public enum Upload {
      /// Upload Documents
      public static let actionTitle = LFLocalizable.tr("Localizable", "uploadDocument.upload.actionTitle", fallback: "Upload Documents")
      /// Please Upload documents to help us verify your account
      public static let description = LFLocalizable.tr("Localizable", "uploadDocument.upload.description", fallback: "Please Upload documents to help us verify your account")
      /// UPLOAD DOCUMENTS
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.upload.title", fallback: "UPLOAD DOCUMENTS")
    }
  }
  public enum VerificationCode {
    public enum EnterCode {
      /// ENTER VERIFICATION CODE
      public static let screenTitle = LFLocalizable.tr("Localizable", "verificationCode.enterCode.screenTitle", fallback: "ENTER VERIFICATION CODE")
      /// Enter Code
      public static let textFieldPlaceholder = LFLocalizable.tr("Localizable", "verificationCode.enterCode.textFieldPlaceholder", fallback: "Enter Code")
    }
    public enum OtpSent {
      /// New code sent
      public static let toastMessage = LFLocalizable.tr("Localizable", "verificationCode.otpSent.toastMessage", fallback: "New code sent")
    }
    public enum Resend {
      /// Resend Code
      public static let buttonTitle = LFLocalizable.tr("Localizable", "verificationCode.resend.buttonTitle", fallback: "Resend Code")
    }
    public enum SendTo {
      /// Code sent to %@
      public static func textFieldTitle(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "verificationCode.sendTo.textFieldTitle", String(describing: p1), fallback: "Code sent to %@")
      }
    }
  }
  public enum Welcome {
    /// HOW IT WORKS:
    public static let howItWorks = LFLocalizable.tr("Localizable", "welcome.how_it_works", fallback: "HOW IT WORKS:")
    public enum Button {
      /// Order Card
      public static let orderCard = LFLocalizable.tr("Localizable", "welcome.button.order_card", fallback: "Order Card")
    }
    public enum Header {
      /// The AvalancheCard is an easy way to earn Avalanche with everyday purchases.  You can also buy, sell and spend Avalanche with the AvalancheCard app.
      public static let desc = LFLocalizable.tr("Localizable", "welcome.header.desc", fallback: "The AvalancheCard is an easy way to earn Avalanche with everyday purchases.  You can also buy, sell and spend Avalanche with the AvalancheCard app.")
      /// WELCOME!
      public static let title = LFLocalizable.tr("Localizable", "welcome.header.title", fallback: "WELCOME!")
    }
    public enum HowItWorks {
      /// Create a AvalancheCard account
      public static let item1 = LFLocalizable.tr("Localizable", "welcome.how_it_works.item1", fallback: "Create a AvalancheCard account")
      /// Use your AvalancheCard for everyday purchases
      public static let item2 = LFLocalizable.tr("Localizable", "welcome.how_it_works.item2", fallback: "Use your AvalancheCard for everyday purchases")
      /// Give more by rounding up your purchases.
      public static let item3 = LFLocalizable.tr("Localizable", "welcome.how_it_works.item3", fallback: "Give more by rounding up your purchases.")
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
