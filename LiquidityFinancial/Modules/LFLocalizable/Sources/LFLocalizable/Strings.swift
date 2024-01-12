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
  /// YOUR RESIDENTIAL ADDRESS
  public static let addressTitle = LFLocalizable.tr("Localizable", "address_title", fallback: "YOUR RESIDENTIAL ADDRESS")
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
  /// Something went wrong, please try again.
  public static let genericErrorMessage = LFLocalizable.tr("Localizable", "generic_ErrorMessage", fallback: "Something went wrong, please try again.")
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
  public enum BlockingFiatView {
    /// ATTENTION
    public static let attention = LFLocalizable.tr("Localizable", "BlockingFiatView.attention", fallback: "ATTENTION")
    /// DogeCard checking accounts and cards have been temporarily turned off while we onboard to our new banking partners.  Any balance, or credit to your accounts or cards will be mailed to your address on file.
    /// 
    /// We will be in touch shortly to invite you to get your new card.
    public static let description = LFLocalizable.tr("Localizable", "BlockingFiatView.description", fallback: "DogeCard checking accounts and cards have been temporarily turned off while we onboard to our new banking partners.  Any balance, or credit to your accounts or cards will be mailed to your address on file.\n\nWe will be in touch shortly to invite you to get your new card.")
    /// BANKING PARTNER UPDATE
    public static let title = LFLocalizable.tr("Localizable", "BlockingFiatView.title", fallback: "BANKING PARTNER UPDATE")
  }
  public enum ChangeRewardView {
    /// How would you like your rewards?
    public static let caption = LFLocalizable.tr("Localizable", "ChangeRewardView.caption", fallback: "How would you like your rewards?")
    /// Current Rewards
    public static let currentRewards = LFLocalizable.tr("Localizable", "ChangeRewardView.current_rewards", fallback: "Current Rewards")
    /// Select Rewards
    public static let title = LFLocalizable.tr("Localizable", "ChangeRewardView.title", fallback: "Select Rewards")
  }
  public enum ConfirmSendCryptoView {
    /// Amount
    public static let amount = LFLocalizable.tr("Localizable", "ConfirmSendCryptoView.amount", fallback: "Amount")
    /// Fee
    public static let fee = LFLocalizable.tr("Localizable", "ConfirmSendCryptoView.fee", fallback: "Fee")
    /// Confirm Transfer
    public static let title = LFLocalizable.tr("Localizable", "ConfirmSendCryptoView.title", fallback: "Confirm Transfer")
    /// To
    public static let to = LFLocalizable.tr("Localizable", "ConfirmSendCryptoView.to", fallback: "To")
    /// Wallet address
    public static let walletAddress = LFLocalizable.tr("Localizable", "ConfirmSendCryptoView.wallet_address", fallback: "Wallet address")
    public enum Send {
      /// Send
      public static let title = LFLocalizable.tr("Localizable", "ConfirmSendCryptoView.send.title", fallback: "Send")
    }
  }
  public enum EnterCryptoAddressView {
    /// SEND %@
    public static func title(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "EnterCryptoAddressView.title", String(describing: p1), fallback: "SEND %@")
    }
    /// Sending to a non - %@ wallet will result in lost funds
    public static func warning(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "EnterCryptoAddressView.warning", String(describing: p1), fallback: "Sending to a non - %@ wallet will result in lost funds")
    }
    public enum DeletePopup {
      /// Would you like to delete saved wallet: %@?
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "EnterCryptoAddressView.delete_popup.message", String(describing: p1), fallback: "Would you like to delete saved wallet: %@?")
      }
      /// Delete
      public static let primaryButton = LFLocalizable.tr("Localizable", "EnterCryptoAddressView.delete_popup.primary_button", fallback: "Delete")
      /// Delete Saved wallet address
      public static let title = LFLocalizable.tr("Localizable", "EnterCryptoAddressView.delete_popup.title", fallback: "Delete Saved wallet address")
    }
    public enum DeleteSuccess {
      /// Wallet address deleted
      public static let message = LFLocalizable.tr("Localizable", "EnterCryptoAddressView.delete_success.message", fallback: "Wallet address deleted")
    }
    public enum SaveSuccess {
      /// Wallet address saved
      public static let message = LFLocalizable.tr("Localizable", "EnterCryptoAddressView.save_success.message", fallback: "Wallet address saved")
    }
    public enum WalletAddress {
      /// Name, or Wallet Address
      public static let placeholder = LFLocalizable.tr("Localizable", "EnterCryptoAddressView.wallet_address.placeholder", fallback: "Name, or Wallet Address")
      /// %@ Wallet Address
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "EnterCryptoAddressView.wallet_address.title", String(describing: p1), fallback: "%@ Wallet Address")
      }
    }
  }
  public enum MoveCryptoInput {
    public enum Buy {
      /// You currently have %@ available to buy Dogecoin. If this amount is less than expected, please contact support.
      public static func annotation(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.buy.annotation", String(describing: p1), fallback: "You currently have %@ available to buy Dogecoin. If this amount is less than expected, please contact support.")
      }
      /// BUY %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.buy.title", String(describing: p1), fallback: "BUY %@")
      }
    }
    public enum BuyAvailableBalance {
      /// %@ available
      public static func subtitle(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.buyAvailableBalance.subtitle", String(describing: p1), fallback: "%@ available")
      }
    }
    public enum InsufficientFunds {
      /// Insufficient funds
      public static let description = LFLocalizable.tr("Localizable", "MoveCryptoInput.insufficientFunds.description", fallback: "Insufficient funds")
    }
    public enum MinimumCash {
      /// Minimum amount should be $0.10
      public static let description = LFLocalizable.tr("Localizable", "MoveCryptoInput.minimumCash.description", fallback: "Minimum amount should be $0.10")
    }
    public enum Sell {
      /// You currently have %@ Dogecoin available to sell. Doge Rewards are not available to sell until 48 hours after they are earned.
      public static func annotation(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.sell.annotation", String(describing: p1), fallback: "You currently have %@ Dogecoin available to sell. Doge Rewards are not available to sell until 48 hours after they are earned.")
      }
      /// SELL %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.sell.title", String(describing: p1), fallback: "SELL %@")
      }
    }
    public enum SellAvailableBalance {
      /// %@ %@ available
      public static func subtitle(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.sellAvailableBalance.subtitle", String(describing: p1), String(describing: p2), fallback: "%@ %@ available")
      }
    }
    public enum Send {
      /// You currently have %@ %@ available to send. If this amount is less than expected, please contact support.
      public static func annotation(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.send.annotation", String(describing: p1), String(describing: p2), fallback: "You currently have %@ %@ available to send. If this amount is less than expected, please contact support.")
      }
      /// The estimated network fee is an approximation and the actual network fee applied on a withdrawal may differ.
      public static let estimatedFee = LFLocalizable.tr("Localizable", "MoveCryptoInput.send.estimated_fee", fallback: "The estimated network fee is an approximation and the actual network fee applied on a withdrawal may differ.")
      /// SEND %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.send.title", String(describing: p1), fallback: "SEND %@")
      }
    }
    public enum SendAvailableBalance {
      /// %@ %@ available
      public static func subtitle(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "MoveCryptoInput.sendAvailableBalance.subtitle", String(describing: p1), String(describing: p2), fallback: "%@ %@ available")
      }
    }
  }
  public enum RewardTabView {
    /// Latest rewards
    public static let lastestRewards = LFLocalizable.tr("Localizable", "RewardTabView.lastest_rewards", fallback: "Latest rewards")
    /// No rewards yet
    public static let noRewards = LFLocalizable.tr("Localizable", "RewardTabView.noRewards", fallback: "No rewards yet")
    /// See all
    public static let seeAll = LFLocalizable.tr("Localizable", "RewardTabView.see_all", fallback: "See all")
    public enum EarningRewards {
      /// Earning rewards in %@
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "RewardTabView.earning_rewards.description", String(describing: p1), fallback: "Earning rewards in %@")
      }
    }
    public enum FirstReward {
      /// Select Reward
      public static let select = LFLocalizable.tr("Localizable", "RewardTabView.firstReward.select", fallback: "Select Reward")
      /// CHOOSE BETWEEN
      public static let title = LFLocalizable.tr("Localizable", "RewardTabView.firstReward.title", fallback: "CHOOSE BETWEEN")
    }
  }
  public enum Account {
    public enum Reward {
      /// We were unable to load Reward right now.
      /// Please try again.
      public static let error = LFLocalizable.tr("Localizable", "account.reward.error", fallback: "We were unable to load Reward right now.\nPlease try again.")
      /// Retry
      public static let retry = LFLocalizable.tr("Localizable", "account.reward.retry", fallback: "Retry")
      public enum Empty {
        /// There are currently no rewards
        public static let message = LFLocalizable.tr("Localizable", "account.reward.empty.message", fallback: "There are currently no rewards")
        /// NO REWARDS
        public static let title = LFLocalizable.tr("Localizable", "account.reward.empty.title", fallback: "NO REWARDS")
      }
      public enum Item {
        /// %@%% back
        public static func descUpToBack(_ p1: Any) -> String {
          return LFLocalizable.tr("Localizable", "account.reward.item.desc_up_to_back", String(describing: p1), fallback: "%@%% back")
        }
        /// Qualifying purchases
        public static let title = LFLocalizable.tr("Localizable", "account.reward.item.title", fallback: "Qualifying purchases")
      }
      public enum Session {
        /// Rewards by Asset Type
        public static let normal = LFLocalizable.tr("Localizable", "account.reward.session.normal", fallback: "Rewards by Asset Type")
        /// Special Promotions
        public static let special = LFLocalizable.tr("Localizable", "account.reward.session.special", fallback: "Special Promotions")
      }
    }
    public enum SpendingReward {
      /// Spending %@
      public static func normal(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "account.spendingReward.normal", String(describing: p1), fallback: "Spending %@")
      }
    }
  }
  public enum AccountLocked {
    public enum ContactSupport {
      /// Your account was locked due to too many verification attempts. Please
      /// contact support.
      public static let description = LFLocalizable.tr("Localizable", "accountLocked.contactSupport.description", fallback: "Your account was locked due to too many verification attempts. Please\ncontact support.")
      /// CONTACT SUPPORT
      public static let title = LFLocalizable.tr("Localizable", "accountLocked.contactSupport.title", fallback: "CONTACT SUPPORT")
    }
  }
  public enum AccountMigrationView {
    /// Your account is currently in the migration process. Please be patient; you will be able to log in to your account soon.
    public static let description = LFLocalizable.tr("Localizable", "accountMigrationView.description", fallback: "Your account is currently in the migration process. Please be patient; you will be able to log in to your account soon.")
    /// ACCOUNT IN MIGRATION
    public static let title = LFLocalizable.tr("Localizable", "accountMigrationView.title", fallback: "ACCOUNT IN MIGRATION")
  }
  public enum AccountView {
    /// ATM’s Nearby
    public static let atm = LFLocalizable.tr("Localizable", "accountView.atm", fallback: "ATM’s Nearby")
    /// ATM Locations
    public static let atmLocationTitle = LFLocalizable.tr("Localizable", "accountView.atm_location_title", fallback: "ATM Locations")
    /// Bank Statements
    public static let bankStatements = LFLocalizable.tr("Localizable", "accountView.bank_statements", fallback: "Bank Statements")
    /// Account
    public static let cardAccountDetails = LFLocalizable.tr("Localizable", "accountView.card_account_details", fallback: "Account")
    /// Connect
    public static let connectNewAccounts = LFLocalizable.tr("Localizable", "accountView.connect_new_accounts", fallback: "Connect")
    /// Connected Accounts
    public static let connectedAccounts = LFLocalizable.tr("Localizable", "accountView.connected_accounts", fallback: "Connected Accounts")
    /// Deposit Limits
    public static let depositLimits = LFLocalizable.tr("Localizable", "accountView.deposit_limits", fallback: "Deposit Limits")
    /// Help & Support
    public static let helpSupport = LFLocalizable.tr("Localizable", "accountView.help_support", fallback: "Help & Support")
    /// Legal
    public static let legal = LFLocalizable.tr("Localizable", "accountView.legal", fallback: "Legal")
    /// Limits
    public static let limits = LFLocalizable.tr("Localizable", "accountView.limits", fallback: "Limits")
    /// Enable Notifications
    public static let notifications = LFLocalizable.tr("Localizable", "accountView.notifications", fallback: "Enable Notifications")
    /// Current Rewards
    public static let rewards = LFLocalizable.tr("Localizable", "accountView.rewards", fallback: "Current Rewards")
    /// Shortcuts
    public static let shortcuts = LFLocalizable.tr("Localizable", "accountView.shortcuts", fallback: "Shortcuts")
    /// Taxes
    public static let taxes = LFLocalizable.tr("Localizable", "accountView.taxes", fallback: "Taxes")
    /// Wallets
    public static let wallets = LFLocalizable.tr("Localizable", "accountView.wallets", fallback: "Wallets")
    public enum AccountNumber {
      /// Account Number
      public static let title = LFLocalizable.tr("Localizable", "accountView.accountNumber.title", fallback: "Account Number")
    }
    public enum BankTransfers {
      /// Send from your bank to AvalancheCard
      public static let subtitle = LFLocalizable.tr("Localizable", "accountView.bank_transfers.subtitle", fallback: "Send from your bank to AvalancheCard")
      /// Bank Transfers
      public static let title = LFLocalizable.tr("Localizable", "accountView.bank_transfers.title", fallback: "Bank Transfers")
    }
    public enum DebitDeposits {
      /// Use your Debit Card
      public static let subtitle = LFLocalizable.tr("Localizable", "accountView.debit_deposits.subtitle", fallback: "Use your Debit Card")
      /// Instant Deposits
      public static let title = LFLocalizable.tr("Localizable", "accountView.debit_deposits.title", fallback: "Instant Deposits")
    }
    public enum DebitDepositsFunds {
      /// Connect your bank with a Debit Card
      public static let subtitle = LFLocalizable.tr("Localizable", "accountView.debit_deposits_funds.subtitle", fallback: "Connect your bank with a Debit Card")
    }
    public enum DirectDeposit {
      /// Deposit part, or all of your paycheck
      public static let subtitle = LFLocalizable.tr("Localizable", "accountView.direct_deposit.subtitle", fallback: "Deposit part, or all of your paycheck")
      /// Direct Deposit
      public static let title = LFLocalizable.tr("Localizable", "accountView.direct_deposit.title", fallback: "Direct Deposit")
    }
    public enum Disclosure {
      /// The DogeCard pre-paid debit card is established by Pathward, National Association Member FDIC, pursuant to license by Visa. Netspend is a service provider to Pathward. Cryptocurrency services provided by Zero Hash. Cryptocurrency is not insured by, or subject to the protections of the FDIC.
      public static let message = LFLocalizable.tr("Localizable", "accountView.disclosure.message", fallback: "The DogeCard pre-paid debit card is established by Pathward, National Association Member FDIC, pursuant to license by Visa. Netspend is a service provider to Pathward. Cryptocurrency services provided by Zero Hash. Cryptocurrency is not insured by, or subject to the protections of the FDIC.")
    }
    public enum HiddenValue {
      /// **** %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "accountView.hiddenValue.title", String(describing: p1), fallback: "**** %@")
      }
    }
    public enum OneTimeTransfers {
      /// Connect an external bank with Plaid
      public static let subtitle = LFLocalizable.tr("Localizable", "accountView.one_time_transfers.subtitle", fallback: "Connect an external bank with Plaid")
      /// Bank Transfers
      public static let title = LFLocalizable.tr("Localizable", "accountView.one_time_transfers.title", fallback: "Bank Transfers")
    }
    public enum RoutingNumber {
      /// Routing Number
      public static let title = LFLocalizable.tr("Localizable", "accountView.routingNumber.title", fallback: "Routing Number")
    }
    public enum Wallet {
      /// %@ Wallet
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "accountView.wallet.title", String(describing: p1), fallback: "%@ Wallet")
      }
    }
  }
  public enum AddBankWithDebit {
    /// Card number
    public static let cardNumber = LFLocalizable.tr("Localizable", "addBankWithDebit.card_number", fallback: "Card number")
    /// 1234 5678 9012 3456
    public static let cardNumberPlaceholder = LFLocalizable.tr("Localizable", "addBankWithDebit.card_number_placeholder", fallback: "1234 5678 9012 3456")
    /// CVV
    public static let cvv = LFLocalizable.tr("Localizable", "addBankWithDebit.cvv", fallback: "CVV")
    /// Enter CVV
    public static let cvvPlaceholder = LFLocalizable.tr("Localizable", "addBankWithDebit.cvv_placeholder", fallback: "Enter CVV")
    /// Expires
    public static let expires = LFLocalizable.tr("Localizable", "addBankWithDebit.expires", fallback: "Expires")
    /// MM / YY
    public static let expiresPlaceholder = LFLocalizable.tr("Localizable", "addBankWithDebit.expires_placeholder", fallback: "MM / YY")
    /// ADD A BANK USING YOUR DEBIT CARD
    public static let title = LFLocalizable.tr("Localizable", "addBankWithDebit.title", fallback: "ADD A BANK USING YOUR DEBIT CARD")
  }
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
  public enum AlertAttributedText {
    /// 83-01252270
    public static let ein = LFLocalizable.tr("Localizable", "alert_attributed_text.ein", fallback: "83-01252270")
    /// Privacy Policy
    public static let privacy = LFLocalizable.tr("Localizable", "alert_attributed_text.privacy", fallback: "Privacy Policy")
    /// Round up spare change to the nearest dollar when you use your CauseCard. It's an easy way to make a big impact over time.
    /// 
    /// Round up donations made to ShoppingGives Foundation EIN: %@. 100%% of funds granted to designated nonprofit - %@ and %@.
    public static func roundUp(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
      return LFLocalizable.tr("Localizable", "alert_attributed_text.round_up", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "Round up spare change to the nearest dollar when you use your CauseCard. It's an easy way to make a big impact over time.\n\nRound up donations made to ShoppingGives Foundation EIN: %@. 100%% of funds granted to designated nonprofit - %@ and %@.")
    }
    /// Donations made to ShoppingGives Foundation EIN: %@.
    /// 100%% of funds granted to designated nonprofit - %@ and %@.
    public static func taxDeductions(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
      return LFLocalizable.tr("Localizable", "alert_attributed_text.tax_deductions", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "Donations made to ShoppingGives Foundation EIN: %@.\n100%% of funds granted to designated nonprofit - %@ and %@.")
    }
    /// Terms & Conditions
    public static let terms = LFLocalizable.tr("Localizable", "alert_attributed_text.terms", fallback: "Terms & Conditions")
  }
  public enum AssetView {
    /// Cryptocurrency services powered by Zero Hash
    public static let disclosure = LFLocalizable.tr("Localizable", "assetView.disclosure", fallback: "Cryptocurrency services powered by Zero Hash")
    /// See all
    public static let seeAll = LFLocalizable.tr("Localizable", "assetView.see_all", fallback: "See all")
    /// Today
    public static let today = LFLocalizable.tr("Localizable", "assetView.today", fallback: "Today")
    /// Wallet address
    public static let walletAddress = LFLocalizable.tr("Localizable", "assetView.wallet_address", fallback: "Wallet address")
    public enum Buy {
      /// Buy
      public static let title = LFLocalizable.tr("Localizable", "assetView.buy.title", fallback: "Buy")
    }
    public enum Receive {
      /// Receive
      public static let title = LFLocalizable.tr("Localizable", "assetView.receive.title", fallback: "Receive")
    }
    public enum Sell {
      /// Sell
      public static let title = LFLocalizable.tr("Localizable", "assetView.sell.title", fallback: "Sell")
    }
    public enum Send {
      /// Send
      public static let title = LFLocalizable.tr("Localizable", "assetView.send.title", fallback: "Send")
    }
    public enum Transfer {
      /// Transfer
      public static let title = LFLocalizable.tr("Localizable", "assetView.transfer.title", fallback: "Transfer")
    }
    public enum TransferPopup {
      /// TRANSFER
      public static let title = LFLocalizable.tr("Localizable", "assetView.transfer_popup.title", fallback: "TRANSFER")
    }
  }
  public enum Authentication {
    public enum BiometricsAuthenticationLocalizedFallback {
      /// Use Backup Options
      public static let title = LFLocalizable.tr("Localizable", "authentication.biometrics_authentication_localizedFallback.title", fallback: "Use Backup Options")
    }
    public enum BiometricsBackup {
      public enum BiomericsButton {
        /// Login with %@
        public static func title(_ p1: Any) -> String {
          return LFLocalizable.tr("Localizable", "authentication.biometrics_backup.biomerics_button.title", String(describing: p1), fallback: "Login with %@")
        }
      }
      public enum PasswordButton {
        /// Login with Password
        public static let title = LFLocalizable.tr("Localizable", "authentication.biometrics_backup.password_button.title", fallback: "Login with Password")
      }
    }
    public enum BiometricsBackupLocalizedFallback {
      /// Use Password Instead
      public static let title = LFLocalizable.tr("Localizable", "authentication.biometrics_backup_localizedFallback.title", fallback: "Use Password Instead")
    }
    public enum BiometricsEnableLocalizedFallback {
      /// Try Again
      public static let title = LFLocalizable.tr("Localizable", "authentication.biometrics_enable_localizedFallback.title", fallback: "Try Again")
    }
    public enum BiometricsFaceID {
      /// Face ID
      public static let title = LFLocalizable.tr("Localizable", "authentication.biometrics_faceID.title", fallback: "Face ID")
    }
    public enum BiometricsLocalizedReason {
      /// Unlock your account
      public static let title = LFLocalizable.tr("Localizable", "authentication.biometrics_localized_reason.title", fallback: "Unlock your account")
    }
    public enum BiometricsLockoutError {
      /// Unable to use %@
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "authentication.biometrics_lockout_error.message", String(describing: p1), fallback: "Unable to use %@")
      }
      /// %@ attempts exceeded
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "authentication.biometrics_lockout_error.title", String(describing: p1), fallback: "%@ attempts exceeded")
      }
    }
    public enum BiometricsNotEnrolled {
      /// %@ is not enabled on your device. Please go to your phone’s settings to turn it on
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "authentication.biometrics_notEnrolled.message", String(describing: p1), fallback: "%@ is not enabled on your device. Please go to your phone’s settings to turn it on")
      }
      /// %@ is not enrolled
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "authentication.biometrics_notEnrolled.title", String(describing: p1), fallback: "%@ is not enrolled")
      }
    }
    public enum BiometricsTouchID {
      /// Touch ID
      public static let title = LFLocalizable.tr("Localizable", "authentication.biometrics_touchID.title", fallback: "Touch ID")
    }
    public enum ChangePassword {
      /// CHANGE PASSWORD
      public static let title = LFLocalizable.tr("Localizable", "authentication.change_password.title", fallback: "CHANGE PASSWORD")
      public enum Current {
        /// Enter current password
        public static let placeholder = LFLocalizable.tr("Localizable", "authentication.change_password.current.placeholder", fallback: "Enter current password")
        /// Enter your current password
        public static let title = LFLocalizable.tr("Localizable", "authentication.change_password.current.title", fallback: "Enter your current password")
      }
      public enum New {
        /// Create new password
        public static let placeholder = LFLocalizable.tr("Localizable", "authentication.change_password.new.placeholder", fallback: "Create new password")
        /// New password
        public static let title = LFLocalizable.tr("Localizable", "authentication.change_password.new.title", fallback: "New password")
      }
      public enum SuccessPopup {
        /// PASSWORD CHANGED SUCCESSFULLY!
        public static let title = LFLocalizable.tr("Localizable", "authentication.change_password.success_popup.title", fallback: "PASSWORD CHANGED SUCCESSFULLY!")
      }
    }
    public enum CreatePassword {
      /// Must be at least 8 characters
      public static let desc1 = LFLocalizable.tr("Localizable", "authentication.create_password.desc_1", fallback: "Must be at least 8 characters")
      /// Must have 1 special character including @ #$ %
      public static let desc2 = LFLocalizable.tr("Localizable", "authentication.create_password.desc_2", fallback: "Must have 1 special character including @ #$ %")
      /// Must be 1 lower case and 1 upper case
      public static let desc3 = LFLocalizable.tr("Localizable", "authentication.create_password.desc_3", fallback: "Must be 1 lower case and 1 upper case")
      /// Create a new password
      public static let subTitle1 = LFLocalizable.tr("Localizable", "authentication.create_password.sub_title_1", fallback: "Create a new password")
      /// Enter new password
      public static let subTitle2 = LFLocalizable.tr("Localizable", "authentication.create_password.sub_title_2", fallback: "Enter new password")
      /// Re-enter password
      public static let subTitle3 = LFLocalizable.tr("Localizable", "authentication.create_password.sub_title_3", fallback: "Re-enter password")
      /// Re-Enter password
      public static let subTitle4 = LFLocalizable.tr("Localizable", "authentication.create_password.sub_title_4", fallback: "Re-Enter password")
      /// create password
      public static let title = LFLocalizable.tr("Localizable", "authentication.create_password.title", fallback: "create password")
      /// Passwords don't match
      public static let warning = LFLocalizable.tr("Localizable", "authentication.create_password.warning", fallback: "Passwords don't match")
      public enum SuccessPopup {
        /// PASSWORD CREATED SUCCESSFULLY!
        public static let title = LFLocalizable.tr("Localizable", "authentication.create_password.success_popup.title", fallback: "PASSWORD CREATED SUCCESSFULLY!")
      }
    }
    public enum DeviceLocalizedReason {
      /// Authorize sensitive transactions.
      public static let title = LFLocalizable.tr("Localizable", "authentication.device_localized_reason.title", fallback: "Authorize sensitive transactions.")
    }
    public enum EnterPassword {
      /// Forgot Password
      public static let forgotPasswordButton = LFLocalizable.tr("Localizable", "authentication.enter_password.forgotPasswordButton", fallback: "Forgot Password")
      /// Enter password
      public static let placeholder = LFLocalizable.tr("Localizable", "authentication.enter_password.placeholder", fallback: "Enter password")
      /// Enter Password
      public static let title = LFLocalizable.tr("Localizable", "authentication.enter_password.title", fallback: "Enter Password")
      public enum Error {
        /// Wrong password
        public static let wrongPassword = LFLocalizable.tr("Localizable", "authentication.enter_password.error.wrong_password", fallback: "Wrong password")
      }
    }
    public enum EnterTotp {
      /// Lost your device? 
      public static let bottomDisclosure = LFLocalizable.tr("Localizable", "authentication.enter_totp.bottom_disclosure", fallback: "Lost your device? ")
      /// MFA TURNED OFF
      public static let mfaTurnedOff = LFLocalizable.tr("Localizable", "authentication.enter_totp.mfa_turnedOff", fallback: "MFA TURNED OFF")
      /// ENTER Code from authenticator app
      public static let title = LFLocalizable.tr("Localizable", "authentication.enter_totp.title", fallback: "ENTER Code from authenticator app")
      /// Use Recovery Code
      public static let useRecoveryCodeAttributeText = LFLocalizable.tr("Localizable", "authentication.enter_totp.use_recovery_code_attributeText", fallback: "Use Recovery Code")
    }
    public enum RecoveryCode {
      /// Enter recovery code
      public static let enterCodePlaceholder = LFLocalizable.tr("Localizable", "authentication.recovery_code.enter_code_placeholder", fallback: "Enter recovery code")
      /// MFA RECOVERED
      public static let mfaRecovered = LFLocalizable.tr("Localizable", "authentication.recovery_code.mfa_recovered", fallback: "MFA RECOVERED")
      /// ENTER RECOVERY CODE
      public static let title = LFLocalizable.tr("Localizable", "authentication.recovery_code.title", fallback: "ENTER RECOVERY CODE")
    }
    public enum ResetPassword {
      /// ENTER 6 DIGIT CODE
      public static let enterCode = LFLocalizable.tr("Localizable", "authentication.reset_password.enter_code", fallback: "ENTER 6 DIGIT CODE")
      /// OR
      public static let or = LFLocalizable.tr("Localizable", "authentication.reset_password.or", fallback: "OR")
      /// Please check your email for 6 Digit Code
      public static let subtitle = LFLocalizable.tr("Localizable", "authentication.reset_password.subtitle", fallback: "Please check your email for 6 Digit Code")
      /// RESET PASSWORD
      public static let title = LFLocalizable.tr("Localizable", "authentication.reset_password.title", fallback: "RESET PASSWORD")
      public enum ResendCodeButton {
        /// Resend Code
        public static let title = LFLocalizable.tr("Localizable", "authentication.reset_password.resend_code_button.title", fallback: "Resend Code")
      }
      public enum SuccessPopup {
        /// PASSWORD RESET SUCCESSFULLY!
        public static let title = LFLocalizable.tr("Localizable", "authentication.reset_password.success_popup.title", fallback: "PASSWORD RESET SUCCESSFULLY!")
      }
    }
    public enum Security {
      /// Security
      public static let title = LFLocalizable.tr("Localizable", "authentication.security.title", fallback: "Security")
    }
    public enum SecurityAuthenticationApp {
      /// Authentication App
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_authenticationApp.title", fallback: "Authentication App")
    }
    public enum SecurityChangePassword {
      /// Change
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_changePassword.title", fallback: "Change")
    }
    public enum SecurityEmail {
      /// Email
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_email.title", fallback: "Email")
    }
    public enum SecurityMfa {
      /// MFA
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_mfa.title", fallback: "MFA")
    }
    public enum SecurityPassword {
      /// Password
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_password.title", fallback: "Password")
    }
    public enum SecurityPhone {
      /// Phone
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_phone.title", fallback: "Phone")
    }
    public enum SecurityRequireMFAFor {
      /// Adding External Bank
      public static let addingExternalBank = LFLocalizable.tr("Localizable", "authentication.security_requireMFAFor.addingExternalBank", fallback: "Adding External Bank")
      /// New Device Login
      public static let newDeviceLogin = LFLocalizable.tr("Localizable", "authentication.security_requireMFAFor.newDeviceLogin", fallback: "New Device Login")
      /// Require MFA for
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_requireMFAFor.title", fallback: "Require MFA for")
      /// Withdrawal over %@
      public static func withdrawal(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "authentication.security_requireMFAFor.withdrawal", String(describing: p1), fallback: "Withdrawal over %@")
      }
    }
    public enum SecurityVerified {
      /// Verified
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_verified.title", fallback: "Verified")
    }
    public enum SecurityVerify {
      /// Verify
      public static let title = LFLocalizable.tr("Localizable", "authentication.security_verify.title", fallback: "Verify")
    }
    public enum SetupBiometrics {
      /// %@ will use %@ to unlock your account.
      public static func description(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "authentication.setup_biometrics.description", String(describing: p1), String(describing: p2), fallback: "%@ will use %@ to unlock your account.")
      }
      /// Do you want to allow “%@“ to use %@?
      public static func title(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "authentication.setup_biometrics.title", String(describing: p1), String(describing: p2), fallback: "Do you want to allow “%@“ to use %@?")
      }
    }
    public enum SetupEnhancedSecurity {
      /// We are improving the safety and security of our products by adding several new features aimed to keep you and your financial information safe.
      /// 
      /// • SET UP FaceID or TouchID
      public static let biometricsStep = LFLocalizable.tr("Localizable", "authentication.setup_enhanced_security.biometricsStep", fallback: "We are improving the safety and security of our products by adding several new features aimed to keep you and your financial information safe.\n\n• SET UP FaceID or TouchID")
      /// We are improving the safety and security of our products by adding several new features aimed to keep you and your financial information safe.
      /// 
      /// • Create Password
      /// • SET UP FaceID or TouchID
      public static let fullStep = LFLocalizable.tr("Localizable", "authentication.setup_enhanced_security.fullStep", fallback: "We are improving the safety and security of our products by adding several new features aimed to keep you and your financial information safe.\n\n• Create Password\n• SET UP FaceID or TouchID")
      /// SETUP ENHANCED SECURITY
      public static let title = LFLocalizable.tr("Localizable", "authentication.setup_enhanced_security.title", fallback: "SETUP ENHANCED SECURITY")
    }
    public enum SetupMfa {
      /// We highly recommend that you enable Two-Factor Authentication. It ties your login information to a mobile device, making it much harder for someone to hack into your account.
      public static let description = LFLocalizable.tr("Localizable", "authentication.setup_mfa.description", fallback: "We highly recommend that you enable Two-Factor Authentication. It ties your login information to a mobile device, making it much harder for someone to hack into your account.")
      /// You must have Google Authenticator or Authy installed on your phone.
      public static let downloadAppDescription = LFLocalizable.tr("Localizable", "authentication.setup_mfa.download_app_description", fallback: "You must have Google Authenticator or Authy installed on your phone.")
      /// Download App
      public static let downloadAppTitle = LFLocalizable.tr("Localizable", "authentication.setup_mfa.download_app_title", fallback: "Download App")
      /// Enter Code
      public static let enterCodePlaceHolder = LFLocalizable.tr("Localizable", "authentication.setup_mfa.enter_code_placeHolder", fallback: "Enter Code")
      /// Enter Code
      public static let enterCodeTitle = LFLocalizable.tr("Localizable", "authentication.setup_mfa.enter_code_title", fallback: "Enter Code")
      /// MFA TURNED ON
      public static let mfaTurnedOn = LFLocalizable.tr("Localizable", "authentication.setup_mfa.mfa_turnedOn", fallback: "MFA TURNED ON")
      /// I have safely recorded this code
      public static let recoveryCodeCheckBoxTitle = LFLocalizable.tr("Localizable", "authentication.setup_mfa.recoveryCode_checkBox_title", fallback: "I have safely recorded this code")
      /// Copy code
      public static let recoveryCodeCopyCodeButton = LFLocalizable.tr("Localizable", "authentication.setup_mfa.recoveryCode_copyCode_button", fallback: "Copy code")
      /// Copy this recovery code and keep it somewhere  safe, You’ll need it if you ever need to log in without your device
      public static let recoveryCodePopupMessage = LFLocalizable.tr("Localizable", "authentication.setup_mfa.recoveryCode_popup_message", fallback: "Copy this recovery code and keep it somewhere  safe, You’ll need it if you ever need to log in without your device")
      /// Almost there!
      public static let recoveryCodePopupTitle = LFLocalizable.tr("Localizable", "authentication.setup_mfa.recoveryCode_popup_title", fallback: "Almost there!")
      /// Open the app and scan the QR Code image below or enter your key manually:
      public static let scanQrCodeDescription = LFLocalizable.tr("Localizable", "authentication.setup_mfa.scan_qrCode_description", fallback: "Open the app and scan the QR Code image below or enter your key manually:")
      /// Scan QR code
      public static let scanQrCodeTitle = LFLocalizable.tr("Localizable", "authentication.setup_mfa.scan_qrCode_title", fallback: "Scan QR code")
      /// TURN ON MFA WITH AUTHENTICATOR APP
      public static let title = LFLocalizable.tr("Localizable", "authentication.setup_mfa.title", fallback: "TURN ON MFA WITH AUTHENTICATOR APP")
      /// Open the app and scan the QR Code image below or enter your key manually:
      public static let verify2faCodeDescription = LFLocalizable.tr("Localizable", "authentication.setup_mfa.verify_2faCode_description", fallback: "Open the app and scan the QR Code image below or enter your key manually:")
      /// Verify your 2FA code
      public static let verify2faCodeTitle = LFLocalizable.tr("Localizable", "authentication.setup_mfa.verify_2faCode_title", fallback: "Verify your 2FA code")
    }
    public enum VerifyEmail {
      /// PLEASE CHECK YOUR EMAIL FOR A 6 DIGIT CODE
      public static let description = LFLocalizable.tr("Localizable", "authentication.verify_email.description", fallback: "PLEASE CHECK YOUR EMAIL FOR A 6 DIGIT CODE")
      /// ENTER CODE FROM EMAIL
      public static let title = LFLocalizable.tr("Localizable", "authentication.verify_email.title", fallback: "ENTER CODE FROM EMAIL")
      public enum SuccessPopup {
        /// EMAIL VERIFIED SUCCESSFULLY
        public static let title = LFLocalizable.tr("Localizable", "authentication.verify_email.success_popup.title", fallback: "EMAIL VERIFIED SUCCESSFULLY")
      }
    }
  }
  public enum BalanceAlert {
    /// Deposit
    public static let cta = LFLocalizable.tr("Localizable", "balanceAlert.cta", fallback: "Deposit")
    public enum Low {
      /// Your balance is below %@
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "balanceAlert.low.message", String(describing: p1), fallback: "Your balance is below %@")
      }
      /// Low Balance Alert
      public static let title = LFLocalizable.tr("Localizable", "balanceAlert.low.title", fallback: "Low Balance Alert")
    }
    public enum Negative {
      /// Negative Balance
      public static let title = LFLocalizable.tr("Localizable", "balanceAlert.negative.title", fallback: "Negative Balance")
      public enum Message {
        /// Please deposit cash
        public static let cash = LFLocalizable.tr("Localizable", "balanceAlert.negative.message.cash", fallback: "Please deposit cash")
        /// Please deposit Doge
        public static let crypto = LFLocalizable.tr("Localizable", "balanceAlert.negative.message.crypto", fallback: "Please deposit Doge")
      }
    }
  }
  public enum BankTransfers {
    public enum AccountNumber {
      /// Account number
      public static let title = LFLocalizable.tr("Localizable", "bankTransfers.accountNumber.title", fallback: "Account number")
    }
    public enum BulletOne {
      /// Login to your bank, and find the transfers section of your bank’s app or website
      public static let title = LFLocalizable.tr("Localizable", "bankTransfers.bulletOne.title", fallback: "Login to your bank, and find the transfers section of your bank’s app or website")
    }
    public enum BulletThree {
      /// Select CauseCard as the recipient and transfer up to $25k at a time.
      public static let title = LFLocalizable.tr("Localizable", "bankTransfers.bulletThree.title", fallback: "Select CauseCard as the recipient and transfer up to $25k at a time.")
    }
    public enum BulletTwo {
      /// If it’s your first transfer, you’ll need to add your CauseCard as an external account. Enter you routing and account number, and select Checking as account type.
      public static let title = LFLocalizable.tr("Localizable", "bankTransfers.bulletTwo.title", fallback: "If it’s your first transfer, you’ll need to add your CauseCard as an external account. Enter you routing and account number, and select Checking as account type.")
    }
    public enum Disclosure {
      /// Some banks require a one-time test deposit to verify your account. If so, check your %@Card transactions after 1-2 days, and enter the test deposit amounts in the bank’s app or website.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "bankTransfers.disclosure.message", String(describing: p1), fallback: "Some banks require a one-time test deposit to verify your account. If so, check your %@Card transactions after 1-2 days, and enter the test deposit amounts in the bank’s app or website.")
      }
    }
    public enum HowTo {
      /// How to transfer money from your bank to %@Card:
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "bankTransfers.howTo.title", String(describing: p1), fallback: "How to transfer money from your bank to %@Card:")
      }
    }
    public enum RoutingNumber {
      /// Rounting number
      public static let title = LFLocalizable.tr("Localizable", "bankTransfers.routingNumber.title", fallback: "Rounting number")
    }
    public enum Screen {
      /// BANK TRANSFERS
      public static let title = LFLocalizable.tr("Localizable", "bankTransfers.screen.title", fallback: "BANK TRANSFERS")
    }
  }
  public enum BankStatement {
    /// Created %@
    public static func created(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "bank_statement.created", String(describing: p1), fallback: "Created %@")
    }
    /// There are currently no bank statements
    public static let emptyInfo = LFLocalizable.tr("Localizable", "bank_statement.emptyInfo", fallback: "There are currently no bank statements")
    /// NO STATEMENTS
    public static let emptyTitle = LFLocalizable.tr("Localizable", "bank_statement.emptyTitle", fallback: "NO STATEMENTS")
    /// We were unable to load Bank Statementes right now.
    /// Please try again.
    public static let error = LFLocalizable.tr("Localizable", "bank_statement.error", fallback: "We were unable to load Bank Statementes right now.\nPlease try again.")
    /// Bank Statements
    public static let title = LFLocalizable.tr("Localizable", "bank_statement.title", fallback: "Bank Statements")
  }
  public enum Button {
    public enum Back {
      /// Back
      public static let title = LFLocalizable.tr("Localizable", "button.back.title", fallback: "Back")
    }
    public enum Confirm {
      /// Confirm
      public static let title = LFLocalizable.tr("Localizable", "button.confirm.title", fallback: "Confirm")
    }
    public enum ContactSupport {
      /// Contact Support
      public static let title = LFLocalizable.tr("Localizable", "button.contactSupport.title", fallback: "Contact Support")
    }
    public enum Continue {
      /// Continue
      public static let title = LFLocalizable.tr("Localizable", "button.continue.title", fallback: "Continue")
    }
    public enum DisputeTransaction {
      /// Dispute a Transaction
      public static let title = LFLocalizable.tr("Localizable", "button.disputeTransaction.title", fallback: "Dispute a Transaction")
    }
    public enum Done {
      /// Done
      public static let title = LFLocalizable.tr("Localizable", "button.done.title", fallback: "Done")
    }
    public enum DonotAllow {
      /// Don't Allow
      public static let title = LFLocalizable.tr("Localizable", "button.donotAllow.title", fallback: "Don't Allow")
    }
    public enum Logout {
      /// Log Out
      public static let title = LFLocalizable.tr("Localizable", "button.logout.title", fallback: "Log Out")
    }
    public enum No {
      /// No
      public static let title = LFLocalizable.tr("Localizable", "button.no.title", fallback: "No")
    }
    public enum NotNow {
      /// Not now
      public static let title = LFLocalizable.tr("Localizable", "button.notNow.title", fallback: "Not now")
    }
    public enum Ok {
      /// OK
      public static let title = LFLocalizable.tr("Localizable", "button.ok.title", fallback: "OK")
    }
    public enum Okay {
      /// Okay
      public static let title = LFLocalizable.tr("Localizable", "button.okay.title", fallback: "Okay")
    }
    public enum Retry {
      /// Retry
      public static let title = LFLocalizable.tr("Localizable", "button.retry.title", fallback: "Retry")
    }
    public enum Save {
      /// Save
      public static let title = LFLocalizable.tr("Localizable", "button.save.title", fallback: "Save")
    }
    public enum Share {
      /// Share
      public static let title = LFLocalizable.tr("Localizable", "button.share.title", fallback: "Share")
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
    public enum Verify {
      /// Verify
      public static let title = LFLocalizable.tr("Localizable", "button.verify.title", fallback: "Verify")
    }
    public enum Yes {
      /// Yes
      public static let title = LFLocalizable.tr("Localizable", "button.yes.title", fallback: "Yes")
    }
  }
  public enum CancelTransfer {
    /// Cancel Deposit
    public static let title = LFLocalizable.tr("Localizable", "cancelTransfer.title", fallback: "Cancel Deposit")
    public enum Fail {
      /// We were unable to cancel your deposit. Please try again or contact support.
      public static let message = LFLocalizable.tr("Localizable", "cancelTransfer.fail.message", fallback: "We were unable to cancel your deposit. Please try again or contact support.")
      /// Something went wrong
      public static let title = LFLocalizable.tr("Localizable", "cancelTransfer.fail.title", fallback: "Something went wrong")
    }
    public enum Success {
      /// Your deposit has been successfully cancelled.
      public static let message = LFLocalizable.tr("Localizable", "cancelTransfer.success.message", fallback: "Your deposit has been successfully cancelled.")
      /// Success!
      public static let title = LFLocalizable.tr("Localizable", "cancelTransfer.success.title", fallback: "Success!")
    }
  }
  public enum Card {
    public enum CardNumber {
      /// Card Number
      public static let title = LFLocalizable.tr("Localizable", "card.cardNumber.title", fallback: "Card Number")
    }
    public enum CopyToClipboard {
      /// Card number copied to clipboard
      public static let title = LFLocalizable.tr("Localizable", "card.copyToClipboard.title", fallback: "Card number copied to clipboard")
    }
    public enum Cvv {
      /// CVV
      public static let title = LFLocalizable.tr("Localizable", "card.cvv.title", fallback: "CVV")
    }
    public enum Exp {
      /// Exp
      public static let title = LFLocalizable.tr("Localizable", "card.exp.title", fallback: "Exp")
    }
    public enum Physical {
      /// %@Card
      public static func name(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "card.physical.name", String(describing: p1), fallback: "%@Card")
      }
      /// Physical
      public static let title = LFLocalizable.tr("Localizable", "card.physical.title", fallback: "Physical")
    }
    public enum Virtual {
      /// Virtual
      public static let title = LFLocalizable.tr("Localizable", "card.virtual.title", fallback: "Virtual")
    }
  }
  public enum CardActivated {
    public enum CardActived {
      /// Your card is activated!  Next, add it to your Apple Pay wallet for fast and easy payments.
      public static let description = LFLocalizable.tr("Localizable", "cardActivated.cardActived.description", fallback: "Your card is activated!  Next, add it to your Apple Pay wallet for fast and easy payments.")
      /// CARD ACTIVATED!
      public static let title = LFLocalizable.tr("Localizable", "cardActivated.cardActived.title", fallback: "CARD ACTIVATED!")
    }
  }
  public enum CardShare {
    /// I earned %@ back by using my Visa CauseCard. Get one here: %@
    public static func cashback(_ p1: Any, _ p2: Any) -> String {
      return LFLocalizable.tr("Localizable", "card_share.cashback", String(describing: p1), String(describing: p2), fallback: "I earned %@ back by using my Visa CauseCard. Get one here: %@")
    }
    /// I earned %@ by using my Visa CauseCard. Get one here: %@
    public static func crypto(_ p1: Any, _ p2: Any) -> String {
      return LFLocalizable.tr("Localizable", "card_share.crypto", String(describing: p1), String(describing: p2), fallback: "I earned %@ by using my Visa CauseCard. Get one here: %@")
    }
    /// Share
    public static let title = LFLocalizable.tr("Localizable", "card_share.title", fallback: "Share")
    public enum Message {
      /// Supporting %@ - %@.
      public static func donation(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "card_share.message.donation", String(describing: p1), String(describing: p2), fallback: "Supporting %@ - %@.")
      }
    }
    public enum Title {
      /// Cashback
      public static let cashback = LFLocalizable.tr("Localizable", "card_share.title.cashback", fallback: "Cashback")
      /// Donation
      public static let donation = LFLocalizable.tr("Localizable", "card_share.title.donation", fallback: "Donation")
    }
  }
  public enum CardsDetail {
    /// Available Limit
    public static let availableLimits = LFLocalizable.tr("Localizable", "cards_detail.available_limits", fallback: "Available Limit")
    /// Donations
    public static let donations = LFLocalizable.tr("Localizable", "cards_detail.donations", fallback: "Donations")
    /// Monthly Spend Limit
    public static let monthlyLimits = LFLocalizable.tr("Localizable", "cards_detail.monthly_limits", fallback: "Monthly Spend Limit")
    /// Per Transaction Limit
    public static let perTransactionLimits = LFLocalizable.tr("Localizable", "cards_detail.per_transaction_limits", fallback: "Per Transaction Limit")
    public enum Deals {
      /// Donate up to 8% of purchase
      public static func value(_ p1: Int) -> String {
        return LFLocalizable.tr("Localizable", "cards_detail.deals.value", p1, fallback: "Donate up to 8% of purchase")
      }
    }
    public enum Roundup {
      /// Round up purchases
      public static let desc = LFLocalizable.tr("Localizable", "cards_detail.roundup.desc", fallback: "Round up purchases")
      /// ROUND UP
      public static let title = LFLocalizable.tr("Localizable", "cards_detail.roundup.title", fallback: "ROUND UP")
    }
  }
  public enum CashCard {
    public enum Balance {
      /// Balance
      public static let title = LFLocalizable.tr("Localizable", "cashCard.balance.title", fallback: "Balance")
    }
  }
  public enum CashTab {
    public enum ChangeAsset {
      /// Change
      public static let buttonTitle = LFLocalizable.tr("Localizable", "cashTab.changeAsset.buttonTitle", fallback: "Change")
    }
    public enum CreateCard {
      /// Create Card
      public static let buttonTitle = LFLocalizable.tr("Localizable", "cashTab.createCard.buttonTitle", fallback: "Create Card")
    }
    public enum DeActiveError {
      /// Your checking account was deactivated
      public static let message = LFLocalizable.tr("Localizable", "cashTab.deActiveError.message", fallback: "Your checking account was deactivated")
    }
    public enum Deposit {
      /// Deposit
      public static let title = LFLocalizable.tr("Localizable", "cashTab.deposit.title", fallback: "Deposit")
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
    public enum WaysToAdd {
      /// More ways to deposit
      public static let title = LFLocalizable.tr("Localizable", "cashTab.waysToAdd.title", fallback: "More ways to deposit")
    }
    public enum Withdraw {
      /// Withdraw
      public static let title = LFLocalizable.tr("Localizable", "cashTab.withdraw.title", fallback: "Withdraw")
    }
  }
  public enum Cashback {
    /// Latest rewards
    public static let latest = LFLocalizable.tr("Localizable", "cashback.latest", fallback: "Latest rewards")
    /// See all
    public static let seeAll = LFLocalizable.tr("Localizable", "cashback.see_all", fallback: "See all")
  }
  public enum Cause {
    public enum Share {
      /// Include donations
      public static let includeDonations = LFLocalizable.tr("Localizable", "cause.share.include_donations", fallback: "Include donations")
      public enum Card {
        /// I'm using CauseCard to support %@ by making passive donations through my everyday purchases.
        public static func fundraiser(_ p1: Any) -> String {
          return LFLocalizable.tr("Localizable", "cause.share.card.fundraiser", String(describing: p1), fallback: "I'm using CauseCard to support %@ by making passive donations through my everyday purchases.")
        }
      }
    }
  }
  public enum Causes {
    /// We were unable to load the Causes right now.
    /// Please try again.
    public static let error = LFLocalizable.tr("Localizable", "causes.error", fallback: "We were unable to load the Causes right now.\nPlease try again.")
    /// Explore
    public static let explore = LFLocalizable.tr("Localizable", "causes.explore", fallback: "Explore")
    /// New
    public static let new = LFLocalizable.tr("Localizable", "causes.new", fallback: "New")
    /// Retry
    public static let retry = LFLocalizable.tr("Localizable", "causes.retry", fallback: "Retry")
    /// Trending
    public static let trending = LFLocalizable.tr("Localizable", "causes.trending", fallback: "Trending")
  }
  public enum CausesFilter {
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "causes_filter.continue", fallback: "Continue")
    /// Select categories you are interested in
    public static let subtitle = LFLocalizable.tr("Localizable", "causes_filter.subtitle", fallback: "Select categories you are interested in")
    /// SELECT A CAUSE
    public static let title = LFLocalizable.tr("Localizable", "causes_filter.title", fallback: "SELECT A CAUSE")
  }
  public enum CausesList {
    public enum Error {
      /// We aren't able to select this Cause right now.
      public static let message = LFLocalizable.tr("Localizable", "causes_list.error.message", fallback: "We aren't able to select this Cause right now.")
      /// We're Sorry
      public static let title = LFLocalizable.tr("Localizable", "causes_list.error.title", fallback: "We're Sorry")
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
  public enum ConfirmBuySellCrypto {
    /// Confirm
    public static let confirm = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.confirm", fallback: "Confirm")
    public enum Amount {
      /// Amount
      public static let title = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.amount.title", fallback: "Amount")
      /// %@ DOGE
      public static func valueCrypto(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "confirmBuySellCrypto.amount.value_crypto", String(describing: p1), fallback: "%@ DOGE")
      }
    }
    public enum Buy {
      /// BUY
      public static let text = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.buy.text", fallback: "BUY")
      /// CONFIRM YOUR DOGE PURCHASE OF %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "confirmBuySellCrypto.buy.title", String(describing: p1), fallback: "CONFIRM YOUR DOGE PURCHASE OF %@")
      }
    }
    public enum Disclosure {
      /// Orders may not be canceled or reversed once submitted by you. Also, if a withdrawal request is being made, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal.
      public static let crypto = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.disclosure.crypto", fallback: "Orders may not be canceled or reversed once submitted by you. Also, if a withdrawal request is being made, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal.")
      /// 100%% of funds are tax deductible and granted to designated nonprofit: %@. EIN: %@.
      /// 
      /// Donations made to ShoppingGives Foundation
      /// EIN: 83-1352270
      public static func donation(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "confirmBuySellCrypto.disclosure.donation", String(describing: p1), String(describing: p2), fallback: "100%% of funds are tax deductible and granted to designated nonprofit: %@. EIN: %@.\n\nDonations made to ShoppingGives Foundation\nEIN: 83-1352270")
      }
    }
    public enum ExchangeRate {
      /// Exchange Rate
      public static let title = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.exchangeRate.title", fallback: "Exchange Rate")
    }
    public enum Fee {
      /// Fees
      public static let title = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.fee.title", fallback: "Fees")
    }
    public enum OrderType {
      /// Order Type
      public static let title = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.orderType.title", fallback: "Order Type")
    }
    public enum Price {
      /// %@
      public static func value(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "confirmBuySellCrypto.price.value", String(describing: p1), fallback: "%@")
      }
    }
    public enum Sell {
      /// SELL
      public static let text = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.sell.text", fallback: "SELL")
      /// CONFIRM YOUR DOGE SELL OF %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "confirmBuySellCrypto.sell.title", String(describing: p1), fallback: "CONFIRM YOUR DOGE SELL OF %@")
      }
    }
    public enum Symbol {
      /// Symbol
      public static let title = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.symbol.title", fallback: "Symbol")
    }
    public enum Total {
      /// Total
      public static let title = LFLocalizable.tr("Localizable", "confirmBuySellCrypto.total.title", fallback: "Total")
      /// %@
      public static func value(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "confirmBuySellCrypto.total.value", String(describing: p1), fallback: "%@")
      }
    }
  }
  public enum ConnectedView {
    /// Connected Accounts
    public static let title = LFLocalizable.tr("Localizable", "connectedView.title", fallback: "Connected Accounts")
    public enum DeletePopup {
      /// Are you sure you want to remove this bank account/debit card?
      public static let message = LFLocalizable.tr("Localizable", "connectedView.delete_popup.message", fallback: "Are you sure you want to remove this bank account/debit card?")
      /// Delete
      public static let primaryButton = LFLocalizable.tr("Localizable", "connectedView.delete_popup.primary_button", fallback: "Delete")
      /// Remove this bank account/debit card
      public static let title = LFLocalizable.tr("Localizable", "connectedView.delete_popup.title", fallback: "Remove this bank account/debit card")
    }
    public enum Row {
      /// %@ **** %@
      public static func externalBank(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "connectedView.row.externalBank", String(describing: p1), String(describing: p2), fallback: "%@ **** %@")
      }
      /// Debit Card **** %@
      public static func externalCard(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "connectedView.row.externalCard", String(describing: p1), fallback: "Debit Card **** %@")
      }
    }
  }
  public enum Crypto {
    /// Doge
    public static let value = LFLocalizable.tr("Localizable", "crypto.value", fallback: "Doge")
  }
  public enum CryptoChart {
    public enum Filter {
      /// All
      public static let all = LFLocalizable.tr("Localizable", "cryptoChart.filter.all", fallback: "All")
      /// 1D
      public static let day = LFLocalizable.tr("Localizable", "cryptoChart.filter.day", fallback: "1D")
      /// Live
      public static let live = LFLocalizable.tr("Localizable", "cryptoChart.filter.live", fallback: "Live")
      /// 1M
      public static let month = LFLocalizable.tr("Localizable", "cryptoChart.filter.month", fallback: "1M")
      /// 1W
      public static let week = LFLocalizable.tr("Localizable", "cryptoChart.filter.week", fallback: "1W")
      /// 1Y
      public static let year = LFLocalizable.tr("Localizable", "cryptoChart.filter.year", fallback: "1Y")
    }
  }
  public enum CryptoChartDetail {
    public enum Buy {
      /// Buy
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.buy.title", fallback: "Buy")
    }
    public enum Change {
      /// Change
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.change.title", fallback: "Change")
    }
    public enum Close {
      /// Close
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.close.title", fallback: "Close")
    }
    public enum High {
      /// High
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.high.title", fallback: "High")
    }
    public enum Low {
      /// Low
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.low.title", fallback: "Low")
    }
    public enum Open {
      /// Open
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.open.title", fallback: "Open")
    }
    public enum Receive {
      /// Receive
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.receive.title", fallback: "Receive")
    }
    public enum Sell {
      /// Sell
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.sell.title", fallback: "Sell")
    }
    public enum Send {
      /// Send
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.send.title", fallback: "Send")
    }
    public enum Today {
      /// Today
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.today.title", fallback: "Today")
    }
    public enum Transfer {
      /// Transfer
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.transfer.title", fallback: "Transfer")
    }
    public enum TransferBalance {
      /// YOU DON'T HAVE ANY %@ TO TRANSFER AT THIS TIME.
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "cryptoChartDetail.transferBalance.title", String(describing: p1), fallback: "YOU DON'T HAVE ANY %@ TO TRANSFER AT THIS TIME.")
      }
    }
    public enum TransferCoin {
      /// Transfer
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.transferCoin.title", fallback: "Transfer")
    }
    public enum Volume {
      /// Volume
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.volume.title", fallback: "Volume")
    }
    public enum WalletAddress {
      /// Wallet address
      public static let title = LFLocalizable.tr("Localizable", "cryptoChartDetail.walletAddress.title", fallback: "Wallet address")
    }
  }
  public enum CryptoReceipt {
    public enum AccountID {
      /// Account ID
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.accountID.title", fallback: "Account ID")
    }
    public enum Amount {
      /// Amount
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.amount.title", fallback: "Amount")
    }
    public enum Beware {
      /// Cryptocurrencies and money transfer services are commonly targeted by hackers and criminals who commit fraud. For more information on how to protect against fraud, visit the Consumer Financial Protection Bureau’s website at 
      ///  https://www.consumerfinance.gov/consumer-tools/fraud/. 
      /// 
      /// 
      /// 
      /// 
      /// 
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.beware.description", fallback: "Cryptocurrencies and money transfer services are commonly targeted by hackers and criminals who commit fraud. For more information on how to protect against fraud, visit the Consumer Financial Protection Bureau’s website at \n https://www.consumerfinance.gov/consumer-tools/fraud/. \n\n\n\n\n")
      /// Beware of Fraud:
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.beware.title", fallback: "Beware of Fraud:")
    }
    public enum Cancellation {
      /// All transactions are final. You are responsible for reviewing this receipt for accuracy land for notifying Zero Hash LLC of any tuspected errors via email at support@zerohash.com within 24 hours of the trade.
      /// 
      /// 
      /// 
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.cancellation.description", fallback: "All transactions are final. You are responsible for reviewing this receipt for accuracy land for notifying Zero Hash LLC of any tuspected errors via email at support@zerohash.com within 24 hours of the trade.\n\n\n")
      /// Return/Cancellation Policy:
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.cancellation.title", fallback: "Return/Cancellation Policy:")
    }
    public enum CardType {
      /// doge@zerohash.com
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.cardType.link", fallback: "doge@zerohash.com")
    }
    public enum ConsumerTools {
      /// https://www.consumerfinance.gov/consumer-tools/fraud
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.consumerTools.link", fallback: "https://www.consumerfinance.gov/consumer-tools/fraud")
    }
    public enum Currency {
      /// Currency
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.currency.title", fallback: "Currency")
    }
    public enum DateAndTime {
      /// Date and Time
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.dateAndTime.title", fallback: "Date and Time")
    }
    public enum ExchangeRate {
      /// Exchange Rate
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.exchangeRate.title", fallback: "Exchange Rate")
    }
    public enum Fee {
      /// Fee
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.fee.title", fallback: "Fee")
    }
    public enum Illinois {
      /// In the event of an unresolved complaint, please contact the Illinois Department of Financial and Professional Regulation - Division of Financial Institutions at 1-888-473-4858 or submit an online complaint at 
      ///  https://idfpr.illinois.gov/admin/dfi/dficomplaint.html. 
      /// 
      /// 
      /// 
      /// 
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.illinois.description", fallback: "In the event of an unresolved complaint, please contact the Illinois Department of Financial and Professional Regulation - Division of Financial Institutions at 1-888-473-4858 or submit an online complaint at \n https://idfpr.illinois.gov/admin/dfi/dficomplaint.html. \n\n\n\n")
      /// Illinois Customers
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.illinois.title", fallback: "Illinois Customers")
    }
    public enum IllinoisCustomer {
      /// https://idfpr.illinois.gov/admin/dfi/dficomplaint.html.
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.illinoisCustomer.link", fallback: "https://idfpr.illinois.gov/admin/dfi/dficomplaint.html.")
    }
    public enum Liability {
      /// Zero Hash LLC's or Zero Hash Liquidity Services LLC's aggregate liability, including for non-delivery or delayed delivery, is limited to losses resulting solely from the gross negligence, intentional misconduct or fraud of Zero Hash or Zero Hash Liquidity Services, their affiliates or any of their officers, directors, managers, partners, employees or independent agents or contractors, as determined by a court of competent jurisdiction or arbitration panel in accordance with the terms of the User Agreement 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.liability.description", fallback: "Zero Hash LLC's or Zero Hash Liquidity Services LLC's aggregate liability, including for non-delivery or delayed delivery, is limited to losses resulting solely from the gross negligence, intentional misconduct or fraud of Zero Hash or Zero Hash Liquidity Services, their affiliates or any of their officers, directors, managers, partners, employees or independent agents or contractors, as determined by a court of competent jurisdiction or arbitration panel in accordance with the terms of the User Agreement \n\n\n\n\n\n\n\n\n\n")
      /// Liability for Non-Delivery or Delayed Delivery:
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.liability.title", fallback: "Liability for Non-Delivery or Delayed Delivery:")
    }
    public enum MaineCustomer {
      ///  www.credit.maine.gov
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.maineCustomer.link", fallback: " www.credit.maine.gov")
    }
    public enum MaineCustomers {
      /// In the event of a dispute, please contact the Bureau of Consumer Credit Protection at 1-800-332-8529 or at www.credit.maine.gov. 
      /// 
      /// 
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.maineCustomers.description", fallback: "In the event of a dispute, please contact the Bureau of Consumer Credit Protection at 1-800-332-8529 or at www.credit.maine.gov. \n\n")
      /// Maine Customers
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.maineCustomers.title", fallback: "Maine Customers")
    }
    public enum MinnesotaCustomerCryptocurrency {
      /// https://mn.gov/commerce/money/investments/cryptocurrency
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.minnesotaCustomerCryptocurrency.link", fallback: "https://mn.gov/commerce/money/investments/cryptocurrency")
    }
    public enum MinnesotaCustomerFraud {
      /// https://mn.gov/commerce/money/fraud/
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.minnesotaCustomerFraud.link", fallback: "https://mn.gov/commerce/money/fraud/")
    }
    public enum MinnesotaCustomers {
      /// If you believe you are a victim of fraud, please contact the Minnesota Commerce Department Consumer Services Center at 1-800-657-3602 or consumer.protection@state.mn.us. For more information about how to protect against fraud and submit a complaint, visit https://mn.gov/commerce/money/fraud/. For more information on cryptocurrency, please visit
      /// https://mn.gov/commerce/money/investments/cryptocurrency/. 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.minnesotaCustomers.description", fallback: "If you believe you are a victim of fraud, please contact the Minnesota Commerce Department Consumer Services Center at 1-800-657-3602 or consumer.protection@state.mn.us. For more information about how to protect against fraud and submit a complaint, visit https://mn.gov/commerce/money/fraud/. For more information on cryptocurrency, please visit\nhttps://mn.gov/commerce/money/investments/cryptocurrency/. \n\n\n\n\n\n\n")
      /// Minnesota Customers
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.minnesotaCustomers.title", fallback: "Minnesota Customers")
    }
    public enum Navigation {
      /// Receipt
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.navigation.title", fallback: "Receipt")
    }
    public enum OrderNumber {
      /// Order Number
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.orderNumber.title", fallback: "Order Number")
    }
    public enum OrderType {
      /// Order Type
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.orderType.title", fallback: "Order Type")
    }
    public enum Phonenumber {
      /// 855-744-7333
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.phonenumber.link", fallback: "855-744-7333")
    }
    public enum PriceRisk {
      /// The value of any cryptocurrency, including any digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.
      /// 
      /// 
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.priceRisk.description", fallback: "The value of any cryptocurrency, including any digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.\n\n")
      /// PRICE RISK
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.priceRisk.title", fallback: "PRICE RISK")
    }
    public enum TexasCustomer {
      /// www.dob.texas.gov.
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.texasCustomer.link", fallback: "www.dob.texas.gov.")
    }
    public enum TexasCustomers {
      /// If you have a complaint, first contact the consumer assistance division of Zero Hash LLC at 1 (855) 744-7333, if you still have an unresolved complaint regarding the company's money transmission activity, please direct your complaint to: Texas Department of Banking, 2601 North Lamar Boulevard, Austin, Texas 78705, 1-877-276- 5554 (toll free), www.dob.texas.gov. 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      /// 
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.texasCustomers.description", fallback: "If you have a complaint, first contact the consumer assistance division of Zero Hash LLC at 1 (855) 744-7333, if you still have an unresolved complaint regarding the company's money transmission activity, please direct your complaint to: Texas Department of Banking, 2601 North Lamar Boulevard, Austin, Texas 78705, 1-877-276- 5554 (toll free), www.dob.texas.gov. \n\n\n\n\n\n\n")
      /// Texas Customers
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.texasCustomers.title", fallback: "Texas Customers")
    }
    public enum TradingPair {
      /// Trading Pair
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.tradingPair.title", fallback: "Trading Pair")
    }
    public enum TransactionValue {
      /// Transaction Value
      public static let title = LFLocalizable.tr("Localizable", "cryptoReceipt.transactionValue.title", fallback: "Transaction Value")
    }
    public enum Zerohash {
      /// Zero Hash LLC 327 N Aberdeen St Chicago, IL 60607 
      /// 
      ///  www.zerohash.com
      public static let description = LFLocalizable.tr("Localizable", "cryptoReceipt.zerohash.description", fallback: "Zero Hash LLC 327 N Aberdeen St Chicago, IL 60607 \n\n www.zerohash.com")
      /// www.zerohash.com
      public static let link = LFLocalizable.tr("Localizable", "cryptoReceipt.zerohash.link", fallback: "www.zerohash.com")
    }
  }
  public enum DirectDeposit {
    public enum AccountNumber {
      /// AccountNumber
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.accountNumber.title", fallback: "AccountNumber")
    }
    public enum AddSignature {
      /// Add Signature
      public static let buttonTitle = LFLocalizable.tr("Localizable", "directDeposit.addSignature.buttonTitle", fallback: "Add Signature")
      /// Sign the form on the next page to authorize Direct Deposit enrollment.
      public static let description = LFLocalizable.tr("Localizable", "directDeposit.addSignature.description", fallback: "Sign the form on the next page to authorize Direct Deposit enrollment.")
      /// Signature
      public static let placeholder = LFLocalizable.tr("Localizable", "directDeposit.addSignature.placeholder", fallback: "Signature")
      /// ADD YOUR SIGNATURE
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.addSignature.title", fallback: "ADD YOUR SIGNATURE")
    }
    public enum AutomationSetup {
      /// Tell us who pays you, and we’ll help you get set up.
      public static let description = LFLocalizable.tr("Localizable", "directDeposit.automationSetup.description", fallback: "Tell us who pays you, and we’ll help you get set up.")
      /// Automatic Setup
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.automationSetup.title", fallback: "Automatic Setup")
    }
    public enum Benefits {
      /// BENEFITS OF DIRECT DEPOSIT
      public static let bottomSheetTitle = LFLocalizable.tr("Localizable", "directDeposit.benefits.bottomSheetTitle", fallback: "BENEFITS OF DIRECT DEPOSIT")
    }
    public enum Copied {
      /// Copied to clipboard
      public static let message = LFLocalizable.tr("Localizable", "directDeposit.copied.message", fallback: "Copied to clipboard")
    }
    public enum EmailForm {
      /// Email Form
      public static let buttonTitle = LFLocalizable.tr("Localizable", "directDeposit.emailForm.buttonTitle", fallback: "Email Form")
    }
    public enum EmployerName {
      /// Enter employer name
      public static let textFieldPlaceholder = LFLocalizable.tr("Localizable", "directDeposit.employerName.textFieldPlaceholder", fallback: "Enter employer name")
      /// Employer name
      public static let textFieldTitle = LFLocalizable.tr("Localizable", "directDeposit.employerName.textFieldTitle", fallback: "Employer name")
      /// ENTER THE NAME OF YOUR EMPLOYER
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.employerName.title", fallback: "ENTER THE NAME OF YOUR EMPLOYER")
    }
    public enum FillOutForm {
      /// Fill out a form
      public static let buttonTitle = LFLocalizable.tr("Localizable", "directDeposit.fillOutForm.buttonTitle", fallback: "Fill out a form")
    }
    public enum FindYourEmployer {
      /// FIND YOUR EMPLOYER
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.findYourEmployer.title", fallback: "FIND YOUR EMPLOYER")
    }
    public enum FirstBenefit {
      /// Payday up to 2 days early
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.firstBenefit.title", fallback: "Payday up to 2 days early")
    }
    public enum Form {
      /// Receive paychecks up to two days early by completing this form and sharing it with your employer’s payroll department. 
      ///  
      ///  
      /// You can also save the completed form to share with your employer later.
      public static let description = LFLocalizable.tr("Localizable", "directDeposit.form.description", fallback: "Receive paychecks up to two days early by completing this form and sharing it with your employer’s payroll department. \n \n \nYou can also save the completed form to share with your employer later.")
      /// DIRECT DEPOSIT FORM
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.form.title", fallback: "DIRECT DEPOSIT FORM")
    }
    public enum GetStarted {
      /// Get Started
      public static let buttonTitle = LFLocalizable.tr("Localizable", "directDeposit.getStarted.buttonTitle", fallback: "Get Started")
    }
    public enum Mail {
      /// Mail app is not configured
      public static let toastMessage = LFLocalizable.tr("Localizable", "directDeposit.mail.toastMessage", fallback: "Mail app is not configured")
    }
    public enum ManualSetup {
      /// Give these to your employer and they’ll handle the rest.
      public static let description = LFLocalizable.tr("Localizable", "directDeposit.manualSetup.description", fallback: "Give these to your employer and they’ll handle the rest.")
      /// Share this form with your employer's payroll team to authorize direct deposits to your %@Card
      public static func successMessage(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "directDeposit.manualSetup.successMessage", String(describing: p1), fallback: "Share this form with your employer's payroll team to authorize direct deposits to your %@Card")
      }
      /// YOUR DIRECT DEPOSIT FORM IS READY
      public static let successTitle = LFLocalizable.tr("Localizable", "directDeposit.manualSetup.successTitle", fallback: "YOUR DIRECT DEPOSIT FORM IS READY")
      /// Manual Setup
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.manualSetup.title", fallback: "Manual Setup")
    }
    public enum Paycheck {
      /// Enter Amount
      public static let enterAmount = LFLocalizable.tr("Localizable", "directDeposit.paycheck.enterAmount", fallback: "Enter Amount")
      /// Enter Percentage
      public static let enterPercentage = LFLocalizable.tr("Localizable", "directDeposit.paycheck.enterPercentage", fallback: "Enter Percentage")
      /// Full Paycheck
      public static let full = LFLocalizable.tr("Localizable", "directDeposit.paycheck.full", fallback: "Full Paycheck")
      /// HOW MUCH OF PAYCHECK YOU WANT TO DEPOSIT?
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.paycheck.title", fallback: "HOW MUCH OF PAYCHECK YOU WANT TO DEPOSIT?")
    }
    public enum Pdf {
      /// AUTHORIZATION
      public static let authorization = LFLocalizable.tr("Localizable", "directDeposit.pdf.authorization", fallback: "AUTHORIZATION")
      /// Customer name
      public static let customName = LFLocalizable.tr("Localizable", "directDeposit.pdf.customName", fallback: "Customer name")
      /// Date
      public static let date = LFLocalizable.tr("Localizable", "directDeposit.pdf.date", fallback: "Date")
      /// help@%@Card.co
      public static func emailText(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "directDeposit.pdf.emailText", String(describing: p1), fallback: "help@%@Card.co")
      }
      /// Entire Paycheck
      public static let entirePaycheck = LFLocalizable.tr("Localizable", "directDeposit.pdf.entirePaycheck", fallback: "Entire Paycheck")
      /// 
      ///  This authorization replaces any previous direct deposit authorization and shall remain in effect until my employer receives written notification from me of its termination. The information for my %@Card account is provided above
      public static func fifthDescription(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "directDeposit.pdf.fifthDescription", String(describing: p1), fallback: "\n This authorization replaces any previous direct deposit authorization and shall remain in effect until my employer receives written notification from me of its termination. The information for my %@Card account is provided above")
      }
      /// I,
      public static let firstDescription = LFLocalizable.tr("Localizable", "directDeposit.pdf.firstDescription", fallback: "I,")
      /// Direct Deposit Form
      public static let formText = LFLocalizable.tr("Localizable", "directDeposit.pdf.formText", fallback: "Direct Deposit Form")
      /// less lawful withholdings and deductions), or earnings, as applicable, to my CauseCard account, including employer receives written notification from me of its termination of my employment or enagement
      public static let fourthDescription = LFLocalizable.tr("Localizable", "directDeposit.pdf.fourthDescription", fallback: "less lawful withholdings and deductions), or earnings, as applicable, to my CauseCard account, including employer receives written notification from me of its termination of my employment or enagement")
      /// Pay 
      ///  to the order of
      public static let payTo = LFLocalizable.tr("Localizable", "directDeposit.pdf.payTo", fallback: "Pay \n to the order of")
      /// authorize,
      public static let secondDescription = LFLocalizable.tr("Localizable", "directDeposit.pdf.secondDescription", fallback: "authorize,")
      /// Signature
      public static let signature = LFLocalizable.tr("Localizable", "directDeposit.pdf.signature", fallback: "Signature")
      /// I wish to deposit
      public static let sixthDescription = LFLocalizable.tr("Localizable", "directDeposit.pdf.sixthDescription", fallback: "I wish to deposit")
      /// to directly deposit my wages
      public static let thirdDescription = LFLocalizable.tr("Localizable", "directDeposit.pdf.thirdDescription", fallback: "to directly deposit my wages")
    }
    public enum RoutingNumber {
      /// Routing Number
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.routingNumber.title", fallback: "Routing Number")
    }
    public enum Screen {
      /// Direct Deposit
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.screen.title", fallback: "Direct Deposit")
    }
    public enum SecondBenefit {
      /// 3 ATM fees covered each month you direct deposit $300+
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.secondBenefit.title", fallback: "3 ATM fees covered each month you direct deposit $300+")
    }
    public enum SeeAllBenefits {
      /// See all the benefits
      public static let buttonTitle = LFLocalizable.tr("Localizable", "directDeposit.seeAllBenefits.buttonTitle", fallback: "See all the benefits")
    }
    public enum Signature {
      /// Please add your signature
      public static let toastMessage = LFLocalizable.tr("Localizable", "directDeposit.signature.toastMessage", fallback: "Please add your signature")
    }
    public enum Toolbal {
      /// Direct Deposit
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.toolbal.title", fallback: "Direct Deposit")
    }
    public enum UseAccountDetails {
      /// USE ACCOUNT DETAILS
      public static let title = LFLocalizable.tr("Localizable", "directDeposit.useAccountDetails.title", fallback: "USE ACCOUNT DETAILS")
    }
    public enum ViewForm {
      /// View Form
      public static let buttonTitle = LFLocalizable.tr("Localizable", "directDeposit.viewForm.buttonTitle", fallback: "View Form")
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
  public enum DonationReceipt {
    public enum AccountID {
      /// Account ID
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.accountID.title", fallback: "Account ID")
    }
    public enum Charity {
      /// Donations made to %@. EIN: %@
      public static func title(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "donationReceipt.charity.title", String(describing: p1), String(describing: p2), fallback: "Donations made to %@. EIN: %@")
      }
    }
    public enum DateAndTime {
      /// Date and Time
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.dateAndTime.title", fallback: "Date and Time")
    }
    public enum Fee {
      /// Fee
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.fee.title", fallback: "Fee")
    }
    public enum Fundraiser {
      /// 100%% of funds are tax deductible and granted to designated nonprofit: %@.
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "donationReceipt.fundraiser.title", String(describing: p1), fallback: "100%% of funds are tax deductible and granted to designated nonprofit: %@.")
      }
    }
    public enum Navigation {
      /// Donation Receipt
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.navigation.title", fallback: "Donation Receipt")
    }
    public enum OneTime {
      /// One Time Donation
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.oneTime.title", fallback: "One Time Donation")
    }
    public enum Privacy {
      /// Privacy Policy
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.privacy.title", fallback: "Privacy Policy")
    }
    public enum Reward {
      /// Rewards Donation
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.reward.title", fallback: "Rewards Donation")
    }
    public enum Roundup {
      /// Round up Donation
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.roundup.title", fallback: "Round up Donation")
    }
    public enum Terms {
      /// Terms & Conditions
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.terms.title", fallback: "Terms & Conditions")
    }
    public enum Total {
      /// Total Donation
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.total.title", fallback: "Total Donation")
    }
    public enum TransactionNumber {
      /// Transaction Number
      public static let title = LFLocalizable.tr("Localizable", "donationReceipt.transactionNumber.title", fallback: "Transaction Number")
    }
  }
  public enum Donations {
    /// Latest
    public static let fundraiserDonations = LFLocalizable.tr("Localizable", "donations.fundraiser_donations", fallback: "Latest")
    /// No donations yet
    public static let noDonations = LFLocalizable.tr("Localizable", "donations.no_donations", fallback: "No donations yet")
    /// Select a Cause
    public static let selectFundraiser = LFLocalizable.tr("Localizable", "donations.select_fundraiser", fallback: "Select a Cause")
    /// My Donations
    public static let userDonations = LFLocalizable.tr("Localizable", "donations.user_donations", fallback: "My Donations")
  }
  public enum DonationsDisclosure {
    /// Cash Back and Charitable donations are granted automatically at the time of transaction.
    public static let second = LFLocalizable.tr("Localizable", "donations_disclosure.second", fallback: "Cash Back and Charitable donations are granted automatically at the time of transaction.")
    /// %@ of the donations you make are tax deductible and go to charity. 
    public static func text(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "donations_disclosure.text", String(describing: p1), fallback: "%@ of the donations you make are tax deductible and go to charity. ")
    }
    public enum Alert {
      /// Powered by ShoppingGives 
      public static let poweredBy = LFLocalizable.tr("Localizable", "donations_disclosure.alert.powered_by", fallback: "Powered by ShoppingGives ")
      /// DONATIONS
      public static let title = LFLocalizable.tr("Localizable", "donations_disclosure.alert.title", fallback: "DONATIONS")
    }
  }
  public enum EditNicknameOfWallet {
    /// EDIT WALLET ADDRESS
    public static let saveTitle = LFLocalizable.tr("Localizable", "edit_nickname_of_wallet.save_title", fallback: "EDIT WALLET ADDRESS")
  }
  public enum EditRewards {
    /// Select Rewards
    public static let navigationTitle = LFLocalizable.tr("Localizable", "edit_rewards.navigation_title", fallback: "Select Rewards")
    /// How would you like your rewards?
    public static let title = LFLocalizable.tr("Localizable", "edit_rewards.title", fallback: "How would you like your rewards?")
  }
  public enum EnterCVVCode {
    public enum ActiveCard {
      /// ACTIVATE PHYSICAL CARD
      public static let title = LFLocalizable.tr("Localizable", "enterCVVCode.activeCard.title", fallback: "ACTIVATE PHYSICAL CARD")
    }
    public enum Screen {
      /// Enter the 3-digit CVV code of your card
      public static let description = LFLocalizable.tr("Localizable", "enterCVVCode.screen.description", fallback: "Enter the 3-digit CVV code of your card")
    }
    public enum SetCardPin {
      /// ENTER CVV TO SET CARD PIN
      public static let title = LFLocalizable.tr("Localizable", "enterCVVCode.setCardPin.title", fallback: "ENTER CVV TO SET CARD PIN")
    }
  }
  public enum EnterVerificationCode {
    public enum CodeInvalid {
      /// OTP is invalid. Please resend OTP
      public static let message = LFLocalizable.tr("Localizable", "enterVerificationCode.codeInvalid.message", fallback: "OTP is invalid. Please resend OTP")
    }
    public enum Encrypt {
      /// Encrypted using 256-BIT SSL
      public static let cellText = LFLocalizable.tr("Localizable", "enterVerificationCode.encrypt.cellText", fallback: "Encrypted using 256-BIT SSL")
    }
    public enum Last4SSN {
      /// Enter Last 4 of SSN
      public static let placeholder = LFLocalizable.tr("Localizable", "enterVerificationCode.last4SSN.placeholder", fallback: "Enter Last 4 of SSN")
      /// LAST 4 DIGITS OF SSN
      public static let screenTitle = LFLocalizable.tr("Localizable", "enterVerificationCode.last4SSN.screenTitle", fallback: "LAST 4 DIGITS OF SSN")
    }
    public enum Last5Passport {
      /// Enter Last 5 of PASSPORT
      public static let placeholder = LFLocalizable.tr("Localizable", "enterVerificationCode.last5Passport.placeholder", fallback: "Enter Last 5 of PASSPORT")
      /// LAST 5 DIGITS OF PASSPORT
      public static let screenTitle = LFLocalizable.tr("Localizable", "enterVerificationCode.last5Passport.screenTitle", fallback: "LAST 5 DIGITS OF PASSPORT")
    }
    public enum LastXIdInvalid {
      /// SSN or Passport is invalid.
      public static let message = LFLocalizable.tr("Localizable", "enterVerificationCode.lastXIdInvalid.message", fallback: "SSN or Passport is invalid.")
    }
  }
  public enum EnterNicknameOfWallet {
    /// Create a name for "%@"
    public static func createNickname(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.create_nickname", String(describing: p1), fallback: "Create a name for \"%@\"")
    }
    /// You can change it at any time
    public static let disclosures = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.disclosures", fallback: "You can change it at any time")
    /// Create new name for "%@"
    public static func editNickname(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.edit_nickname", String(describing: p1), fallback: "Create new name for \"%@\"")
    }
    /// Enter name
    public static let placeholder = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.placeholder", fallback: "Enter name")
    /// Save
    public static let saveButton = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.save_button", fallback: "Save")
    /// SAVE WALLET ADDRESS
    public static let saveTitle = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.save_title", fallback: "SAVE WALLET ADDRESS")
    /// Wallet address name
    public static let textFieldTitle = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.textField_title", fallback: "Wallet address name")
    /// Wallet address was saved
    public static let walletWasSaved = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.wallet_was_saved", fallback: "Wallet address was saved")
    public enum NameExist {
      /// This wallet address name already exists
      public static let inlineError = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.name_exist.inline_error", fallback: "This wallet address name already exists")
    }
  }
  public enum EnterSsn {
    /// Encrypted using 256-BIT SSL
    public static let bulletOne = LFLocalizable.tr("Localizable", "enter_ssn.bullet_one", fallback: "Encrypted using 256-BIT SSL")
    /// No credit checks
    public static let bulletTwo = LFLocalizable.tr("Localizable", "enter_ssn.bullet_two", fallback: "No credit checks")
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "enter_ssn.continue", fallback: "Continue")
    /// No SSN? Tap here
    public static let noSsn = LFLocalizable.tr("Localizable", "enter_ssn.no_ssn", fallback: "No SSN? Tap here")
    /// Enter Full Social Security Number
    public static let placeholder = LFLocalizable.tr("Localizable", "enter_ssn.placeholder", fallback: "Enter Full Social Security Number")
    /// PLEASE ENTER SSN
    public static let title = LFLocalizable.tr("Localizable", "enter_ssn.title", fallback: "PLEASE ENTER SSN")
    /// Why do we need SSN?
    public static let why = LFLocalizable.tr("Localizable", "enter_ssn.why", fallback: "Why do we need SSN?")
    public enum Alert {
      /// A valid SSN is required by our partners to provide banking services.
      public static let message = LFLocalizable.tr("Localizable", "enter_ssn.alert.message", fallback: "A valid SSN is required by our partners to provide banking services.")
      /// Okay
      public static let okay = LFLocalizable.tr("Localizable", "enter_ssn.alert.okay", fallback: "Okay")
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
  public enum FundCard {
    /// DogeCard is a Pre-paid Debit Card, which means there are no credit checks, interest payments or overdrafts. However, you have to deposit money to your account before you can use. Start by connecting your bank:
    public static let message = LFLocalizable.tr("Localizable", "fundCard.message", fallback: "DogeCard is a Pre-paid Debit Card, which means there are no credit checks, interest payments or overdrafts. However, you have to deposit money to your account before you can use. Start by connecting your bank:")
    /// FUND YOUR DOGECARD
    public static let title = LFLocalizable.tr("Localizable", "fundCard.title", fallback: "FUND YOUR DOGECARD")
  }
  public enum Fundraise {
    public enum ShareDonation {
      /// I donated %@ to %@ using %@. Join us in supporting %@.
      public static func amount(_ p1: Any, _ p2: Any, _ p3: Any, _ p4: Any) -> String {
        return LFLocalizable.tr("Localizable", "fundraise.share_donation.amount", String(describing: p1), String(describing: p2), String(describing: p3), String(describing: p4), fallback: "I donated %@ to %@ using %@. Join us in supporting %@.")
      }
      /// We're raising money for %@ using %@. Join us in supporting %@.
      public static func generic(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return LFLocalizable.tr("Localizable", "fundraise.share_donation.generic", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "We're raising money for %@ using %@. Join us in supporting %@.")
      }
    }
  }
  public enum FundraiserActions {
    /// Donate
    public static let donate = LFLocalizable.tr("Localizable", "fundraiser_actions.donate", fallback: "Donate")
    /// More
    public static let more = LFLocalizable.tr("Localizable", "fundraiser_actions.more", fallback: "More")
    /// Share
    public static let share = LFLocalizable.tr("Localizable", "fundraiser_actions.share", fallback: "Share")
  }
  public enum FundraiserDetail {
    /// Active
    public static let active = LFLocalizable.tr("Localizable", "fundraiser_detail.active", fallback: "Active")
    /// Address
    public static let address = LFLocalizable.tr("Localizable", "fundraiser_detail.address", fallback: "Address")
    /// Give with confidence
    public static let confidence = LFLocalizable.tr("Localizable", "fundraiser_detail.confidence", fallback: "Give with confidence")
    /// Charity details
    public static let details = LFLocalizable.tr("Localizable", "fundraiser_detail.details", fallback: "Charity details")
    /// EIN
    public static let ein = LFLocalizable.tr("Localizable", "fundraiser_detail.ein", fallback: "EIN")
    /// Latest Donations
    public static let latestDonations = LFLocalizable.tr("Localizable", "fundraiser_detail.latest_donations", fallback: "Latest Donations")
    /// Charity Navigator
    public static let navigator = LFLocalizable.tr("Localizable", "fundraiser_detail.navigator", fallback: "Charity Navigator")
    /// Select Cause
    public static let select = LFLocalizable.tr("Localizable", "fundraiser_detail.select", fallback: "Select Cause")
    /// 501c3 Status
    public static let status = LFLocalizable.tr("Localizable", "fundraiser_detail.status", fallback: "501c3 Status")
    /// Tags
    public static let tags = LFLocalizable.tr("Localizable", "fundraiser_detail.tags", fallback: "Tags")
    /// Website
    public static let website = LFLocalizable.tr("Localizable", "fundraiser_detail.website", fallback: "Website")
    public enum Error {
      /// We aren't able to open the Charity address right now.
      public static let geocode = LFLocalizable.tr("Localizable", "fundraiser_detail.error.geocode", fallback: "We aren't able to open the Charity address right now.")
      /// We weren't able to select this Fundraiser. Please try again.
      public static let select = LFLocalizable.tr("Localizable", "fundraiser_detail.error.select", fallback: "We weren't able to select this Fundraiser. Please try again.")
      /// We're Sorry
      public static let title = LFLocalizable.tr("Localizable", "fundraiser_detail.error.title", fallback: "We're Sorry")
    }
    public enum Success {
      /// THANK YOU!
      public static let title = LFLocalizable.tr("Localizable", "fundraiser_detail.success.title", fallback: "THANK YOU!")
    }
  }
  public enum FundraiserDonationAnnotation {
    /// You currently have %@ available to make a donation. If this amount is less than expected, please contact support.
    public static func description(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "fundraiser_donation_annotation.description", String(describing: p1), fallback: "You currently have %@ available to make a donation. If this amount is less than expected, please contact support.")
    }
  }
  public enum FundraiserSelection {
    /// Thank you for supporting %@ (you can always change later).
    public static func allowed(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "fundraiser_selection.allowed", String(describing: p1), fallback: "Thank you for supporting %@ (you can always change later).")
    }
    /// Thank you for supporting %@ (you can always change later). Next, please create your account.
    public static func allowedBeforeAccountCreation(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "fundraiser_selection.allowed_before_account_creation", String(describing: p1), fallback: "Thank you for supporting %@ (you can always change later). Next, please create your account.")
    }
  }
  public enum FundraiserStatus {
    /// %@ donations
    public static func donations(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "fundraiser_status.donations", String(describing: p1), fallback: "%@ donations")
    }
    /// raised
    public static let raised = LFLocalizable.tr("Localizable", "fundraiser_status.raised", fallback: "raised")
  }
  public enum GridValue {
    /// All
    public static let all = LFLocalizable.tr("Localizable", "grid_value.all", fallback: "All")
    /// %@ AVAX
    public static func crypto(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "grid_value.crypto", String(describing: p1), fallback: "%@ AVAX")
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
    public enum CauseTab {
      /// Causes
      public static let title = LFLocalizable.tr("Localizable", "home.causeTab.title", fallback: "Causes")
    }
    public enum DonationTab {
      /// Donations
      public static let title = LFLocalizable.tr("Localizable", "home.donationTab.title", fallback: "Donations")
    }
    public enum RewardsTab {
      /// Rewards
      public static let title = LFLocalizable.tr("Localizable", "home.rewardsTab.title", fallback: "Rewards")
    }
  }
  public enum Initial {
    public enum Label {
      /// %@ Card
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "initial.label.title", String(describing: p1), fallback: "%@ Card")
      }
    }
  }
  public enum Kyc {
    public enum Question {
      /// Please answer the following questions to help us verify your information.
      public static let desc = LFLocalizable.tr("Localizable", "kyc.question.desc", fallback: "Please answer the following questions to help us verify your information.")
      /// The questions are only valid for 5 minutes
      public static let timeDesc = LFLocalizable.tr("Localizable", "kyc.question.timeDesc", fallback: "The questions are only valid for 5 minutes")
      /// Additional Security Questions
      public static let title = LFLocalizable.tr("Localizable", "kyc.question.title", fallback: "Additional Security Questions")
    }
    public enum TimeIsUp {
      /// The time to answer questions has expired, please contact support to verify your accont.
      public static let message = LFLocalizable.tr("Localizable", "kyc.timeIsUp.message", fallback: "The time to answer questions has expired, please contact support to verify your accont.")
      /// TIME IS UP
      public static let title = LFLocalizable.tr("Localizable", "kyc.timeIsUp.title", fallback: "TIME IS UP")
    }
  }
  public enum KycStatus {
    public enum Document {
      public enum Inreview {
        /// We will update you after your documents have been reviewed. Thank you for your patience.
        public static let message = LFLocalizable.tr("Localizable", "kycStatus.document.inreview.message", fallback: "We will update you after your documents have been reviewed. Thank you for your patience.")
        /// Documents are in review
        public static let title = LFLocalizable.tr("Localizable", "kycStatus.document.inreview.title", fallback: "Documents are in review")
      }
    }
    public enum Fail {
      /// Based on the information you entered, we were unable to create a Depository account at this time. We will be in touch via email.
      public static let message = LFLocalizable.tr("Localizable", "kycStatus.fail.message", fallback: "Based on the information you entered, we were unable to create a Depository account at this time. We will be in touch via email.")
      /// WE’RE SORRY
      public static let title = LFLocalizable.tr("Localizable", "kycStatus.fail.title", fallback: "WE’RE SORRY")
      public enum Unclear {
        /// %@, we were unable to create a Depository account at this time. We will be in touch via email.
        public static func message(_ p1: Any) -> String {
          return LFLocalizable.tr("Localizable", "kycStatus.fail.unclear.message", String(describing: p1), fallback: "%@, we were unable to create a Depository account at this time. We will be in touch via email.")
        }
      }
    }
    public enum IdentityVerification {
      /// Please verify your identity with a valid Driver’s License, ID or Passport. 
      public static let message = LFLocalizable.tr("Localizable", "kycStatus.identityVerification.message", fallback: "Please verify your identity with a valid Driver’s License, ID or Passport. ")
      /// DRIVER’s LICENSE, ID OR PASSPORT
      public static let title = LFLocalizable.tr("Localizable", "kycStatus.identityVerification.title", fallback: "DRIVER’s LICENSE, ID OR PASSPORT")
    }
    public enum InReview {
      /// Hi %@, we are still verifying your account details.  This is common when VOIP or Google voice phone numbers are used, or addresses / emails change.  Please contact support and we will help verify the details.  Thank you for your patience.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "kycStatus.inReview.message", String(describing: p1), fallback: "Hi %@, we are still verifying your account details.  This is common when VOIP or Google voice phone numbers are used, or addresses / emails change.  Please contact support and we will help verify the details.  Thank you for your patience.")
      }
      /// Check Status
      public static let primaryTitle = LFLocalizable.tr("Localizable", "kycStatus.inReview.primaryTitle", fallback: "Check Status")
      /// Contact Support
      public static let secondaryTitle = LFLocalizable.tr("Localizable", "kycStatus.inReview.secondaryTitle", fallback: "Contact Support")
      /// VERIFYING ACCOUNT DETAILS
      public static let title = LFLocalizable.tr("Localizable", "kycStatus.inReview.title", fallback: "VERIFYING ACCOUNT DETAILS")
      public enum Popup {
        /// Thank you for your patience while your account is still reviewed.
        public static let message = LFLocalizable.tr("Localizable", "kycStatus.inReview.popup.message", fallback: "Thank you for your patience while your account is still reviewed.")
        /// In Review
        public static let title = LFLocalizable.tr("Localizable", "kycStatus.inReview.popup.title", fallback: "In Review")
      }
    }
    public enum MissingInfo {
      /// The information you have entered is not complete, you need to contact us via email to add some necessary information.
      public static let message = LFLocalizable.tr("Localizable", "kycStatus.missingInfo.message", fallback: "The information you have entered is not complete, you need to contact us via email to add some necessary information.")
    }
    public enum WaitingVerification {
      /// We’re confiming your account details. This could take up to 30 seconds
      public static let message = LFLocalizable.tr("Localizable", "kycStatus.waitingVerification.message", fallback: "We’re confiming your account details. This could take up to 30 seconds")
      /// THANK YOU FOR WAITING
      public static let title = LFLocalizable.tr("Localizable", "kycStatus.waitingVerification.title", fallback: "THANK YOU FOR WAITING")
    }
  }
  public enum ListCard {
    public enum ActivateCard {
      /// Activate %@ Card
      public static func buttonTitle(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "listCard.activateCard.buttonTitle", String(describing: p1), fallback: "Activate %@ Card")
      }
      /// To start using your card, please activate it now
      public static let message = LFLocalizable.tr("Localizable", "listCard.activateCard.message", fallback: "To start using your card, please activate it now")
      /// Activate Card
      public static let primary = LFLocalizable.tr("Localizable", "listCard.activateCard.primary", fallback: "Activate Card")
      /// Activate Card
      public static let title = LFLocalizable.tr("Localizable", "listCard.activateCard.title", fallback: "Activate Card")
    }
    public enum CardClosed {
      /// You have successfully 
      ///  closed your card.
      public static let message = LFLocalizable.tr("Localizable", "listCard.cardClosed.message", fallback: "You have successfully \n closed your card.")
      /// CARD CLOSED
      public static let title = LFLocalizable.tr("Localizable", "listCard.cardClosed.title", fallback: "CARD CLOSED")
    }
    public enum ChangePin {
      /// Change PIN
      public static let title = LFLocalizable.tr("Localizable", "listCard.changePin.title", fallback: "Change PIN")
    }
    public enum CloseCard {
      /// Are you sure you want to remove this card?
      public static let message = LFLocalizable.tr("Localizable", "listCard.closeCard.message", fallback: "Are you sure you want to remove this card?")
      /// Close Card
      public static let title = LFLocalizable.tr("Localizable", "listCard.closeCard.title", fallback: "Close Card")
    }
    public enum Deals {
      /// up to 8%% back in %@
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "listCard.deals.description", String(describing: p1), fallback: "up to 8%% back in %@")
      }
      /// Deals
      public static let title = LFLocalizable.tr("Localizable", "listCard.deals.title", fallback: "Deals")
    }
    public enum LockCard {
      /// Stop card from being used
      public static let description = LFLocalizable.tr("Localizable", "listCard.lockCard.description", fallback: "Stop card from being used")
      /// Lock Card
      public static let title = LFLocalizable.tr("Localizable", "listCard.lockCard.title", fallback: "Lock Card")
    }
    public enum OrderPhysicalCard {
      /// Order Physical Card
      public static let title = LFLocalizable.tr("Localizable", "listCard.orderPhysicalCard.title", fallback: "Order Physical Card")
    }
    public enum Security {
      /// Security
      public static let title = LFLocalizable.tr("Localizable", "listCard.security.title", fallback: "Security")
    }
    public enum ShowCardNumber {
      /// Show Card Number
      public static let title = LFLocalizable.tr("Localizable", "listCard.showCardNumber.title", fallback: "Show Card Number")
    }
  }
  public enum MoreWaysToSupport {
    /// More ways to support
    public static let title = LFLocalizable.tr("Localizable", "more_ways_to_support.title", fallback: "More ways to support")
    public enum Employer {
      /// Get taxable donations
      public static let action = LFLocalizable.tr("Localizable", "more_ways_to_support.employer.action", fallback: "Get taxable donations")
      /// Does your employer have a matching program?
      /// Double your impact with a simple email
      public static let message = LFLocalizable.tr("Localizable", "more_ways_to_support.employer.message", fallback: "Does your employer have a matching program?\nDouble your impact with a simple email")
      /// EMPLOYER MATCH PROGRAM
      public static let title = LFLocalizable.tr("Localizable", "more_ways_to_support.employer.title", fallback: "EMPLOYER MATCH PROGRAM")
    }
    public enum News {
      /// Get news and updates from %@
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "more_ways_to_support.news.message", String(describing: p1), fallback: "Get news and updates from %@")
      }
      /// NEWS AND UPDATES
      public static let title = LFLocalizable.tr("Localizable", "more_ways_to_support.news.title", fallback: "NEWS AND UPDATES")
    }
    public enum Photo {
      /// Failed to save image
      public static let error = LFLocalizable.tr("Localizable", "more_ways_to_support.photo.error", fallback: "Failed to save image")
      /// Update your profile photo on Social Media
      public static let message = LFLocalizable.tr("Localizable", "more_ways_to_support.photo.message", fallback: "Update your profile photo on Social Media")
      /// Image saved to Library!
      public static let success = LFLocalizable.tr("Localizable", "more_ways_to_support.photo.success", fallback: "Image saved to Library!")
      /// PROFILE PHOTO
      public static let title = LFLocalizable.tr("Localizable", "more_ways_to_support.photo.title", fallback: "PROFILE PHOTO")
    }
    public enum Share {
      /// Share cause
      public static let cause = LFLocalizable.tr("Localizable", "more_ways_to_support.share.cause", fallback: "Share cause")
      /// Invite friends
      public static let friends = LFLocalizable.tr("Localizable", "more_ways_to_support.share.friends", fallback: "Invite friends")
      /// SHARE
      public static let title = LFLocalizable.tr("Localizable", "more_ways_to_support.share.title", fallback: "SHARE")
    }
  }
  public enum MoveMoney {
    /// Add bank or card
    public static let addAccount = LFLocalizable.tr("Localizable", "moveMoney.add_account", fallback: "Add bank or card")
    public enum AvailableBalance {
      /// %@ available
      public static func subtitle(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "moveMoney.available_balance.subtitle", String(describing: p1), fallback: "%@ available")
      }
    }
    public enum Deposit {
      /// DEPOSIT
      public static let title = LFLocalizable.tr("Localizable", "moveMoney.deposit.title", fallback: "DEPOSIT")
    }
    public enum Error {
      /// no contact selected
      public static let noContact = LFLocalizable.tr("Localizable", "moveMoney.error.noContact", fallback: "no contact selected")
    }
    public enum TransferFeePopup {
      /// Free
      public static let free = LFLocalizable.tr("Localizable", "moveMoney.transferFeePopup.free", fallback: "Free")
      /// Instant
      public static let instant = LFLocalizable.tr("Localizable", "moveMoney.transferFeePopup.instant", fallback: "Instant")
      /// Normal
      public static let normal = LFLocalizable.tr("Localizable", "moveMoney.transferFeePopup.normal", fallback: "Normal")
      /// (3-4 business days)
      public static let normalDays = LFLocalizable.tr("Localizable", "moveMoney.transferFeePopup.normalDays", fallback: "(3-4 business days)")
      /// %@ SPEED
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "moveMoney.transferFeePopup.title", String(describing: p1), fallback: "%@ SPEED")
      }
    }
    public enum Withdraw {
      /// You currently have %@ available to withdraw. Rewards are not available to withdraw until 48 hours after they are earned.
      public static func annotation(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "moveMoney.withdraw.annotation", String(describing: p1), fallback: "You currently have %@ available to withdraw. Rewards are not available to withdraw until 48 hours after they are earned.")
      }
      /// WITHDRAW
      public static let title = LFLocalizable.tr("Localizable", "moveMoney.withdraw.title", fallback: "WITHDRAW")
    }
  }
  public enum NotificationPopup {
    /// Yes
    public static let action = LFLocalizable.tr("Localizable", "notification_popup.action", fallback: "Yes")
    /// Not now
    public static let dismiss = LFLocalizable.tr("Localizable", "notification_popup.dismiss", fallback: "Not now")
    /// Would you like to be notified about the status of your account or if your card has been charged?
    public static let subtitle = LFLocalizable.tr("Localizable", "notification_popup.subtitle", fallback: "Would you like to be notified about the status of your account or if your card has been charged?")
    /// WOULD YOU LIKE TO BE NOTIFIED?
    public static let title = LFLocalizable.tr("Localizable", "notification_popup.title", fallback: "WOULD YOU LIKE TO BE NOTIFIED?")
  }
  public enum OrderPhysicalCard {
    public enum Address {
      /// THE CARD WILL BE SHIPPED TO:
      public static let title = LFLocalizable.tr("Localizable", "orderPhysicalCard.address.title", fallback: "THE CARD WILL BE SHIPPED TO:")
    }
    public enum EditAddress {
      /// Edit address
      public static let buttonTitle = LFLocalizable.tr("Localizable", "orderPhysicalCard.editAddress.buttonTitle", fallback: "Edit address")
    }
    public enum Fees {
      /// Fees
      public static let title = LFLocalizable.tr("Localizable", "orderPhysicalCard.fees.title", fallback: "Fees")
    }
    public enum Order {
      /// Order Physical Card
      public static let buttonTitle = LFLocalizable.tr("Localizable", "orderPhysicalCard.order.buttonTitle", fallback: "Order Physical Card")
    }
    public enum OrderedSuccess {
      /// Thank you, your physical card was ordered. It will arrive in 7-14 business days. After it arrives, please come back to activate your card.
      public static let message = LFLocalizable.tr("Localizable", "orderPhysicalCard.orderedSuccess.message", fallback: "Thank you, your physical card was ordered. It will arrive in 7-14 business days. After it arrives, please come back to activate your card.")
      /// PHYSICAL CARD ORDERED
      public static let title = LFLocalizable.tr("Localizable", "orderPhysicalCard.orderedSuccess.title", fallback: "PHYSICAL CARD ORDERED")
    }
    public enum PhysicalCard {
      /// ORDER PHYSICAL CARD
      public static let title = LFLocalizable.tr("Localizable", "orderPhysicalCard.physicalCard.title", fallback: "ORDER PHYSICAL CARD")
    }
  }
  public enum PatriotAct {
    /// To help the government fight the funding of terrorism and money laundering activities, Section 326 of the USA PATRIOT Act requires all financial institutions to obtain, verify, and record information identifying each person who opens an account.
    /// 
    /// What this means to you: when you open an account or change an existing account, we will ask for information that will allow us to identify you, such as full legal name, physical address, date of birth, and other personally identifiable information that will be used to verify your identity. We may also ask to see a valid government issued photo ID (such as a Passport) or other identifying documents as well.
    /// 
    public static let body = LFLocalizable.tr("Localizable", "patriotAct.body", fallback: "To help the government fight the funding of terrorism and money laundering activities, Section 326 of the USA PATRIOT Act requires all financial institutions to obtain, verify, and record information identifying each person who opens an account.\n\nWhat this means to you: when you open an account or change an existing account, we will ask for information that will allow us to identify you, such as full legal name, physical address, date of birth, and other personally identifiable information that will be used to verify your identity. We may also ask to see a valid government issued photo ID (such as a Passport) or other identifying documents as well.\n")
    /// USA PATRIOT ACT NOTICES
    public static let title = LFLocalizable.tr("Localizable", "patriotAct.title", fallback: "USA PATRIOT ACT NOTICES")
    public enum Agreements {
      /// I have reviewed our full USA PATRIOT Act Notice
      public static let partiotActNotice = LFLocalizable.tr("Localizable", "patriotAct.agreements.partiotActNotice", fallback: "I have reviewed our full USA PATRIOT Act Notice")
    }
    public enum Links {
      /// USA PATRIOT Act Notice
      public static let partiotActNotice = LFLocalizable.tr("Localizable", "patriotAct.links.partiotActNotice", fallback: "USA PATRIOT Act Notice")
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
  public enum PlaidLink {
    public enum ConnectViaDebitCard {
      /// Link Bank via Debit Card
      public static let title = LFLocalizable.tr("Localizable", "plaidLink.connectViaDebitCard.title", fallback: "Link Bank via Debit Card")
    }
    public enum ContactSupport {
      /// Contact Support
      public static let title = LFLocalizable.tr("Localizable", "plaidLink.contactSupport.title", fallback: "Contact Support")
    }
    public enum Popup {
      /// We’re unable to link your bank account via Plaid.
      public static let description = LFLocalizable.tr("Localizable", "plaidLink.popup.description", fallback: "We’re unable to link your bank account via Plaid.")
      /// WE’RE SORRY
      public static let title = LFLocalizable.tr("Localizable", "plaidLink.popup.title", fallback: "WE’RE SORRY")
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
  public enum Profile {
    public enum Accountsettings {
      /// Account & Settings
      public static let title = LFLocalizable.tr("Localizable", "profile.accountsettings.title", fallback: "Account & Settings")
    }
    public enum Address {
      /// Address
      public static let title = LFLocalizable.tr("Localizable", "profile.address.title", fallback: "Address")
    }
    public enum Atm {
      /// ATM's Nearby
      public static let title = LFLocalizable.tr("Localizable", "profile.atm.title", fallback: "ATM's Nearby")
    }
    public enum ContributionToast {
      /// Failed to load your donations
      public static let message = LFLocalizable.tr("Localizable", "profile.contributionToast.message", fallback: "Failed to load your donations")
    }
    public enum DeleteAccount {
      /// Are you sure you want to delete your account?
      public static let message = LFLocalizable.tr("Localizable", "profile.deleteAccount.message", fallback: "Are you sure you want to delete your account?")
      /// Delete Account
      public static let title = LFLocalizable.tr("Localizable", "profile.deleteAccount.title", fallback: "Delete Account")
    }
    public enum DepositLimits {
      /// Deposit Limits
      public static let title = LFLocalizable.tr("Localizable", "profile.depositLimits.title", fallback: "Deposit Limits")
    }
    public enum Email {
      /// Email
      public static let title = LFLocalizable.tr("Localizable", "profile.email.title", fallback: "Email")
    }
    public enum Help {
      /// Help & support
      public static let title = LFLocalizable.tr("Localizable", "profile.help.title", fallback: "Help & support")
    }
    public enum Logout {
      /// Are you sure you want to log out?
      public static let message = LFLocalizable.tr("Localizable", "profile.logout.message", fallback: "Are you sure you want to log out?")
      /// Log Out
      public static let title = LFLocalizable.tr("Localizable", "profile.logout.title", fallback: "Log Out")
    }
    public enum NoticeOfDeletion {
      /// In order to delete your account, and comply with banking rules and regulations, we ask that you:
      /// 
      /// 1.Remove all funds from your account
      /// 
      /// 2.Allow all of your transactions to settle and complete
      /// 
      /// After submitting your request for deletion, you will continue to have access to your Bank Statements.
      /// 
      /// After this, your account data will be deleted as is permitted by law.
      public static let message = LFLocalizable.tr("Localizable", "profile.noticeOfDeletion.message", fallback: "In order to delete your account, and comply with banking rules and regulations, we ask that you:\n\n1.Remove all funds from your account\n\n2.Allow all of your transactions to settle and complete\n\nAfter submitting your request for deletion, you will continue to have access to your Bank Statements.\n\nAfter this, your account data will be deleted as is permitted by law.")
      /// NOTICE OF ACCOUNT DELETION
      public static let title = LFLocalizable.tr("Localizable", "profile.noticeOfDeletion.title", fallback: "NOTICE OF ACCOUNT DELETION")
      public enum Cancel {
        /// Cancel
        public static let title = LFLocalizable.tr("Localizable", "profile.noticeOfDeletion.cancel.title", fallback: "Cancel")
      }
      public enum Continue {
        /// Continue, Delete Account
        public static let title = LFLocalizable.tr("Localizable", "profile.noticeOfDeletion.continue.title", fallback: "Continue, Delete Account")
      }
    }
    public enum Notifications {
      /// Notifications
      public static let title = LFLocalizable.tr("Localizable", "profile.notifications.title", fallback: "Notifications")
    }
    public enum Or {
      /// OR
      public static let title = LFLocalizable.tr("Localizable", "profile.or.title", fallback: "OR")
    }
    public enum PhoneNumber {
      /// Phone Number
      public static let title = LFLocalizable.tr("Localizable", "profile.phoneNumber.title", fallback: "Phone Number")
    }
    public enum Referrals {
      /// Earn Doge with Friends
      public static let message = LFLocalizable.tr("Localizable", "profile.referrals.message", fallback: "Earn Doge with Friends")
      /// Invite Friends
      public static let title = LFLocalizable.tr("Localizable", "profile.referrals.title", fallback: "Invite Friends")
    }
    public enum Rewards {
      /// Current Rewards
      public static let title = LFLocalizable.tr("Localizable", "profile.rewards.title", fallback: "Current Rewards")
    }
    public enum Security {
      /// Security
      public static let title = LFLocalizable.tr("Localizable", "profile.security.title", fallback: "Security")
    }
    public enum Stickers {
      /// Stickers
      public static let title = LFLocalizable.tr("Localizable", "profile.stickers.title", fallback: "Stickers")
    }
    public enum Taxes {
      /// Taxes
      public static let title = LFLocalizable.tr("Localizable", "profile.taxes.title", fallback: "Taxes")
    }
    public enum Toolbar {
      /// Profile
      public static let title = LFLocalizable.tr("Localizable", "profile.toolbar.title", fallback: "Profile")
    }
    public enum TotalDonated {
      /// Total donated
      public static let title = LFLocalizable.tr("Localizable", "profile.totalDonated.title", fallback: "Total donated")
    }
    public enum TotalDonations {
      /// Total donations
      public static let title = LFLocalizable.tr("Localizable", "profile.totalDonations.title", fallback: "Total donations")
    }
    public enum Version {
      /// Version %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "profile.version.title", String(describing: p1), fallback: "Version %@")
      }
    }
  }
  public enum Question {
    public enum AccountTerms {
      /// %@ has partnered with NetSpend and Pathward to provide banking and card services.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "question.accountTerms.description", String(describing: p1), fallback: "%@ has partnered with NetSpend and Pathward to provide banking and card services.")
      }
      /// ACCOUNT TERMS
      public static let title = LFLocalizable.tr("Localizable", "question.accountTerms.title", fallback: "ACCOUNT TERMS")
    }
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
    public enum TransferTerms {
      /// Please review the Transfer terms and conditions.
      public static let description = LFLocalizable.tr("Localizable", "question.transferTerms.description", fallback: "Please review the Transfer terms and conditions.")
      /// Bank Transfer is a money transfer service provided by Netspend Corporation (NMLS #906983). See netspend.com/licenses.
      public static let diclosure = LFLocalizable.tr("Localizable", "question.transferTerms.diclosure", fallback: "Bank Transfer is a money transfer service provided by Netspend Corporation (NMLS #906983). See netspend.com/licenses.")
      /// TRANSFER TERMS AND CONDITIONS
      public static let title = LFLocalizable.tr("Localizable", "question.transferTerms.title", fallback: "TRANSFER TERMS AND CONDITIONS")
    }
  }
  public enum ReceiveCryptoView {
    /// Cryptocurrency services powered by Zero Hash
    public static let servicesInfo = LFLocalizable.tr("Localizable", "receive_crypto_view.services_info", fallback: "Cryptocurrency services powered by Zero Hash")
    /// %@ Wallet Address
    public static func title(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "receive_crypto_view.title", String(describing: p1), fallback: "%@ Wallet Address")
    }
    /// Wallet Details
    public static let walletDetail = LFLocalizable.tr("Localizable", "receive_crypto_view.wallet_detail", fallback: "Wallet Details")
    public enum Copied {
      /// Copied!
      public static let info = LFLocalizable.tr("Localizable", "receive_crypto_view.copied.info", fallback: "Copied!")
    }
  }
  public enum Referral {
    public enum Campaign {
      /// %d days
      public static func day(_ p1: Int) -> String {
        return LFLocalizable.tr("Localizable", "referral.campaign.day", p1, fallback: "%d days")
      }
      /// %d weeks
      public static func week(_ p1: Int) -> String {
        return LFLocalizable.tr("Localizable", "referral.campaign.week", p1, fallback: "%d weeks")
      }
    }
    public enum Copy {
      /// Copy invite link
      public static let buttonTitle = LFLocalizable.tr("Localizable", "referral.copy.buttonTitle", fallback: "Copy invite link")
    }
    public enum Error {
      /// We are unable to fetch the referral campaigns now. Please try again.
      public static let message = LFLocalizable.tr("Localizable", "referral.error.message", fallback: "We are unable to fetch the referral campaigns now. Please try again.")
    }
    public enum Example {
      /// If the friend you invited earns 500 %@ in a week, you will also get 500 AVAX. Your bonus will be paid each Friday to your %@Card wallet.
      public static func crypto(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "referral.example.crypto", String(describing: p1), String(describing: p2), fallback: "If the friend you invited earns 500 %@ in a week, you will also get 500 AVAX. Your bonus will be paid each Friday to your %@Card wallet.")
      }
      /// If your friend donates %@ in the first %@, we will donate %@ to your selected cause. The donation will be made in your name and is tax deductable.
      public static func donation(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return LFLocalizable.tr("Localizable", "referral.example.donation", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "If your friend donates %@ in the first %@, we will donate %@ to your selected cause. The donation will be made in your name and is tax deductable.")
      }
      /// HOW IT WORKS
      public static let title = LFLocalizable.tr("Localizable", "referral.example.title", fallback: "HOW IT WORKS")
    }
    public enum Info {
      /// Send your invite link to a friend, and we will match their donations for the first %@, or up to %@. This is tax deductable donations in your name.
      public static func message(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "referral.info.message", String(describing: p1), String(describing: p2), fallback: "Send your invite link to a friend, and we will match their donations for the first %@, or up to %@. This is tax deductable donations in your name.")
      }
    }
    public enum Screen {
      /// MAKE DONATIONS WITH FRIENDS
      public static let title = LFLocalizable.tr("Localizable", "referral.screen.title", fallback: "MAKE DONATIONS WITH FRIENDS")
    }
    public enum Send {
      /// Send invite link
      public static let buttonTitle = LFLocalizable.tr("Localizable", "referral.send.buttonTitle", fallback: "Send invite link")
    }
    public enum Toast {
      /// Invite link copied to clipboard.
      public static let message = LFLocalizable.tr("Localizable", "referral.toast.message", fallback: "Invite link copied to clipboard.")
    }
  }
  public enum RewardTerms {
    /// up to 8%% purchase of transaction in rewards
    public static let amountDescription = LFLocalizable.tr("Localizable", "rewardTerms.amount_description", fallback: "up to 8%% purchase of transaction in rewards")
    /// Transaction Amount
    public static let amountTitle = LFLocalizable.tr("Localizable", "rewardTerms.amount_title", fallback: "Transaction Amount")
    /// Maximum reward amounts may vary, and can depend on the user’s level of participation in crypto rewards. Specific terms and conditions may apply.
    public static let disclosuresFifth = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_fifth", fallback: "Maximum reward amounts may vary, and can depend on the user’s level of participation in crypto rewards. Specific terms and conditions may apply.")
    /// By selecting to enroll in the crypto rewards program, you understand and agree that eligible rewards transactions will also trigger your authorization to invest in crypto once your action or card transaction is complete. Transactions may take time in certain cases.
    public static let disclosuresFirst = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_first", fallback: "By selecting to enroll in the crypto rewards program, you understand and agree that eligible rewards transactions will also trigger your authorization to invest in crypto once your action or card transaction is complete. Transactions may take time in certain cases.")
    /// Zero Hash does not offer the ability to set up pre-authorized, automatic, or recurring Orders (“Pre-Authorized Orders”) in your Account; (a) any such Pre-Authorized Order feature (if available) is under the exclusive control of [Business] ; (b) you must contact [Business] in order to stop a Pre-Authorized Order before execution or to turn off such a feature in your Account; and (c) Zero Hash and ZHLS are not liable for the placement and execution of any Pre-Authorized order.
    public static let disclosuresFourth = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_fourth", fallback: "Zero Hash does not offer the ability to set up pre-authorized, automatic, or recurring Orders (“Pre-Authorized Orders”) in your Account; (a) any such Pre-Authorized Order feature (if available) is under the exclusive control of [Business] ; (b) you must contact [Business] in order to stop a Pre-Authorized Order before execution or to turn off such a feature in your Account; and (c) Zero Hash and ZHLS are not liable for the placement and execution of any Pre-Authorized order.")
    /// Cryptocurrency services powered by Zero Hash.
    public static let disclosuresSecond = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_second", fallback: "Cryptocurrency services powered by Zero Hash.")
    /// Orders may not be canceled or reversed once submitted by you. Also, if a withdrawal request is being made, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal.
    public static let disclosuresThird = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_third", fallback: "Orders may not be canceled or reversed once submitted by you. Also, if a withdrawal request is being made, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal.")
    /// Exchange Rate
    public static let disclosuresTitle = LFLocalizable.tr("Localizable", "rewardTerms.disclosures_title", fallback: "Exchange Rate")
    /// Enroll now
    public static let enrollCta = LFLocalizable.tr("Localizable", "rewardTerms.enroll_cta", fallback: "Enroll now")
    /// ENROLL IN CRYPTO REWARDS
    public static let enrollTitle = LFLocalizable.tr("Localizable", "rewardTerms.enroll_title", fallback: "ENROLL IN CRYPTO REWARDS")
    /// Varies, the current prevailing price as determined by Zero Hash Liquidity Services LLC at point of transaction.
    public static let exchangeRateDescription = LFLocalizable.tr("Localizable", "rewardTerms.exchange_rate_description", fallback: "Varies, the current prevailing price as determined by Zero Hash Liquidity Services LLC at point of transaction.")
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
  public enum RoundUp {
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "round_up.continue", fallback: "Continue")
    /// Select a cause you'd like to support. You can change anytime.
    public static let itemOne = LFLocalizable.tr("Localizable", "round_up.item_one", fallback: "Select a cause you'd like to support. You can change anytime.")
    /// Your spare change will be donated to your selected cause.
    public static let itemThree = LFLocalizable.tr("Localizable", "round_up.item_three", fallback: "Your spare change will be donated to your selected cause.")
    /// Spend with your CauseCard.
    public static let itemTwo = LFLocalizable.tr("Localizable", "round_up.item_two", fallback: "Spend with your CauseCard.")
    /// Round up spare change to the nearest dollar when you use your %@. It's easy way to make a big impact over time.
    public static func message(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "round_up.message", String(describing: p1), fallback: "Round up spare change to the nearest dollar when you use your %@. It's easy way to make a big impact over time.")
    }
    /// Round up purchases
    public static let purchases = LFLocalizable.tr("Localizable", "round_up.purchases", fallback: "Round up purchases")
    /// Skip
    public static let skip = LFLocalizable.tr("Localizable", "round_up.skip", fallback: "Skip")
    /// ROUND UPS
    public static let title = LFLocalizable.tr("Localizable", "round_up.title", fallback: "ROUND UPS")
  }
  public enum Screen {
    public enum Title {
      /// Hello i live in Package LFLocalizable
      public static let text = LFLocalizable.tr("Localizable", "screen.title.text", fallback: "Hello i live in Package LFLocalizable")
    }
  }
  public enum SearchCauses {
    /// Search charities
    public static let navigationTitle = LFLocalizable.tr("Localizable", "search_causes.navigation_title", fallback: "Search charities")
    /// No results found
    public static let noResults = LFLocalizable.tr("Localizable", "search_causes.no_results", fallback: "No results found")
  }
  public enum SelectBankAccount {
    /// Connect a Bank Account
    public static let connectABank = LFLocalizable.tr("Localizable", "selectBankAccount.connectABank", fallback: "Connect a Bank Account")
    /// Select Account
    public static let title = LFLocalizable.tr("Localizable", "selectBankAccount.title", fallback: "Select Account")
  }
  public enum SelectCause {
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "select_cause.continue", fallback: "Continue")
    /// Select cause you are interested in
    public static let subtitle = LFLocalizable.tr("Localizable", "select_cause.subtitle", fallback: "Select cause you are interested in")
    /// Select Fundraiser
    public static let title = LFLocalizable.tr("Localizable", "select_cause.title", fallback: "Select Fundraiser")
  }
  public enum SelectFundraiser {
    /// %@ CAUSES
    public static func causes(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "select_fundraiser.causes", String(describing: p1), fallback: "%@ CAUSES")
    }
    /// Unable to select Fundraiser, please try again.
    public static let error = LFLocalizable.tr("Localizable", "select_fundraiser.error", fallback: "Unable to select Fundraiser, please try again.")
    /// Select
    public static let select = LFLocalizable.tr("Localizable", "select_fundraiser.select", fallback: "Select")
    /// You can change your cause anytime
    public static let subtitle = LFLocalizable.tr("Localizable", "select_fundraiser.subtitle", fallback: "You can change your cause anytime")
    /// SELECT A CAUSE
    public static let title = LFLocalizable.tr("Localizable", "select_fundraiser.title", fallback: "SELECT A CAUSE")
    public enum Success {
      /// Continue
      public static let primary = LFLocalizable.tr("Localizable", "select_fundraiser.success.primary", fallback: "Continue")
      /// THANK YOU!
      public static let title = LFLocalizable.tr("Localizable", "select_fundraiser.success.title", fallback: "THANK YOU!")
    }
  }
  public enum SelectRewards {
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "select_rewards.continue", fallback: "Continue")
    /// You can change anytime
    public static let subtitle = LFLocalizable.tr("Localizable", "select_rewards.subtitle", fallback: "You can change anytime")
    /// Select Rewards
    public static let title = LFLocalizable.tr("Localizable", "select_rewards.title", fallback: "Select Rewards")
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
    /// %@ has partnered with Zero Hash to offer cryptocurrency services.
    public static func info(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "setUpWallet.info", String(describing: p1), fallback: "%@ has partnered with Zero Hash to offer cryptocurrency services.")
    }
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
    /// Zero Hash and Zero Hash Liquidity Services User Agreement
    public static let userAgreement = LFLocalizable.tr("Localizable", "setUpWallet.userAgreement", fallback: "Zero Hash and Zero Hash Liquidity Services User Agreement")
    /// Zero Hash and Zero Hash Liquidity Services User Agreement
    public static let walletUseragreement = LFLocalizable.tr("Localizable", "setUpWallet.wallet_useragreement", fallback: "Zero Hash and Zero Hash Liquidity Services User Agreement")
  }
  public enum Share {
    /// Cancel
    public static let cancel = LFLocalizable.tr("Localizable", "share.cancel", fallback: "Cancel")
    /// Email
    public static let email = LFLocalizable.tr("Localizable", "share.email", fallback: "Email")
    /// Facebook
    public static let facebook = LFLocalizable.tr("Localizable", "share.facebook", fallback: "Facebook")
    /// Failed to share on %@
    public static func failure(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "share.failure", String(describing: p1), fallback: "Failed to share on %@")
    }
    /// Include donations
    public static let includeDonations = LFLocalizable.tr("Localizable", "share.include_donations", fallback: "Include donations")
    /// Instagram
    public static let instagram = LFLocalizable.tr("Localizable", "share.instagram", fallback: "Instagram")
    /// Messages
    public static let messages = LFLocalizable.tr("Localizable", "share.messages", fallback: "Messages")
    /// More
    public static let more = LFLocalizable.tr("Localizable", "share.more", fallback: "More")
    /// Share
    public static let navigationTitle = LFLocalizable.tr("Localizable", "share.navigation_title", fallback: "Share")
    /// Snapchat
    public static let snapchat = LFLocalizable.tr("Localizable", "share.snapchat", fallback: "Snapchat")
    /// TikTok
    public static let tikTok = LFLocalizable.tr("Localizable", "share.tikTok", fallback: "TikTok")
    /// Twitter
    public static let twitter = LFLocalizable.tr("Localizable", "share.twitter", fallback: "Twitter")
    /// WhatsApp
    public static let whatsapp = LFLocalizable.tr("Localizable", "share.whatsapp", fallback: "WhatsApp")
    public enum Card {
      /// I'm using %@ to support %@ by making passive donations through my everyday purchases.
      public static func fundraiser(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "share.card.fundraiser", String(describing: p1), String(describing: p2), fallback: "I'm using %@ to support %@ by making passive donations through my everyday purchases.")
      }
    }
  }
  public enum ShippingAddress {
    public enum Address {
      /// Enter address
      public static let placeholder = LFLocalizable.tr("Localizable", "shippingAddress.address.placeholder", fallback: "Enter address")
    }
    public enum City {
      /// Enter city
      public static let placeholder = LFLocalizable.tr("Localizable", "shippingAddress.city.placeholder", fallback: "Enter city")
      /// City
      public static let title = LFLocalizable.tr("Localizable", "shippingAddress.city.title", fallback: "City")
    }
    public enum Confirm {
      /// Confirm Address
      public static let buttonTitle = LFLocalizable.tr("Localizable", "shippingAddress.confirm.buttonTitle", fallback: "Confirm Address")
    }
    public enum MainAddress {
      /// Address line 1 
      public static let title = LFLocalizable.tr("Localizable", "shippingAddress.mainAddress.title", fallback: "Address line 1 ")
    }
    public enum Screen {
      /// WHERE TO SEND YOUR %@?
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "shippingAddress.screen.title", String(describing: p1), fallback: "WHERE TO SEND YOUR %@?")
      }
    }
    public enum State {
      /// Enter state
      public static let placeholder = LFLocalizable.tr("Localizable", "shippingAddress.state.placeholder", fallback: "Enter state")
      /// State
      public static let title = LFLocalizable.tr("Localizable", "shippingAddress.state.title", fallback: "State")
    }
    public enum SubAddress {
      /// Address line 2 (optional)
      public static let title = LFLocalizable.tr("Localizable", "shippingAddress.subAddress.title", fallback: "Address line 2 (optional)")
    }
    public enum ZipCode {
      /// Enter zip code
      public static let placeholder = LFLocalizable.tr("Localizable", "shippingAddress.zipCode.placeholder", fallback: "Enter zip code")
      /// Zip Code
      public static let title = LFLocalizable.tr("Localizable", "shippingAddress.zipCode.title", fallback: "Zip Code")
    }
  }
  public enum SkipFundraiser {
    /// Skip
    public static let title = LFLocalizable.tr("Localizable", "skip_fundraiser.title", fallback: "Skip")
  }
  public enum SuggestCause {
    /// 1000 characters max
    public static let maxCharacters = LFLocalizable.tr("Localizable", "suggest_cause.max_characters", fallback: "1000 characters max")
    /// Enter text
    public static let placeholder = LFLocalizable.tr("Localizable", "suggest_cause.placeholder", fallback: "Enter text")
    /// Submit
    public static let submit = LFLocalizable.tr("Localizable", "suggest_cause.submit", fallback: "Submit")
    /// Please tell us more
    public static let tellMore = LFLocalizable.tr("Localizable", "suggest_cause.tell_more", fallback: "Please tell us more")
    /// Suggest a Cause
    public static let title = LFLocalizable.tr("Localizable", "suggest_cause.title", fallback: "Suggest a Cause")
    public enum Alert {
      /// Thank you for suggesting a cause. Our team will review and follow up.
      public static let message = LFLocalizable.tr("Localizable", "suggest_cause.alert.message", fallback: "Thank you for suggesting a cause. Our team will review and follow up.")
      /// THANK YOU
      public static let title = LFLocalizable.tr("Localizable", "suggest_cause.alert.title", fallback: "THANK YOU")
    }
  }
  public enum Taxes {
    /// We were unable to load Taxes right now.
    /// Please try again.
    public static let error = LFLocalizable.tr("Localizable", "taxes.error", fallback: "We were unable to load Taxes right now.\nPlease try again.")
    /// Taxes
    public static let navigationTitle = LFLocalizable.tr("Localizable", "taxes.navigation_title", fallback: "Taxes")
    /// Retry
    public static let retry = LFLocalizable.tr("Localizable", "taxes.retry", fallback: "Retry")
    /// Created %@
    public static func value(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "taxes.value", String(describing: p1), fallback: "Created %@")
    }
    public enum Empty {
      /// There are currently no tax statements
      public static let message = LFLocalizable.tr("Localizable", "taxes.empty.message", fallback: "There are currently no tax statements")
      /// NO STATEMENTS
      public static let title = LFLocalizable.tr("Localizable", "taxes.empty.title", fallback: "NO STATEMENTS")
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
  public enum Textfield {
    public enum Search {
      /// Search...
      public static let placeholder = LFLocalizable.tr("Localizable", "textfield.search.placeholder", fallback: "Search...")
    }
  }
  public enum Toast {
    public enum Copy {
      /// Copied to clipboard
      public static let message = LFLocalizable.tr("Localizable", "toast.copy.message", fallback: "Copied to clipboard")
    }
  }
  public enum TransactionCard {
    public enum Cashback {
      /// Cashback
      public static let title = LFLocalizable.tr("Localizable", "transactionCard.cashback.title", fallback: "Cashback")
    }
    public enum Crypto {
      /// %@ Earned
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionCard.crypto.title", String(describing: p1), fallback: "%@ Earned")
      }
    }
    public enum Donation {
      /// Donation to %@
      public static func header(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionCard.donation.header", String(describing: p1), fallback: "Donation to %@")
      }
      /// Supporting %@ - %@.
      public static func message(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionCard.donation.message", String(describing: p1), String(describing: p2), fallback: "Supporting %@ - %@.")
      }
      /// Donation
      public static let title = LFLocalizable.tr("Localizable", "transactionCard.donation.title", fallback: "Donation")
    }
    public enum Purchase {
      /// I earned %@ by making a %@ purchase with %@.
      public static func message(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionCard.purchase.message", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "I earned %@ by making a %@ purchase with %@.")
      }
    }
    public enum Share {
      /// Share
      public static let title = LFLocalizable.tr("Localizable", "transactionCard.share.title", fallback: "Share")
    }
    public enum ShareCashback {
      /// I earned %@ back by using my Visa %@. Get one here: %@
      public static func title(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionCard.shareCashback.title", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "I earned %@ back by using my Visa %@. Get one here: %@")
      }
    }
    public enum ShareCrypto {
      /// I earned %@ by using my Visa %@. Get one here: %@
      public static func title(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionCard.shareCrypto.title", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "I earned %@ by using my Visa %@. Get one here: %@")
      }
    }
    public enum ShareDonationAmount {
      /// I donated %@ to %@ using %@. Join us in supporting %@.
      public static func message(_ p1: Any, _ p2: Any, _ p3: Any, _ p4: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionCard.shareDonationAmount.message", String(describing: p1), String(describing: p2), String(describing: p3), String(describing: p4), fallback: "I donated %@ to %@ using %@. Join us in supporting %@.")
      }
    }
    public enum ShareDonationGeneric {
      /// We're raising money for %@ using %@. Join us in supporting %@.
      public static func message(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionCard.shareDonationGeneric.message", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "We're raising money for %@ using %@. Join us in supporting %@.")
      }
    }
  }
  public enum TransactionDetail {
    /// Title
    public static let title = LFLocalizable.tr("Localizable", "transactionDetail.title", fallback: "Title")
    public enum Balance {
      /// Balance
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.balance.title", fallback: "Balance")
    }
    public enum BalanceCash {
      /// Balance: %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionDetail.balanceCash.title", String(describing: p1), fallback: "Balance: %@")
      }
    }
    public enum Buy {
      /// BUY
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.buy.title", fallback: "BUY")
    }
    public enum CancelDeposit {
      /// Cancel Deposit
      public static let button = LFLocalizable.tr("Localizable", "transactionDetail.cancelDeposit.button", fallback: "Cancel Deposit")
    }
    public enum CurrentReward {
      /// Current Rewards
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.currentReward.title", fallback: "Current Rewards")
    }
    public enum CurrentRewards {
      /// Current rewards
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.currentRewards.title", fallback: "Current rewards")
    }
    public enum Description {
      /// Description
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.description.title", fallback: "Description")
    }
    public enum Donation {
      /// Donation
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.donation.title", fallback: "Donation")
    }
    public enum Fee {
      /// Fee
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.fee.title", fallback: "Fee")
    }
    public enum Merchant {
      /// Vendor
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.merchant.title", fallback: "Vendor")
    }
    public enum NetworkFee {
      /// Network Fee
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.networkFee.title", fallback: "Network Fee")
    }
    public enum Nickname {
      /// Nickname
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.nickname.title", fallback: "Nickname")
    }
    public enum OrderType {
      /// Order Type
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.orderType.title", fallback: "Order Type")
    }
    public enum PaidTo {
      /// Paid To
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.paidTo.title", fallback: "Paid To")
    }
    public enum Price {
      /// Price
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.price.title", fallback: "Price")
    }
    public enum Receipt {
      /// Receipt
      public static let button = LFLocalizable.tr("Localizable", "transactionDetail.receipt.button", fallback: "Receipt")
    }
    public enum Receive {
      /// RECEIVE
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.receive.title", fallback: "RECEIVE")
    }
    public enum ReceivedFrom {
      /// Received From
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.receivedFrom.title", fallback: "Received From")
    }
    public enum Reward {
      /// Reward
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.reward.title", fallback: "Reward")
    }
    public enum RewardDisclosure {
      /// *You will earn rewards with each qualifying purchase on your CauseCard. CauseCard “rewards” are donated to the non-profit you have selected in accordance with our Terms. Qualifying Purchases do not include any other payment or transfer, including incoming transactions, outgoing transactions where you are the receiving party, peer to peer transactions, ACH Transactions, ATM transactions, fees, chargebacks, adjustments, purchases that use PIN, or wire transfers. For more information, see the Terms. Rewards Program is managed by CauseCard. CauseCard is not FDIC insured. Rewards Program is not managed by Lewis and Clark Bank.
      public static let description = LFLocalizable.tr("Localizable", "transactionDetail.rewardDisclosure.description", fallback: "*You will earn rewards with each qualifying purchase on your CauseCard. CauseCard “rewards” are donated to the non-profit you have selected in accordance with our Terms. Qualifying Purchases do not include any other payment or transfer, including incoming transactions, outgoing transactions where you are the receiving party, peer to peer transactions, ACH Transactions, ATM transactions, fees, chargebacks, adjustments, purchases that use PIN, or wire transfers. For more information, see the Terms. Rewards Program is managed by CauseCard. CauseCard is not FDIC insured. Rewards Program is not managed by Lewis and Clark Bank.")
      public enum Links {
        /// Terms
        public static let terms = LFLocalizable.tr("Localizable", "transactionDetail.rewardDisclosure.links.terms", fallback: "Terms")
      }
    }
    public enum Rewards {
      /// Rewards
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.rewards.title", fallback: "Rewards")
    }
    public enum SaveWalletPopup {
      /// Save wallet address
      public static let button = LFLocalizable.tr("Localizable", "transactionDetail.saveWalletPopup.button", fallback: "Save wallet address")
      /// Would you like to save this wallet address to use again?
      public static let description = LFLocalizable.tr("Localizable", "transactionDetail.saveWalletPopup.description", fallback: "Would you like to save this wallet address to use again?")
      /// SAVE WALLET ADDRESS
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.saveWalletPopup.title", fallback: "SAVE WALLET ADDRESS")
    }
    public enum Sell {
      /// SELL
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.sell.title", fallback: "SELL")
    }
    public enum Send {
      /// SEND
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.send.title", fallback: "SEND")
    }
    public enum Source {
      /// Source
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.source.title", fallback: "Source")
    }
    public enum TotalDonated {
      /// Total Donated: %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionDetail.totalDonated.title", String(describing: p1), fallback: "Total Donated: %@")
      }
    }
    public enum TransactionId {
      /// Transaction Id
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.transactionId.title", fallback: "Transaction Id")
    }
    public enum TransactionStatus {
      /// Status
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.transactionStatus.title", fallback: "Status")
    }
    public enum TransactionType {
      /// Transaction Type
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.transactionType.title", fallback: "Transaction Type")
    }
    public enum WalletAddress {
      /// Wallet Address
      public static let title = LFLocalizable.tr("Localizable", "transactionDetail.walletAddress.title", fallback: "Wallet Address")
    }
  }
  public enum TransactionList {
    /// Transactions
    public static let title = LFLocalizable.tr("Localizable", "transactionList.title", fallback: "Transactions")
  }
  public enum TransactionRow {
    /// Pending
    public static let pending = LFLocalizable.tr("Localizable", "transactionRow.pending", fallback: "Pending")
    public enum FundraiserDonation {
      /// Donation
      public static let generic = LFLocalizable.tr("Localizable", "transactionRow.fundraiser_donation.generic", fallback: "Donation")
      /// Donation by %@
      public static func user(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transactionRow.fundraiser_donation.user", String(describing: p1), fallback: "Donation by %@")
      }
    }
  }
  public enum TransactionRewardsStatus {
    /// Completed
    public static let completed = LFLocalizable.tr("Localizable", "transaction_rewards_status.completed", fallback: "Completed")
    /// Pending
    public static let pending = LFLocalizable.tr("Localizable", "transaction_rewards_status.pending", fallback: "Pending")
  }
  public enum TransferDebitSuggestion {
    /// Get Faster Deposits
    public static let title = LFLocalizable.tr("Localizable", "transferDebitSuggestion.title", fallback: "Get Faster Deposits")
    public enum Body {
      /// For instant deposits, connect and deposit with your Debit Card
      public static let title = LFLocalizable.tr("Localizable", "transferDebitSuggestion.body.title", fallback: "For instant deposits, connect and deposit with your Debit Card")
    }
    public enum Connect {
      /// Connect Debit Card
      public static let title = LFLocalizable.tr("Localizable", "transferDebitSuggestion.connect.title", fallback: "Connect Debit Card")
    }
  }
  public enum TransferLimit {
    public enum Alltime {
      /// AllTime
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.alltime.title", fallback: "AllTime")
    }
    public enum BankDeposit {
      /// Connect your external bank through Plaid, and use the %@ app to deposit.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transferLimit.bankDeposit.message", String(describing: p1), fallback: "Connect your external bank through Plaid, and use the %@ app to deposit.")
      }
      /// Bank Account Deposit Limits
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.bankDeposit.title", fallback: "Bank Account Deposit Limits")
    }
    public enum BankWithdrawal {
      /// Connect your external bank through Plaid, and use the %@ app to withdrawal.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transferLimit.bankWithdrawal.message", String(describing: p1), fallback: "Connect your external bank through Plaid, and use the %@ app to withdrawal.")
      }
      /// Bank Account Withdrawal Limits
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.bankWithdrawal.title", fallback: "Bank Account Withdrawal Limits")
    }
    public enum CardDeposit {
      /// Use your bank’s Debit Card to instantly deposit funds to your %@ Account.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transferLimit.cardDeposit.message", String(describing: p1), fallback: "Use your bank’s Debit Card to instantly deposit funds to your %@ Account.")
      }
      /// Debit Card Deposit Limits
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.cardDeposit.title", fallback: "Debit Card Deposit Limits")
    }
    public enum CardWithdrawal {
      /// Use your bank’s Debit Card to instantly withdraw funds from your %@ Account.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transferLimit.cardWithdrawal.message", String(describing: p1), fallback: "Use your bank’s Debit Card to instantly withdraw funds from your %@ Account.")
      }
      /// Debit Card Withdrawal Limits
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.cardWithdrawal.title", fallback: "Debit Card Withdrawal Limits")
    }
    public enum CreateSupportTicket {
      /// Support Ticket
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.createSupportTicket.title", fallback: "Support Ticket")
    }
    public enum Daily {
      /// Daily
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.daily.title", fallback: "Daily")
    }
    public enum Deposit {
      /// Deposit
      public static let tabTitle = LFLocalizable.tr("Localizable", "transferLimit.deposit.tabTitle", fallback: "Deposit")
      public enum TotallLimits {
        /// Send external bank transfers or Direct Deposit to your %@ account using account and routing number.
        public static func message(_ p1: Any) -> String {
          return LFLocalizable.tr("Localizable", "transferLimit.deposit.totall_limits.message", String(describing: p1), fallback: "Send external bank transfers or Direct Deposit to your %@ account using account and routing number.")
        }
        /// Deposit limits
        public static let title = LFLocalizable.tr("Localizable", "transferLimit.deposit.totall_limits.title", fallback: "Deposit limits")
      }
    }
    public enum Error {
      /// We were unable to load transfer limits right now.
      /// Please try again.
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.error.title", fallback: "We were unable to load transfer limits right now.\nPlease try again.")
    }
    public enum FinancialInstitutionsLimits {
      /// There are limits to how much you can “pull” to your card. This includes funds deposited using the app’s “Deposit” feature.
      public static let message = LFLocalizable.tr("Localizable", "transferLimit.financialInstitutionsLimits.message", fallback: "There are limits to how much you can “pull” to your card. This includes funds deposited using the app’s “Deposit” feature.")
      /// Financial Institutions Spending Limits
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.financialInstitutionsLimits.title", fallback: "Financial Institutions Spending Limits")
    }
    public enum IncreaseLimit {
      /// Your request to increase the limits has been sent successfully!
      public static let message = LFLocalizable.tr("Localizable", "transferLimit.increaseLimit.message", fallback: "Your request to increase the limits has been sent successfully!")
    }
    public enum IncreaseLimitInReview {
      /// You already submitted a request to increase your limits. Thanks for your patience!
      public static let message = LFLocalizable.tr("Localizable", "transferLimit.increaseLimitInReview.message", fallback: "You already submitted a request to increase your limits. Thanks for your patience!")
    }
    public enum Monthly {
      /// Monthly
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.monthly.title", fallback: "Monthly")
    }
    public enum PerTransaction {
      /// Per Transaction
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.perTransaction.title", fallback: "Per Transaction")
    }
    public enum RequestLimitIncrease {
      /// Request Limit Increase
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.requestLimitIncrease.title", fallback: "Request Limit Increase")
    }
    public enum Screen {
      /// Limits
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.screen.title", fallback: "Limits")
    }
    public enum SendToCard {
      /// There are limits to how much you can “pull” to your card. This includes funds deposited using the app’s “Deposit” feature.
      public static let message = LFLocalizable.tr("Localizable", "transferLimit.sendToCard.message", fallback: "There are limits to how much you can “pull” to your card. This includes funds deposited using the app’s “Deposit” feature.")
      /// Send to %@Card
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transferLimit.sendToCard.title", String(describing: p1), fallback: "Send to %@Card")
      }
    }
    public enum Spending {
      /// Spending
      public static let tabTitle = LFLocalizable.tr("Localizable", "transferLimit.spending.tabTitle", fallback: "Spending")
    }
    public enum SpendingLimits {
      /// There are limits to how much you can “pull” to your card. This includes funds deposited using the app’s “Deposit” feature.
      public static let message = LFLocalizable.tr("Localizable", "transferLimit.spendingLimits.message", fallback: "There are limits to how much you can “pull” to your card. This includes funds deposited using the app’s “Deposit” feature.")
      /// Spending Limits
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.spendingLimits.title", fallback: "Spending Limits")
    }
    public enum Weekly {
      /// Weekly
      public static let title = LFLocalizable.tr("Localizable", "transferLimit.weekly.title", fallback: "Weekly")
    }
    public enum Withdraw {
      /// Withdrawal
      public static let tabTitle = LFLocalizable.tr("Localizable", "transferLimit.withdraw.tabTitle", fallback: "Withdrawal")
      public enum TotallLimits {
        /// Withdraw external bank transfers or Direct Deposit to your %@ account using account and routing number.
        public static func message(_ p1: Any) -> String {
          return LFLocalizable.tr("Localizable", "transferLimit.withdraw.totall_limits.message", String(describing: p1), fallback: "Withdraw external bank transfers or Direct Deposit to your %@ account using account and routing number.")
        }
        /// Withdrawal Limits
        public static let title = LFLocalizable.tr("Localizable", "transferLimit.withdraw.totall_limits.title", fallback: "Withdrawal Limits")
      }
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
    public enum AmountTooLow {
      /// This transaction was blocked because amount is too low.
      public static let message = LFLocalizable.tr("Localizable", "transferView.amountTooLow.message", fallback: "This transaction was blocked because amount is too low.")
      /// We're sorry
      public static let title = LFLocalizable.tr("Localizable", "transferView.amountTooLow.title", fallback: "We're sorry")
    }
    public enum BankLimits {
      /// This deposit was blocked because it is over your banks current withdraw limit. Please contact your bank to raise the limit.
      public static let message = LFLocalizable.tr("Localizable", "transferView.bankLimits.message", fallback: "This deposit was blocked because it is over your banks current withdraw limit. Please contact your bank to raise the limit.")
      /// We're sorry
      public static let title = LFLocalizable.tr("Localizable", "transferView.bankLimits.title", fallback: "We're sorry")
    }
    public enum DebitSuggestion {
      /// For instant deposits, connect and deposit with your Debit Card
      public static let body = LFLocalizable.tr("Localizable", "transferView.debit_suggestion.body", fallback: "For instant deposits, connect and deposit with your Debit Card")
      /// Connect Debit Card
      public static let connect = LFLocalizable.tr("Localizable", "transferView.debit_suggestion.connect", fallback: "Connect Debit Card")
      /// Get Faster Deposits
      public static let title = LFLocalizable.tr("Localizable", "transferView.debit_suggestion.title", fallback: "Get Faster Deposits")
    }
    public enum InsufficientFundsPopup {
      /// We were unable to %@ due to insufficient funds. Please try again or contact support.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transferView.insufficientFundsPopup.message", String(describing: p1), fallback: "We were unable to %@ due to insufficient funds. Please try again or contact support.")
      }
      /// Insufficient funds
      public static let title = LFLocalizable.tr("Localizable", "transferView.insufficientFundsPopup.title", fallback: "Insufficient funds")
    }
    public enum LimitsReachedPopup {
      /// We're sorry, your deposit crossed your current limit. Please contact support to increase your limits.
      public static let message = LFLocalizable.tr("Localizable", "transferView.limits_reached_popup.message", fallback: "We're sorry, your deposit crossed your current limit. Please contact support to increase your limits.")
      /// Deposit limit reached
      public static let title = LFLocalizable.tr("Localizable", "transferView.limits_reached_popup.title", fallback: "Deposit limit reached")
    }
    public enum RewardType {
      public enum Cashback {
        /// 0.75% on every qualifying purchase
        public static func subtitle(_ p1: Int) -> String {
          return LFLocalizable.tr("Localizable", "transferView.reward_type.cashback.subtitle", p1, fallback: "0.75% on every qualifying purchase")
        }
        /// Cashback
        public static let title = LFLocalizable.tr("Localizable", "transferView.reward_type.cashback.title", fallback: "Cashback")
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
      /// Failed
      public static let failed = LFLocalizable.tr("Localizable", "transferView.rewards_status.failed", fallback: "Failed")
      /// Pending
      public static let pending = LFLocalizable.tr("Localizable", "transferView.rewards_status.pending", fallback: "Pending")
    }
    public enum Status {
      /// Free
      public static let free = LFLocalizable.tr("Localizable", "transferView.status.free", fallback: "Free")
      /// Transfer Fee
      public static let transferFee = LFLocalizable.tr("Localizable", "transferView.status.transferFee", fallback: "Transfer Fee")
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
  public enum UnspecifiedRewards {
    /// Select Reward
    public static let cta = LFLocalizable.tr("Localizable", "unspecified_rewards.cta", fallback: "Select Reward")
    /// CHOOSE BETWEEN
    public static let title = LFLocalizable.tr("Localizable", "unspecified_rewards.title", fallback: "CHOOSE BETWEEN")
  }
  public enum UpdateAppView {
    /// You’re on an older version of the %@ app. Please update to the latest version.
    public static func message(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "updateAppView.message", String(describing: p1), fallback: "You’re on an older version of the %@ app. Please update to the latest version.")
    }
    /// UPDATE APP
    public static let title = LFLocalizable.tr("Localizable", "updateAppView.title", fallback: "UPDATE APP")
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
  public enum UserRewardType {
    public enum Cashback {
      /// Earning cash back rewards
      public static let description = LFLocalizable.tr("Localizable", "user_reward_type.cashback.description", fallback: "Earning cash back rewards")
      /// %.2f%% on every qualifying purchase
      public static func subtitle(_ p1: Float) -> String {
        return LFLocalizable.tr("Localizable", "user_reward_type.cashback.subtitle", p1, fallback: "%.2f%% on every qualifying purchase")
      }
      /// Cash Back
      public static let title = LFLocalizable.tr("Localizable", "user_reward_type.cashback.title", fallback: "Cash Back")
    }
    public enum Donation {
      /// %.2f%%  donated to a charity you choose
      public static func subtitle(_ p1: Float) -> String {
        return LFLocalizable.tr("Localizable", "user_reward_type.donation.subtitle", p1, fallback: "%.2f%%  donated to a charity you choose")
      }
      /// Donate to Charity
      public static let title = LFLocalizable.tr("Localizable", "user_reward_type.donation.title", fallback: "Donate to Charity")
    }
  }
  public enum VerificationCode {
    public enum EnterCode {
      /// ENTER VERIFICATION CODE
      public static let screenTitle = LFLocalizable.tr("Localizable", "verificationCode.enterCode.screenTitle", fallback: "ENTER VERIFICATION CODE")
      /// Enter Code
      public static let textFieldPlaceholder = LFLocalizable.tr("Localizable", "verificationCode.enterCode.textFieldPlaceholder", fallback: "Enter Code")
    }
    public enum OtpInvalid {
      /// OTP is invalid. Please resend OTP
      public static let message = LFLocalizable.tr("Localizable", "verificationCode.otpInvalid.message", fallback: "OTP is invalid. Please resend OTP")
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
  public enum VerifyCard {
    /// Check your card activity for 1 pending micro-transaction from AvalancheCard. Enter the one amount in the fields below. Once verified, this transaction will be canceled
    public static let detail = LFLocalizable.tr("Localizable", "verify_card.detail", fallback: "Check your card activity for 1 pending micro-transaction from AvalancheCard. Enter the one amount in the fields below. Once verified, this transaction will be canceled")
    /// Verify card ownership
    public static let title = LFLocalizable.tr("Localizable", "verify_card.title", fallback: "Verify card ownership")
    public enum Amount {
      /// Enter amount
      public static let placeholder = LFLocalizable.tr("Localizable", "verify_card.amount.placeholder", fallback: "Enter amount")
      /// Amount
      public static let title = LFLocalizable.tr("Localizable", "verify_card.amount.title", fallback: "Amount")
    }
    public enum Button {
      /// Verify Card
      public static let verifyCard = LFLocalizable.tr("Localizable", "verify_card.button.verifyCard", fallback: "Verify Card")
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
      /// The DogeCard is an easy way to spend cash or Dogecoin, and earn rewards.  Here is how: 
      public static let desc = LFLocalizable.tr("Localizable", "welcome.header.desc", fallback: "The DogeCard is an easy way to spend cash or Dogecoin, and earn rewards.  Here is how: ")
      /// WELCOME!
      public static let title = LFLocalizable.tr("Localizable", "welcome.header.title", fallback: "WELCOME!")
    }
    public enum HowItWorks {
      /// Create an account
      public static let item1 = LFLocalizable.tr("Localizable", "welcome.how_it_works.item1", fallback: "Create an account")
      /// Use your DogeCard anywhere Visa is accepted
      public static let item2 = LFLocalizable.tr("Localizable", "welcome.how_it_works.item2", fallback: "Use your DogeCard anywhere Visa is accepted")
      /// Spend cash or Dogecoin, earn rewards
      public static let item3 = LFLocalizable.tr("Localizable", "welcome.how_it_works.item3", fallback: "Spend cash or Dogecoin, earn rewards")
    }
  }
  public enum YourAccount {
    /// By agreeing to the E-Signature Agreement, you consent to receive electronic disclosures and/or statements for your CauseCard account and consent to be legally bound to this agreement.
    public static let body = LFLocalizable.tr("Localizable", "yourAccount.body", fallback: "By agreeing to the E-Signature Agreement, you consent to receive electronic disclosures and/or statements for your CauseCard account and consent to be legally bound to this agreement.")
    /// Liquidity Financial, doing business as CauseCard, has partnered with Solid Financial and Lewis and Clark Bank to provide banking and card services.
    public static let subtitle = LFLocalizable.tr("Localizable", "yourAccount.subtitle", fallback: "Liquidity Financial, doing business as CauseCard, has partnered with Solid Financial and Lewis and Clark Bank to provide banking and card services.")
    /// YOUR ACCOUNT
    public static let title = LFLocalizable.tr("Localizable", "yourAccount.title", fallback: "YOUR ACCOUNT")
    public enum Agreements {
      /// I read and agree to the: Consumer Account and Cardholder Agreement, Terms and Conditions, and Privacy Policy
      public static let consumerTermsConditions = LFLocalizable.tr("Localizable", "yourAccount.agreements.consumerTermsConditions", fallback: "I read and agree to the: Consumer Account and Cardholder Agreement, Terms and Conditions, and Privacy Policy")
      /// I accept the E-Signature Agreement and continue
      public static let esignature = LFLocalizable.tr("Localizable", "yourAccount.agreements.esignature", fallback: "I accept the E-Signature Agreement and continue")
    }
    public enum Links {
      /// Consumer Account and Cardholder Agreement
      public static let consumerCardholder = LFLocalizable.tr("Localizable", "yourAccount.links.consumerCardholder", fallback: "Consumer Account and Cardholder Agreement")
      /// E-Signature Agreement
      public static let esignature = LFLocalizable.tr("Localizable", "yourAccount.links.esignature", fallback: "E-Signature Agreement")
      /// Privacy Policy
      public static let privacy = LFLocalizable.tr("Localizable", "yourAccount.links.privacy", fallback: "Privacy Policy")
      /// Terms and Conditions
      public static let terms = LFLocalizable.tr("Localizable", "yourAccount.links.terms", fallback: "Terms and Conditions")
    }
  }
  public enum Zerohash {
    public enum Disclosure {
      /// Cryptocurrency services powered by Zero Hash
      public static let description = LFLocalizable.tr("Localizable", "zerohash.disclosure.description", fallback: "Cryptocurrency services powered by Zero Hash")
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
