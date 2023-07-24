// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum LFLocalizable {
  /// ACCOUNT UPDATE
  public static let accountUpdate = LFLocalizable.tr("Localizable", "account_update", fallback: "ACCOUNT UPDATE")
  /// WHERE TO SEND YOUR %@ CARD?
  public static func addressTitle(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "address_title", String(describing: p1), fallback: "WHERE TO SEND YOUR %@ CARD?")
  }
  /// Address line 1 
  public static let addressLine1Title = LFLocalizable.tr("Localizable", "addressLine1_title", fallback: "Address line 1 ")
  /// Address line 2
  public static let addressLine2Title = LFLocalizable.tr("Localizable", "addressLine2_title", fallback: "Address line 2")
  /// Cancel account
  public static let cancelAccount = LFLocalizable.tr("Localizable", "cancel_account", fallback: "Cancel account")
  /// City
  public static let city = LFLocalizable.tr("Localizable", "city", fallback: "City")
  /// Cryptocurrency services powered by Zero Hash
  public static let cryptocurrencyServicesInfo = LFLocalizable.tr("Localizable", "cryptocurrency_services_info", fallback: "Cryptocurrency services powered by Zero Hash")
  /// Date of birth
  public static let dob = LFLocalizable.tr("Localizable", "dob", fallback: "Date of birth")
  /// dd / mm / yyyy
  public static let dobFormat = LFLocalizable.tr("Localizable", "dob_format", fallback: "dd / mm / yyyy")
  /// Email
  public static let email = LFLocalizable.tr("Localizable", "email", fallback: "Email")
  /// Enter address
  public static let enterAddress = LFLocalizable.tr("Localizable", "enter_address", fallback: "Enter address")
  /// Enter city
  public static let enterCity = LFLocalizable.tr("Localizable", "enter_city", fallback: "Enter city")
  /// Enter email address
  public static let enterEmailAddress = LFLocalizable.tr("Localizable", "enter_emailAddress", fallback: "Enter email address")
  /// Enter first name
  public static let enterFirstName = LFLocalizable.tr("Localizable", "enter_firstName", fallback: "Enter first name")
  /// Enter last name
  public static let enterLastName = LFLocalizable.tr("Localizable", "enter_lastName", fallback: "Enter last name")
  /// Enter state
  public static let enterState = LFLocalizable.tr("Localizable", "enter_state", fallback: "Enter state")
  /// Enter zip code
  public static let enterZipcode = LFLocalizable.tr("Localizable", "enter_zipcode", fallback: "Enter zip code")
  /// First name
  public static let firstName = LFLocalizable.tr("Localizable", "first_name", fallback: "First name")
  /// Join waitlist
  public static let joinWaitlist = LFLocalizable.tr("Localizable", "join_waitlist", fallback: "Join waitlist")
  /// Last name
  public static let lastName = LFLocalizable.tr("Localizable", "last_name", fallback: "Last name")
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
  /// Rewards
  public static let rewards = LFLocalizable.tr("Localizable", "rewards", fallback: "Rewards")
  /// Sell Rewards
  public static let sellRewards = LFLocalizable.tr("Localizable", "sell_rewards", fallback: "Sell Rewards")
  /// State
  public static let state = LFLocalizable.tr("Localizable", "state", fallback: "State")
  /// Total rewards
  public static let totalRewards = LFLocalizable.tr("Localizable", "total_rewards", fallback: "Total rewards")
  /// Transfer Rewards
  public static let transferRewards = LFLocalizable.tr("Localizable", "transfer_rewards", fallback: "Transfer Rewards")
  /// You are now on the waitlist. We will email you when we can operate in your state.
  public static let waitlistJoinedMessage = LFLocalizable.tr("Localizable", "waitlist_joined_message", fallback: "You are now on the waitlist. We will email you when we can operate in your state.")
  /// WAITLIST JOINED
  public static let waitlistJoinedTitle = LFLocalizable.tr("Localizable", "waitlist_joined_title", fallback: "WAITLIST JOINED")
  /// Hello, %@. We are very sorry, but due to regulations regarding Doge, we are currently unable to open accounts for residents of New York and Hawaii. We are currently working with regulators to resolve this. In the meantime, we will contact you as soon as we can open your account.
  public static func waitlistMessage(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "waitlist_message", String(describing: p1), fallback: "Hello, %@. We are very sorry, but due to regulations regarding Doge, we are currently unable to open accounts for residents of New York and Hawaii. We are currently working with regulators to resolve this. In the meantime, we will contact you as soon as we can open your account.")
  }
  /// Cryptocurrency services powered by Zero Hash
  public static let zeroHashTransactiondetail = LFLocalizable.tr("Localizable", "Zero_hash_transactiondetail", fallback: "Cryptocurrency services powered by Zero Hash")
  /// Zip code
  public static let zipcode = LFLocalizable.tr("Localizable", "zipcode", fallback: "Zip code")
  public enum AddPersonalInformation {
    /// Add personal information
    public static let title = LFLocalizable.tr("Localizable", "addPersonalInformation.title", fallback: "Add personal information")
  }
  public enum AddToWallet {
    public enum ApplePay {
      /// Your %@ account is activated! Next, add %@ to your Apple Pay wallet for fast and easy payments.
      public static func description(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "addToWallet.applePay.description", String(describing: p1), String(describing: p2), fallback: "Your %@ account is activated! Next, add %@ to your Apple Pay wallet for fast and easy payments.")
      }
      /// It will add this card to Apple Wallet
      public static let message = LFLocalizable.tr("Localizable", "addToWallet.applePay.message", fallback: "It will add this card to Apple Wallet")
      /// ADD TO APPLE PAY
      public static let title = LFLocalizable.tr("Localizable", "addToWallet.applePay.title", fallback: "ADD TO APPLE PAY")
    }
  }
  public enum Address {
    public enum Disclosure {
      /// CauseCard Agreement
      public static let agreement = LFLocalizable.tr("Localizable", "address.disclosure.agreement", fallback: "CauseCard Agreement")
      /// Privacy Policy
      public static let privacy = LFLocalizable.tr("Localizable", "address.disclosure.privacy", fallback: "Privacy Policy")
      /// By tapping 'Continue', you consent to our %@ and %@.
      public static func text(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "address.disclosure.text", String(describing: p1), String(describing: p2), fallback: "By tapping 'Continue', you consent to our %@ and %@.")
      }
    }
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
    public enum Skip {
      /// Skip
      public static let title = LFLocalizable.tr("Localizable", "button.skip.title", fallback: "Skip")
    }
    public enum Title {
      /// Trade Now and Get
      /// Your Life
      public static let text = LFLocalizable.tr("Localizable", "button.title.text", fallback: "Trade Now and Get\nYour Life")
    }
  }
  public enum CardActivated {
    public enum CardActived {
      /// Your %@ is now active, nd can be used anywhere Visa is accepted.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "cardActivated.cardActived.description", String(describing: p1), fallback: "Your %@ is now active, nd can be used anywhere Visa is accepted.")
      }
      /// CARD ACTIVED!
      public static let title = LFLocalizable.tr("Localizable", "cardActivated.cardActived.title", fallback: "CARD ACTIVED!")
    }
  }
  public enum CashCard {
    public enum Balance {
      /// %@ Balance
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "cashCard.balance.title", String(describing: p1), fallback: "%@ Balance")
      }
    }
  }
  public enum CashTab {
    public enum ActiveVirtualCard {
      /// Tap to Activate Virtual Card
      public static let buttonTitle = LFLocalizable.tr("Localizable", "cashTab.activeVirtualCard.buttonTitle", fallback: "Tap to Activate Virtual Card")
    }
    public enum ChangeAsset {
      /// Change
      public static let buttonTitle = LFLocalizable.tr("Localizable", "cashTab.changeAsset.buttonTitle", fallback: "Change")
    }
    public enum DeActiveError {
      /// Your checking account was deactivated
      public static let message = LFLocalizable.tr("Localizable", "cashTab.deActiveError.message", fallback: "Your checking account was deactivated")
    }
    public enum LastestTransaction {
      /// Latest Transactions
      public static let title = LFLocalizable.tr("Localizable", "cashTab.lastestTransaction.title", fallback: "Latest Transactions")
    }
    public enum NoTransactionYet {
      /// No transactions yet
      public static let title = LFLocalizable.tr("Localizable", "cashTab.noTransactionYet.title", fallback: "No transactions yet")
    }
    public enum SeeAll {
      /// See all
      public static let title = LFLocalizable.tr("Localizable", "cashTab.seeAll.title", fallback: "See all")
    }
  }
  public enum ChangeAsset {
    public enum Screen {
      /// Please select the asset to spend.
      public static let message = LFLocalizable.tr("Localizable", "changeAsset.screen.message", fallback: "Please select the asset to spend.")
      /// Change asset
      public static let title = LFLocalizable.tr("Localizable", "changeAsset.screen.title", fallback: "Change asset")
    }
  }
  public enum DocumentType {
    public enum BottomSheet {
      /// DOCUMENT TYPE
      public static let title = LFLocalizable.tr("Localizable", "documentType.bottomSheet.title", fallback: "DOCUMENT TYPE")
    }
    public enum Button {
      /// Choose Document Type
      public static let title = LFLocalizable.tr("Localizable", "documentType.button.title", fallback: "Choose Document Type")
    }
    public enum ForeignID {
      /// Foreign ID
      public static let title = LFLocalizable.tr("Localizable", "documentType.foreignID.title", fallback: "Foreign ID")
    }
    public enum Other {
      /// Other
      public static let title = LFLocalizable.tr("Localizable", "documentType.other.title", fallback: "Other")
    }
    public enum Passport {
      /// Passport
      public static let title = LFLocalizable.tr("Localizable", "documentType.passport.title", fallback: "Passport")
    }
    public enum PayStub {
      /// Pay Stub dated within 30 days
      public static let title = LFLocalizable.tr("Localizable", "documentType.payStub.title", fallback: "Pay Stub dated within 30 days")
    }
    public enum SocialSecurityCard {
      /// Social Security Card
      public static let title = LFLocalizable.tr("Localizable", "documentType.socialSecurityCard.title", fallback: "Social Security Card")
    }
    public enum StateID {
      /// State issued photo id
      public static let title = LFLocalizable.tr("Localizable", "documentType.stateID.title", fallback: "State issued photo id")
    }
    public enum UtilityBill {
      /// Utility Bill
      public static let title = LFLocalizable.tr("Localizable", "documentType.utilityBill.title", fallback: "Utility Bill")
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
  public enum Error {
    public enum WeAreSorry {
      /// WE’RE SORRY
      public static let title = LFLocalizable.tr("Localizable", "error.weAreSorry.title", fallback: "WE’RE SORRY")
    }
  }
  public enum Home {
    public enum AccountTab {
      /// Account
      public static let title = LFLocalizable.tr("Localizable", "home.accountTab.title", fallback: "Account")
    }
    public enum AssetsTab {
      /// Assets
      public static let title = LFLocalizable.tr("Localizable", "home.assetsTab.title", fallback: "Assets")
    }
    public enum CashTab {
      /// Cash
      public static let title = LFLocalizable.tr("Localizable", "home.cashTab.title", fallback: "Cash")
    }
    public enum RewardsTab {
      /// Rewards
      public static let title = LFLocalizable.tr("Localizable", "home.rewardsTab.title", fallback: "Rewards")
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
  public enum KycStatus {
    public enum Fail {
      /// Based on the information you entered, we were unable to create a Depository account at this time. We will be in touch via email.
      public static let message = LFLocalizable.tr("Localizable", "kycStatus.fail.message", fallback: "Based on the information you entered, we were unable to create a Depository account at this time. We will be in touch via email.")
      /// WE’RE SORRY
      public static let title = LFLocalizable.tr("Localizable", "kycStatus.fail.title", fallback: "WE’RE SORRY")
    }
    public enum IdentityVerification {
      /// Please verify your identity with a valid Driver’s License, ID or Passport. 
      public static let message = LFLocalizable.tr("Localizable", "kycStatus.identityVerification.message", fallback: "Please verify your identity with a valid Driver’s License, ID or Passport. ")
      /// DRIVER’s LICENSE, ID OR PASSPORT
      public static let title = LFLocalizable.tr("Localizable", "kycStatus.identityVerification.title", fallback: "DRIVER’s LICENSE, ID OR PASSPORT")
    }
    public enum InReview {
      /// Hi %@, we are still verifying your account details. This is common when phone numbers, addresses or emails change. Please contact support and we will help verify the details. Thank you for your patience.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "kycStatus.inReview.message", String(describing: p1), fallback: "Hi %@, we are still verifying your account details. This is common when phone numbers, addresses or emails change. Please contact support and we will help verify the details. Thank you for your patience.")
      }
      /// Check Status
      public static let primaryTitle = LFLocalizable.tr("Localizable", "kycStatus.inReview.primaryTitle", fallback: "Check Status")
      /// Contact Support
      public static let secondaryTitle = LFLocalizable.tr("Localizable", "kycStatus.inReview.secondaryTitle", fallback: "Contact Support")
      /// VERIFYING ACCOUNT DETAILS
      public static let title = LFLocalizable.tr("Localizable", "kycStatus.inReview.title", fallback: "VERIFYING ACCOUNT DETAILS")
    }
    public enum WaitingVerification {
      /// We’re confiming your account details. This could take up to 30 seconds
      public static let message = LFLocalizable.tr("Localizable", "kycStatus.waitingVerification.message", fallback: "We’re confiming your account details. This could take up to 30 seconds")
      /// THANK YOU FOR WAITING
      public static let title = LFLocalizable.tr("Localizable", "kycStatus.waitingVerification.title", fallback: "THANK YOU FOR WAITING")
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
  public enum Question {
    public enum NetpendCondition {
      /// I agree to the Netspend User Agreement, and I have read and understand the NetSpend Privacy Policy and Regulatory Disclosures.
      public static let description = LFLocalizable.tr("Localizable", "question.netpendCondition.description", fallback: "I agree to the Netspend User Agreement, and I have read and understand the NetSpend Privacy Policy and Regulatory Disclosures.")
      /// NetSpend Privacy Policy
      public static let privacyPolicy = LFLocalizable.tr("Localizable", "question.netpendCondition.privacyPolicy", fallback: "NetSpend Privacy Policy")
      /// Regulatory Disclosures
      public static let regulatoryDisclosures = LFLocalizable.tr("Localizable", "question.netpendCondition.regulatoryDisclosures", fallback: "Regulatory Disclosures")
      /// Netspend User Agreement
      public static let userAgreement = LFLocalizable.tr("Localizable", "question.netpendCondition.userAgreement", fallback: "Netspend User Agreement")
    }
    public enum PathwardCondition {
      /// I agree to the Pathward Bank User Agreement, and I have read and understand the Pathward Privacy Policy and Regulatory Disclosures.
      public static let description = LFLocalizable.tr("Localizable", "question.pathwardCondition.description", fallback: "I agree to the Pathward Bank User Agreement, and I have read and understand the Pathward Privacy Policy and Regulatory Disclosures.")
      /// Pathward Privacy Policy
      public static let privacyPolicy = LFLocalizable.tr("Localizable", "question.pathwardCondition.privacyPolicy", fallback: "Pathward Privacy Policy")
      /// Regulatory Disclosures
      public static let regulatoryDisclosures = LFLocalizable.tr("Localizable", "question.pathwardCondition.regulatoryDisclosures", fallback: "Regulatory Disclosures")
      /// Pathward Bank User Agreement
      public static let userAgreement = LFLocalizable.tr("Localizable", "question.pathwardCondition.userAgreement", fallback: "Pathward Bank User Agreement")
    }
    public enum Screen {
      /// %@Card has partnered with NetSpend and Pathward Bank, a trusted partner in banking.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "question.screen.description", String(describing: p1), fallback: "%@Card has partnered with NetSpend and Pathward Bank, a trusted partner in banking.")
      }
      /// Set up your account
      public static let title = LFLocalizable.tr("Localizable", "question.screen.title", fallback: "Set up your account")
    }
  }
  public enum RewardTerms {
    /// up to 8'%' purchase of transaction
    public static let amountDescription = LFLocalizable.tr("Localizable", "rewardTerms.amount_description", fallback: "up to 8'%' purchase of transaction")
    /// Transaction Amount
    public static let amountTitle = LFLocalizable.tr("Localizable", "rewardTerms.amount_title", fallback: "Transaction Amount")
    /// By selecting to enroll in the crypto rewards program, you understand and agree that eligible rewards transactions will also trigger your authorization to invest in crypto once your action or card transaction is complete. Transactions may take time in certain cases.
    public static let disclosuresFirst = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_first", fallback: "By selecting to enroll in the crypto rewards program, you understand and agree that eligible rewards transactions will also trigger your authorization to invest in crypto once your action or card transaction is complete. Transactions may take time in certain cases.")
    /// Maximum reward amount may vary, and can depend on your level of participation in crypto rewards. Specific terms and condition may apply.
    public static let disclosuresFourth = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_fourth", fallback: "Maximum reward amount may vary, and can depend on your level of participation in crypto rewards. Specific terms and condition may apply.")
    /// Orders may not be canceled or reversed once submitted by you. By submitting a withdrawal request, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal
    public static let disclosuresSecond = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_second", fallback: "Orders may not be canceled or reversed once submitted by you. By submitting a withdrawal request, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal")
    /// Zero Hash does not offer the ability to set up pre-authorized, automatic, or recurring Orders (“Pre-Authorized Orders”) in your Account; (b) any such Pre-Authorized Order feature (if available) is under the exclusive control of CauseCard ; (c) you must contact CauseCard in order to stop a Pre-Authorized Order before execution or to turn off such a feature in your Account; and (d) Zero Hash and ZHLS are not liable for the placement and execution of any Pre-Authorized order.
    public static let disclosuresThird = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_third", fallback: "Zero Hash does not offer the ability to set up pre-authorized, automatic, or recurring Orders (“Pre-Authorized Orders”) in your Account; (b) any such Pre-Authorized Order feature (if available) is under the exclusive control of CauseCard ; (c) you must contact CauseCard in order to stop a Pre-Authorized Order before execution or to turn off such a feature in your Account; and (d) Zero Hash and ZHLS are not liable for the placement and execution of any Pre-Authorized order.")
    /// Exchange Rate
    public static let disclosuresTitle = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_title", fallback: "Exchange Rate")
    /// Enroll now
    public static let enrollCta = LFLocalizable.tr("Localizable", "rewardTerms.enroll_cta", fallback: "Enroll now")
    /// ENROLL FOR AVALANCHECARD REWARDS
    public static let enrollTitle = LFLocalizable.tr("Localizable", "rewardTerms.enroll_title", fallback: "ENROLL FOR AVALANCHECARD REWARDS")
    /// Varies, the current prevaling price as determined by Zero Hash Liquidity Services LLC at the point of transaction.
    public static let exchangeRateDescription = LFLocalizable.tr("Localizable", "rewardTerms.exchange_rate_description", fallback: "Varies, the current prevaling price as determined by Zero Hash Liquidity Services LLC at the point of transaction.")
    /// Exchange Rate
    public static let exchangeRateTitle = LFLocalizable.tr("Localizable", "rewardTerms.exchange_rate_title", fallback: "Exchange Rate")
    /// Fee
    public static let feeTitle = LFLocalizable.tr("Localizable", "rewardTerms.fee_title", fallback: "Fee")
    /// $0
    public static let feesDescription = LFLocalizable.tr("Localizable", "rewardTerms.fees_description", fallback: "$0")
    /// Fees
    public static let feesTitle = LFLocalizable.tr("Localizable", "rewardTerms.fees_title", fallback: "Fees")
    /// Network Fee
    public static let networkFee = LFLocalizable.tr("Localizable", "rewardTerms.network_fee", fallback: "Network Fee")
  }
  public enum Rewards {
    /// No rewards yet
    public static let noRewards = LFLocalizable.tr("Localizable", "rewards.no_rewards", fallback: "No rewards yet")
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
  public enum SetCardPin {
    public enum Popup {
      /// Your card's PIN is now set. Use it for purchases and at ATMs.
      public static let successMessage = LFLocalizable.tr("Localizable", "setCardPin.popup.successMessage", fallback: "Your card's PIN is now set. Use it for purchases and at ATMs.")
      /// CARD PIN SET
      public static let title = LFLocalizable.tr("Localizable", "setCardPin.popup.title", fallback: "CARD PIN SET")
    }
    public enum Screen {
      /// This PIN can be used at ATMs and for purchases, and is not used to get access to the app.
      public static let description = LFLocalizable.tr("Localizable", "setCardPin.screen.description", fallback: "This PIN can be used at ATMs and for purchases, and is not used to get access to the app.")
      /// SET CARD PIN
      public static let title = LFLocalizable.tr("Localizable", "setCardPin.screen.title", fallback: "SET CARD PIN")
    }
  }
  public enum SetUpWallet {
    /// AvalancheCard has partnered with ZeroHash, a trusted partner in crypto and ZeroHash,a crypto storage and liquidity provider.
    public static let info = LFLocalizable.tr("Localizable", "setUpWallet.info", fallback: "AvalancheCard has partnered with ZeroHash, a trusted partner in crypto and ZeroHash,a crypto storage and liquidity provider.")
    /// Regulatory Disclosures
    public static let regulatoryDisclosures = LFLocalizable.tr("Localizable", "setUpWallet.regulatory_disclosures", fallback: "Regulatory Disclosures")
    /// The value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.
    public static let riskDisclosure = LFLocalizable.tr("Localizable", "setUpWallet.risk_disclosure", fallback: "The value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.")
    /// Privacy Policy
    public static let solidPrivacyPolicy = LFLocalizable.tr("Localizable", "setUpWallet.solid_privacyPolicy", fallback: "Privacy Policy")
    /// I agree to the Zero Hash and Zero Hash Liquidity Services User Agreement, and I have read and understand the Zero Hash Privacy Policy and Regulatory Disclosures. I understand that the value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.
    public static let termsAndCondition = LFLocalizable.tr("Localizable", "setUpWallet.termsAndCondition", fallback: "I agree to the Zero Hash and Zero Hash Liquidity Services User Agreement, and I have read and understand the Zero Hash Privacy Policy and Regulatory Disclosures. I understand that the value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.")
    /// CREATE YOUR WALLET
    public static let title = LFLocalizable.tr("Localizable", "setUpWallet.title", fallback: "CREATE YOUR WALLET")
    /// User Agreement
    public static let userAgreement = LFLocalizable.tr("Localizable", "setUpWallet.userAgreement", fallback: "User Agreement")
    /// Zero Hash and Zero Hash Liquidity Services User Agreement
    public static let walletUseragreement = LFLocalizable.tr("Localizable", "setUpWallet.wallet_useragreement", fallback: "Zero Hash and Zero Hash Liquidity Services User Agreement")
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
  public enum TransferView {
    /// Checking **** %@
    public static func checking(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transferView.checking", String(describing: p1), fallback: "Checking **** %@")
    }
    /// Deposit
    public static let credit = LFLocalizable.tr("Localizable", "transferView.credit", fallback: "Deposit")
    /// Deposit completed
    public static let creditCompleted = LFLocalizable.tr("Localizable", "transferView.credit_completed", fallback: "Deposit completed")
    /// Deposit started
    public static let creditStarted = LFLocalizable.tr("Localizable", "transferView.credit_started", fallback: "Deposit started")
    /// Withdraw
    public static let debit = LFLocalizable.tr("Localizable", "transferView.debit", fallback: "Withdraw")
    /// Debit Card **** %@
    public static func debitCard(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transferView.debit_card", String(describing: p1), fallback: "Debit Card **** %@")
    }
    /// Withdraw completed
    public static let debitCompleted = LFLocalizable.tr("Localizable", "transferView.debit_completed", fallback: "Withdraw completed")
    /// Withdraw started
    public static let debitStarted = LFLocalizable.tr("Localizable", "transferView.debit_started", fallback: "Withdraw started")
    /// Limits reached
    public static let limitsReached = LFLocalizable.tr("Localizable", "transferView.limits_reached", fallback: "Limits reached")
    /// Savings **** %@
    public static func saving(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transferView.saving", String(describing: p1), fallback: "Savings **** %@")
    }
    public enum DebitSuggestion {
      /// For instant deposits, connect and deposit with your Debit Card
      public static let body = LFLocalizable.tr("Localizable", "transferView.debit_suggestion.body", fallback: "For instant deposits, connect and deposit with your Debit Card")
      /// Connect Debit Card
      public static let connect = LFLocalizable.tr("Localizable", "transferView.debit_suggestion.connect", fallback: "Connect Debit Card")
      /// Get Faster Deposits
      public static let title = LFLocalizable.tr("Localizable", "transferView.debit_suggestion.title", fallback: "Get Faster Deposits")
    }
    public enum RewardType {
      public enum Cashback {
        /// 0.75% on every qualifying purchase
        public static func subtitle(_ p1: Int) -> String {
          return LFLocalizable.tr("Localizable", "transferView.reward_type.cashback.subtitle", p1, fallback: "0.75% on every qualifying purchase")
        }
        /// Instant Cashback
        public static let title = LFLocalizable.tr("Localizable", "transferView.reward_type.cashback.title", fallback: "Instant Cashback")
      }
      public enum Donation {
        /// 0.75% donated to a charity you choose
        public static func subtitle(_ p1: Int) -> String {
          return LFLocalizable.tr("Localizable", "transferView.reward_type.donation.subtitle", p1, fallback: "0.75% donated to a charity you choose")
        }
        /// Donate to Charity
        public static let title = LFLocalizable.tr("Localizable", "transferView.reward_type.donation.title", fallback: "Donate to Charity")
      }
    }
    public enum RewardsStatus {
      /// Completed
      public static let completed = LFLocalizable.tr("Localizable", "transferView.rewards_status.completed", fallback: "Completed")
      /// Pending
      public static let pending = LFLocalizable.tr("Localizable", "transferView.rewards_status.pending", fallback: "Pending")
    }
    public enum Status {
      public enum Deposit {
        /// Deposit completed
        public static let completed = LFLocalizable.tr("Localizable", "transferView.status.deposit.completed", fallback: "Deposit completed")
        /// Deposit started
        public static let started = LFLocalizable.tr("Localizable", "transferView.status.deposit.started", fallback: "Deposit started")
      }
      public enum Reward {
        /// Reward completed
        public static let completed = LFLocalizable.tr("Localizable", "transferView.status.reward.completed", fallback: "Reward completed")
        /// Reward pending
        public static let started = LFLocalizable.tr("Localizable", "transferView.status.reward.started", fallback: "Reward pending")
      }
      public enum Withdraw {
        /// Withdraw completed
        public static let completed = LFLocalizable.tr("Localizable", "transferView.status.withdraw.completed", fallback: "Withdraw completed")
        /// Withdraw started
        public static let started = LFLocalizable.tr("Localizable", "transferView.status.withdraw.started", fallback: "Withdraw started")
      }
    }
    public enum WithdrawAnnotation {
      /// You currently have %@ available to withdraw. Rewards are not available to withdraw until 48 hours after they are earned.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transferView.withdraw_annotation.description", String(describing: p1), fallback: "You currently have %@ available to withdraw. Rewards are not available to withdraw until 48 hours after they are earned.")
      }
    }
  }
  public enum UploadDocument {
    public enum AddressRequirement {
      /// 401 statement
      public static let _401Statement = LFLocalizable.tr("Localizable", "uploadDocument.addressRequirement.401Statement", fallback: "401 statement")
      /// Bank Statement
      public static let bankStatement = LFLocalizable.tr("Localizable", "uploadDocument.addressRequirement.bankStatement", fallback: "Bank Statement")
      /// ID with matching address
      public static let idMatching = LFLocalizable.tr("Localizable", "uploadDocument.addressRequirement.idMatching", fallback: "ID with matching address")
      /// Mortgae document
      public static let mortgae = LFLocalizable.tr("Localizable", "uploadDocument.addressRequirement.mortgae", fallback: "Mortgae document")
      /// Pay Stub
      public static let payStub = LFLocalizable.tr("Localizable", "uploadDocument.addressRequirement.payStub", fallback: "Pay Stub")
      /// Address Verification - Any ID with a matching address
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.addressRequirement.title", fallback: "Address Verification - Any ID with a matching address")
      /// Utility bill
      public static let utility = LFLocalizable.tr("Localizable", "uploadDocument.addressRequirement.utility", fallback: "Utility bill")
    }
    public enum Button {
      /// Upload Documents
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.button.title", fallback: "Upload Documents")
    }
    public enum IdentifyRequirement {
      /// Driver's license
      public static let driverLicense = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.driverLicense", fallback: "Driver's license")
      /// Foreign Passpost
      public static let foreignPassport = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.foreignPassport", fallback: "Foreign Passpost")
      /// Government/military card
      public static let govermentOrMilitaryCard = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.govermentOrMilitaryCard", fallback: "Government/military card")
      /// Permanent US-Resident card for foreign-born, non-citizens (green card)
      public static let greenCard = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.greenCard", fallback: "Permanent US-Resident card for foreign-born, non-citizens (green card)")
      /// State issued ID Card
      public static let idCard = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.idCard", fallback: "State issued ID Card")
      /// Matricula Consular
      public static let matriculaConsular = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.matriculaConsular", fallback: "Matricula Consular")
      /// Identity Verification
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.title", fallback: "Identity Verification")
      /// US Passport
      public static let usPassport = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.usPassport", fallback: "US Passport")
      /// Visa
      public static let visa = LFLocalizable.tr("Localizable", "uploadDocument.identifyRequirement.visa", fallback: "Visa")
    }
    public enum MaxSize {
      /// %@ MB max size
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "uploadDocument.maxSize.description", String(describing: p1), fallback: "%@ MB max size")
      }
    }
    public enum ProofRequirement {
      /// Driver's license with the new name
      public static let newLicense = LFLocalizable.tr("Localizable", "uploadDocument.proofRequirement.newLicense", fallback: "Driver's license with the new name")
      /// State ID with the new name
      public static let newStateID = LFLocalizable.tr("Localizable", "uploadDocument.proofRequirement.newStateID", fallback: "State ID with the new name")
      /// Driver's license with the old name
      public static let oldLicense = LFLocalizable.tr("Localizable", "uploadDocument.proofRequirement.oldLicense", fallback: "Driver's license with the old name")
      /// State ID with the old name
      public static let oldStateID = LFLocalizable.tr("Localizable", "uploadDocument.proofRequirement.oldStateID", fallback: "State ID with the old name")
      /// Proof of name change
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.proofRequirement.title", fallback: "Proof of name change")
    }
    public enum Requirement {
      /// DOCUMENTS MUST CONTAIN:
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.requirement.title", fallback: "DOCUMENTS MUST CONTAIN:")
    }
    public enum Screen {
      /// %@ has partnered with NetSpend and Pathward Bank, a trusted partner in banking.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "uploadDocument.screen.description", String(describing: p1), fallback: "%@ has partnered with NetSpend and Pathward Bank, a trusted partner in banking.")
      }
      /// SET UP YOUR ACCOUNT
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.screen.title", fallback: "SET UP YOUR ACCOUNT")
    }
    public enum SecondaryRequirement {
      /// 401 statement
      public static let _401Statement = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.401Statement", fallback: "401 statement")
      /// Bank Statement
      public static let bankStatement = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.bankStatement", fallback: "Bank Statement")
      /// Cell phone bill
      public static let cellPhone = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.cellPhone", fallback: "Cell phone bill")
      /// Collections letter
      public static let collectionsLetter = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.collectionsLetter", fallback: "Collections letter")
      /// Credit card bill
      public static let creditCard = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.creditCard", fallback: "Credit card bill")
      /// Earnings Statement
      public static let earnings = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.earnings", fallback: "Earnings Statement")
      /// Insurance bill
      public static let insurance = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.insurance", fallback: "Insurance bill")
      /// Medicaid letter
      public static let medicaid = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.medicaid", fallback: "Medicaid letter")
      /// Medical bill
      public static let medical = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.medical", fallback: "Medical bill")
      /// Mortgage Statement
      public static let mortgae = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.mortgae", fallback: "Mortgage Statement")
      /// School records
      public static let schoolRecords = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.schoolRecords", fallback: "School records")
      /// Secondary Document - Any document that can be used as secondary verification document
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.title", fallback: "Secondary Document - Any document that can be used as secondary verification document")
      /// Utility bill
      public static let utility = LFLocalizable.tr("Localizable", "uploadDocument.secondaryRequirement.utility", fallback: "Utility bill")
    }
    public enum SsnRequirement {
      /// Social Security card
      public static let socialSecurity = LFLocalizable.tr("Localizable", "uploadDocument.ssnRequirement.socialSecurity", fallback: "Social Security card")
      /// SSN document
      public static let title = LFLocalizable.tr("Localizable", "uploadDocument.ssnRequirement.title", fallback: "SSN document")
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
      /// The AvalancheCard is an easy way to earn Avalanche with everyday purchases. You can also buy, sell and spend Avalanche with the AvalancheCard app.
      public static let desc = LFLocalizable.tr("Localizable", "welcome.header.desc", fallback: "The AvalancheCard is an easy way to earn Avalanche with everyday purchases. You can also buy, sell and spend Avalanche with the AvalancheCard app.")
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
