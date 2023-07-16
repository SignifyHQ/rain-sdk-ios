// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum LFLocalizable {
  /// 3 to 4 days
  public static let _3to4days = LFLocalizable.tr("Localizable", "3to4days", fallback: "3 to 4 days")
  /// We could not load your account at this time. Please contact support, or try again later.
  public static let accountErrorMessage = LFLocalizable.tr("Localizable", "account_error_message", fallback: "We could not load your account at this time. Please contact support, or try again later.")
  /// Account Number
  public static let accountNumber = LFLocalizable.tr("Localizable", "account_number", fallback: "Account Number")
  /// ACCOUNT UPDATE
  public static let accountUpdate = LFLocalizable.tr("Localizable", "account_update", fallback: "ACCOUNT UPDATE")
  /// Activate
  public static let activate = LFLocalizable.tr("Localizable", "activate", fallback: "Activate")
  /// Tap to Activate Card
  public static let activateCardButtontitle = LFLocalizable.tr("Localizable", "activate_card_buttontitle", fallback: "Tap to Activate Card")
  /// ACTIVATE CARD
  public static let activateCardTitle = LFLocalizable.tr("Localizable", "activateCard_title", fallback: "ACTIVATE CARD")
  /// Add bank or card
  public static let addAccount = LFLocalizable.tr("Localizable", "add_account", fallback: "Add bank or card")
  /// ADD A BANK USING YOUR DEBIT CARD
  public static let addBankUsingDebit = LFLocalizable.tr("Localizable", "add_bank_using_debit", fallback: "ADD A BANK USING YOUR DEBIT CARD")
  /// ADD CHECK IMAGES
  public static let addCheckImages = LFLocalizable.tr("Localizable", "add_check_images", fallback: "ADD CHECK IMAGES")
  /// Deposit
  public static let addMoney = LFLocalizable.tr("Localizable", "add_money", fallback: "Deposit")
  /// ADD PERSONAL INFORMATION
  public static let addPersonalInfo = LFLocalizable.tr("Localizable", "add_personalInfo", fallback: "ADD PERSONAL INFORMATION")
  /// Add to wallet
  public static let addToWallet = LFLocalizable.tr("Localizable", "add_to_wallet", fallback: "Add to wallet")
  /// Address
  public static let address = LFLocalizable.tr("Localizable", "address", fallback: "Address")
  /// WHERE TO SEND YOUR %@ CARD?
  public static func addressTitle(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "address_title", String(describing: p1), fallback: "WHERE TO SEND YOUR %@ CARD?")
  }
  /// Address line 1 
  public static let addressLine1Title = LFLocalizable.tr("Localizable", "addressLine1_title", fallback: "Address line 1 ")
  /// Address line 2
  public static let addressLine2Title = LFLocalizable.tr("Localizable", "addressLine2_title", fallback: "Address line 2")
  /// All Charities
  public static let allCharities = LFLocalizable.tr("Localizable", "all_charities", fallback: "All Charities")
  /// Amount
  public static let amount = LFLocalizable.tr("Localizable", "amount", fallback: "Amount")
  /// up to 8% purchase of transaction
  public static func amountDescription(_ p1: UnsafeRawPointer) -> String {
    return LFLocalizable.tr("Localizable", "amount_description", Int(bitPattern: p1), fallback: "up to 8% purchase of transaction")
  }
  /// Transaction Amount
  public static let amountTitle = LFLocalizable.tr("Localizable", "amount_title", fallback: "Transaction Amount")
  /// Update
  public static let appUpdateButtonUpdate = LFLocalizable.tr("Localizable", "appUpdate_buttonUpdate", fallback: "Update")
  /// There is a new and improved version of CauseCard available on the App Store. Update your app to make sure you have the best possible experience.
  public static let appUpdateMessage = LFLocalizable.tr("Localizable", "appUpdate_Message", fallback: "There is a new and improved version of CauseCard available on the App Store. Update your app to make sure you have the best possible experience.")
  /// App Update Available
  public static let appUpdateTitle = LFLocalizable.tr("Localizable", "appUpdate_Title", fallback: "App Update Available")
  /// %@ DOGE available
  public static func availableTransferCrypto(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "available_transfer_crypto", String(describing: p1), fallback: "%@ DOGE available")
  }
  /// Avoid shadows
  public static let avoidShadows = LFLocalizable.tr("Localizable", "avoid_shadows", fallback: "Avoid shadows")
  /// Back
  public static let back = LFLocalizable.tr("Localizable", "back", fallback: "Back")
  /// Back of check
  public static let backCheck = LFLocalizable.tr("Localizable", "back_check", fallback: "Back of check")
  /// take photo of back of check
  public static let backTakePhoto = LFLocalizable.tr("Localizable", "back_take_photo", fallback: "take photo of back of check")
  /// Back to Guest Mode
  public static let backToGuestMode = LFLocalizable.tr("Localizable", "backTo_guestMode", fallback: "Back to Guest Mode")
  /// Balance
  public static let balance = LFLocalizable.tr("Localizable", "balance", fallback: "Balance")
  /// Created %@
  public static func bankStatementCreated(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "bank_statement_created", String(describing: p1), fallback: "Created %@")
  }
  /// There are currently no bank statements
  public static let bankStatementEmptyInfo = LFLocalizable.tr("Localizable", "bank_statement_emptyInfo", fallback: "There are currently no bank statements")
  /// NO STATEMENTS
  public static let bankStatementEmptyTitle = LFLocalizable.tr("Localizable", "bank_statement_emptyTitle", fallback: "NO STATEMENTS")
  /// Bank Statements
  public static let bankStatementTitle = LFLocalizable.tr("Localizable", "bank_statement_title", fallback: "Bank Statements")
  /// Beware of Fraud 
  /// 
  ///  Cryptocurrencies and money transfer services arecommonly targeted by hackers and criminals who commitfraud. For more information on how to protect againstfraud, visit the Consumer Financial Protection Bureau'swebsite at 
  ///  https://www.consumerfinance.gov/consumer-tools/fraud
  public static let bewareDesc = LFLocalizable.tr("Localizable", "beware_desc", fallback: "Beware of Fraud \n\n Cryptocurrencies and money transfer services arecommonly targeted by hackers and criminals who commitfraud. For more information on how to protect againstfraud, visit the Consumer Financial Protection Bureau'swebsite at \n https://www.consumerfinance.gov/consumer-tools/fraud")
  /// Beware of Fraud 
  /// 
  public static let bewareText = LFLocalizable.tr("Localizable", "beware_text", fallback: "Beware of Fraud \n")
  /// USD->DOGE
  public static let buyCardanoDescription = LFLocalizable.tr("Localizable", "buy_Cardano_description", fallback: "USD->DOGE")
  /// Doge Purchase
  public static let buyCardanoTitle = LFLocalizable.tr("Localizable", "buy_Cardano_title", fallback: "Doge Purchase")
  /// Cancel
  public static let cancel = LFLocalizable.tr("Localizable", "cancel", fallback: "Cancel")
  /// Cancel account
  public static let cancelAccount = LFLocalizable.tr("Localizable", "cancel_account", fallback: "Cancel account")
  /// All transactions are final. You are responsible for reviewing this receipt for accuracy land for notifying Zero Hash LLC of any suspected errors via email at support@zerohash.com within 24 hours of the trade. 
  /// 
  /// 
  public static let cancellationDesc = LFLocalizable.tr("Localizable", "cancellation_desc", fallback: "All transactions are final. You are responsible for reviewing this receipt for accuracy land for notifying Zero Hash LLC of any suspected errors via email at support@zerohash.com within 24 hours of the trade. \n\n")
  /// Cancellation Policy 
  /// 
  public static let cancellationPolicy = LFLocalizable.tr("Localizable", "cancellation_policy", fallback: "Cancellation Policy \n")
  /// Your %@ is now active, and can be used anywhere Visa is accepted. Please set your PIN for added security.
  public static func cardActivatedCardDescription(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "card_activated_card_description", String(describing: p1), fallback: "Your %@ is now active, and can be used anywhere Visa is accepted. Please set your PIN for added security.")
  }
  /// Card activated!
  public static let cardActivatedTitle = LFLocalizable.tr("Localizable", "card_activated_title", fallback: "Card activated!")
  /// CVV
  public static let cardCvv = LFLocalizable.tr("Localizable", "card_cvv", fallback: "CVV")
  /// Exp
  public static let cardExp = LFLocalizable.tr("Localizable", "card_exp", fallback: "Exp")
  /// Expire date
  public static let cardExpiryDate = LFLocalizable.tr("Localizable", "card_expiryDate", fallback: "Expire date")
  /// Last 4 digits on your card
  public static let cardLast4 = LFLocalizable.tr("Localizable", "card_last4", fallback: "Last 4 digits on your card")
  /// Enter last 4 digits
  public static let cardLast4Placeholder = LFLocalizable.tr("Localizable", "card_last4_placeholder", fallback: "Enter last 4 digits")
  /// Card number
  public static let cardNumber = LFLocalizable.tr("Localizable", "card_number", fallback: "Card number")
  /// Purchase
  public static let cardTransaction = LFLocalizable.tr("Localizable", "card_transaction", fallback: "Purchase")
  /// doge@zerohash.com
  public static let cardanoLink = LFLocalizable.tr("Localizable", "cardano_link", fallback: "doge@zerohash.com")
  /// Doge Deals
  public static let cardanoRewardTitle = LFLocalizable.tr("Localizable", "cardano_reward_title", fallback: "Doge Deals")
  /// CASH
  public static let cash = LFLocalizable.tr("Localizable", "cash", fallback: "CASH")
  /// Balance
  public static let cashBalance = LFLocalizable.tr("Localizable", "cash_balance", fallback: "Balance")
  /// Reproductive Rights Charities
  public static let charitiesCategory = LFLocalizable.tr("Localizable", "charities_category", fallback: "Reproductive Rights Charities")
  /// Charities supported
  public static let charitiesSupported = LFLocalizable.tr("Localizable", "charities_supported", fallback: "Charities supported")
  /// Check Account Status
  public static let checkAccountStatus = LFLocalizable.tr("Localizable", "check_account_status", fallback: "Check Account Status")
  /// YOUR CHECK HAS BEEN RECEIVED.
  public static let checkSubmitted = LFLocalizable.tr("Localizable", "check_submitted", fallback: "YOUR CHECK HAS BEEN RECEIVED.")
  /// City
  public static let city = LFLocalizable.tr("Localizable", "city", fallback: "City")
  /// Code sent to %@
  public static func codeSentTo(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "code_sentTo %@", String(describing: p1), fallback: "Code sent to %@")
  }
  /// plug account info to transfer funds from another bank
  public static let connectAccountsInfo = LFLocalizable.tr("Localizable", "connect_accounts_info", fallback: "plug account info to transfer funds from another bank")
  /// Connect a bank
  public static let connectBankAccounts = LFLocalizable.tr("Localizable", "connect_bank_accounts", fallback: "Connect a bank")
  /// Connect a debit dard
  public static let connectDebitCardAccounts = LFLocalizable.tr("Localizable", "connect_debitCard_accounts", fallback: "Connect a debit dard")
  /// Connected Accounts
  public static let connectedAccounts = LFLocalizable.tr("Localizable", "connected_accounts", fallback: "Connected Accounts")
  /// https://www.consumerfinance.gov/consumer-tools/fraud
  public static let consumerTools = LFLocalizable.tr("Localizable", "consumer_tools", fallback: "https://www.consumerfinance.gov/consumer-tools/fraud")
  /// Contact us
  public static let contactUs = LFLocalizable.tr("Localizable", "contact_us", fallback: "Contact us")
  /// Continue
  public static let `continue` = LFLocalizable.tr("Localizable", "continue", fallback: "Continue")
  /// Copied!
  public static let copyText = LFLocalizable.tr("Localizable", "copy_text", fallback: "Copied!")
  /// Card number copied to clipboard
  public static let copycardtext = LFLocalizable.tr("Localizable", "copycardtext", fallback: "Card number copied to clipboard")
  /// Create Account
  public static let createAccount = LFLocalizable.tr("Localizable", "create_account", fallback: "Create Account")
  /// CREATE ACCOUNT
  public static let createCardanoAccount = LFLocalizable.tr("Localizable", "create_cardanoAccount", fallback: "CREATE ACCOUNT")
  /// In order to use all of the features, please create an account
  public static let createCardanoAccountInfo = LFLocalizable.tr("Localizable", "create_cardanoAccount_info", fallback: "In order to use all of the features, please create an account")
  /// CauseCard has partnered with ZeroHash, a world leader in Crypto custody and settlement.
  public static let createCardanoWalletInfo = LFLocalizable.tr("Localizable", "create_cardanoWallet_info", fallback: "CauseCard has partnered with ZeroHash, a world leader in Crypto custody and settlement.")
  /// I agree to the Zero Hash and Zero Hash Liquidity Services User Agreement, and I have read and understand the Zero Hash Privacy Policy and Regulatory Disclosures. I understand that the value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.
  public static let createCardanoWalletTermsAndCondition = LFLocalizable.tr("Localizable", "create_cardanoWallet_termsAndCondition", fallback: "I agree to the Zero Hash and Zero Hash Liquidity Services User Agreement, and I have read and understand the Zero Hash Privacy Policy and Regulatory Disclosures. I understand that the value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.")
  /// CREATE YOUR DOGE WALLET
  public static let createCardanoWalletTitle = LFLocalizable.tr("Localizable", "create_cardanoWallet_title", fallback: "CREATE YOUR DOGE WALLET")
  /// Doge
  public static let cryptoCurrency = LFLocalizable.tr("Localizable", "crypto_currency", fallback: "Doge")
  /// Sending to a non - Doge wallet will result in lost funds
  public static let cryptoLostFund = LFLocalizable.tr("Localizable", "crypto_lost_fund", fallback: "Sending to a non - Doge wallet will result in lost funds")
  /// Minimum amount should be $0.10
  public static let cryptoMinimumBalance = LFLocalizable.tr("Localizable", "crypto_minimum_balance", fallback: "Minimum amount should be $0.10")
  /// %@ DOGE SENT
  public static func cryptoSend(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "crypto_send", String(describing: p1), fallback: "%@ DOGE SENT")
  }
  /// ARE YOU SURE YOU WANT TO SEND %@ DOGE?
  public static func cryptoSendConfirmation(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "crypto_send_confirmation", String(describing: p1), fallback: "ARE YOU SURE YOU WANT TO SEND %@ DOGE?")
  }
  /// DOGE TRANSFER
  public static let cryptoTransfer = LFLocalizable.tr("Localizable", "crypto_transfer", fallback: "DOGE TRANSFER")
  /// You can send to or receive from other Doge wallets. To send, you will need to know the wallet address or have a QR code. To receive, you will be able to show your wallet QR code or copy and share wallet address
  public static let cryptoTransferSendReceive = LFLocalizable.tr("Localizable", "crypto_transfer_send_receive", fallback: "You can send to or receive from other Doge wallets. To send, you will need to know the wallet address or have a QR code. To receive, you will be able to show your wallet QR code or copy and share wallet address")
  /// Doge Wallet Address
  public static let cryptoWalletAddress = LFLocalizable.tr("Localizable", "crypto_wallet_address", fallback: "Doge Wallet Address")
  /// Wallet name
  public static let cryptoWalletName = LFLocalizable.tr("Localizable", "crypto_wallet_name", fallback: "Wallet name")
  /// Cryptocurrency services powered by Zero Hash
  public static let cryptocurrencyServicesInfo = LFLocalizable.tr("Localizable", "cryptocurrency_services_info", fallback: "Cryptocurrency services powered by Zero Hash")
  /// DOGE
  public static let currencyType = LFLocalizable.tr("Localizable", "currency_type", fallback: "DOGE")
  /// USD
  public static let currencyTypeCash = LFLocalizable.tr("Localizable", "currency_type_cash", fallback: "USD")
  /// Currently supporting
  public static let currentlySupporting = LFLocalizable.tr("Localizable", "currently_supporting", fallback: "Currently supporting")
  /// Deposit check
  public static let depositCheck = LFLocalizable.tr("Localizable", "deposit_check", fallback: "Deposit check")
  /// Direct Deposit
  public static let directDeposit = LFLocalizable.tr("Localizable", "direct_deposit", fallback: "Direct Deposit")
  /// Add Signature
  public static let directDepositAddSignatureButtonTitle = LFLocalizable.tr("Localizable", "direct_deposit_AddSignature_buttonTitle", fallback: "Add Signature")
  /// Sign the form on the next page to authorize Direct Deposit enrollment.
  public static let directDepositAddSignatureMessage = LFLocalizable.tr("Localizable", "direct_deposit_AddSignature_message", fallback: "Sign the form on the next page to authorize Direct Deposit enrollment.")
  /// ADD YOUR SIGNATURE
  public static let directDepositAddSignatureTitle = LFLocalizable.tr("Localizable", "direct_deposit_AddSignature_title", fallback: "ADD YOUR SIGNATURE")
  /// Enter employer name
  public static let directDepositEmployerNameField = LFLocalizable.tr("Localizable", "direct_deposit_employerName_field", fallback: "Enter employer name")
  /// ENTER THE NAME OF YOUR EMPLOYER
  public static let directDepositEmployerNameHeading = LFLocalizable.tr("Localizable", "direct_deposit_employerName_heading", fallback: "ENTER THE NAME OF YOUR EMPLOYER")
  /// Employer name
  public static let directDepositEmployerNameTitle = LFLocalizable.tr("Localizable", "direct_deposit_employerName_title", fallback: "Employer name")
  /// Full Paycheck
  public static let directDepositOption1 = LFLocalizable.tr("Localizable", "direct_deposit_option1", fallback: "Full Paycheck")
  /// Enter Percentage
  public static let directDepositOption2 = LFLocalizable.tr("Localizable", "direct_deposit_option2", fallback: "Enter Percentage")
  /// Enter Amount
  public static let directDepositOption3 = LFLocalizable.tr("Localizable", "direct_deposit_option3", fallback: "Enter Amount")
  /// HOW MUCH OF PAYCHECK YOU WANT TO DEPOSIT?
  public static let directDepositOptoinsTitle = LFLocalizable.tr("Localizable", "direct_deposit_optoinsTitle", fallback: "HOW MUCH OF PAYCHECK YOU WANT TO DEPOSIT?")
  /// Email Form
  public static let directDepositSuccessButtonEmail = LFLocalizable.tr("Localizable", "direct_deposit_success_buttonEmail", fallback: "Email Form")
  /// View Form
  public static let directDepositSuccessButtonView = LFLocalizable.tr("Localizable", "direct_deposit_success_buttonView", fallback: "View Form")
  /// Share this form with your employer's payroll team to authorize direct deposits to your CauseCard
  public static let directDepositSuccessMessage = LFLocalizable.tr("Localizable", "direct_deposit_successMessage", fallback: "Share this form with your employer's payroll team to authorize direct deposits to your CauseCard")
  /// YOUR DIRECT DEPOSIT FORM IS READY
  public static let directDepositSuccessTitle = LFLocalizable.tr("Localizable", "direct_deposit_successTitle", fallback: "YOUR DIRECT DEPOSIT FORM IS READY")
  /// Receive paychecks up to two days early by completing this form and sharing it with your employer’s payroll department. 
  ///  
  ///  
  /// You can also save the completed form to share with your employer later.
  public static let directDepositFormInfo = LFLocalizable.tr("Localizable", "direct_depositForm_info", fallback: "Receive paychecks up to two days early by completing this form and sharing it with your employer’s payroll department. \n \n \nYou can also save the completed form to share with your employer later.")
  /// DIRECT DEPOSIT FORM
  public static let directDepositFormTitle = LFLocalizable.tr("Localizable", "direct_depositForm_title", fallback: "DIRECT DEPOSIT FORM")
  /// Directions
  public static let directions = LFLocalizable.tr("Localizable", "directions", fallback: "Directions")
  /// Your checking account was deactivated
  public static let disabledCashSubtitle = LFLocalizable.tr("Localizable", "disabled_cash_subtitle", fallback: "Your checking account was deactivated")
  /// WE ARE SORRY
  public static let disabledCashTitle = LFLocalizable.tr("Localizable", "disabled_cash_title", fallback: "WE ARE SORRY")
  /// By selecting to enroll in the crypto rewards program, you understand and agree that eligible rewards transactions will also trigger your authorization to invest in crypto once your action or card transaction is complete.  Transactions may take time in certain cases.
  public static let disclosuresFirst = LFLocalizable.tr("Localizable", "disclosures_first", fallback: "By selecting to enroll in the crypto rewards program, you understand and agree that eligible rewards transactions will also trigger your authorization to invest in crypto once your action or card transaction is complete.  Transactions may take time in certain cases.")
  /// Maximum reward amount may vary, and can depend on your level of participation in crypto rewards. Specific terms and condition may apply.
  public static let disclosuresFourth = LFLocalizable.tr("Localizable", "disclosures_fourth", fallback: "Maximum reward amount may vary, and can depend on your level of participation in crypto rewards. Specific terms and condition may apply.")
  /// Orders may not be canceled or reversed once submitted by you. By submitting a withdrawal request, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal
  public static let disclosuresSecond = LFLocalizable.tr("Localizable", "disclosures_second", fallback: "Orders may not be canceled or reversed once submitted by you. By submitting a withdrawal request, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal")
  /// Zero Hash does not offer the ability to set up pre-authorized, automatic, or recurring Orders (“Pre-Authorized Orders”) in your Account; (b) any such Pre-Authorized Order feature (if available) is under the exclusive control of CauseCard ; (c) you must contact CauseCard in order to stop a Pre-Authorized Order before execution or to turn off such a feature in your Account; and (d) Zero Hash and ZHLS are not liable for the placement and execution of any Pre-Authorized order.
  public static let disclosuresThird = LFLocalizable.tr("Localizable", "disclosures_third", fallback: "Zero Hash does not offer the ability to set up pre-authorized, automatic, or recurring Orders (“Pre-Authorized Orders”) in your Account; (b) any such Pre-Authorized Order feature (if available) is under the exclusive control of CauseCard ; (c) you must contact CauseCard in order to stop a Pre-Authorized Order before execution or to turn off such a feature in your Account; and (d) Zero Hash and ZHLS are not liable for the placement and execution of any Pre-Authorized order.")
  /// Exchange Rate
  public static let disclosuresTitle = LFLocalizable.tr("Localizable", "disclosures_title", fallback: "Exchange Rate")
  /// Date of birth
  public static let dob = LFLocalizable.tr("Localizable", "dob", fallback: "Date of birth")
  /// dd / mm / yyyy
  public static let dobFormat = LFLocalizable.tr("Localizable", "dob_format", fallback: "dd / mm / yyyy")
  /// Email
  public static let email = LFLocalizable.tr("Localizable", "email", fallback: "Email")
  /// Enroll now
  public static let enrollCta = LFLocalizable.tr("Localizable", "enroll_cta", fallback: "Enroll now")
  /// ENROLL FOR DOGECOIN REWARDS
  public static let enrollTitle = LFLocalizable.tr("Localizable", "enroll_title", fallback: "ENROLL FOR DOGECOIN REWARDS")
  /// Ensure good lighting
  public static let ensureLighting = LFLocalizable.tr("Localizable", "ensure_lighting", fallback: "Ensure good lighting")
  /// Enter address
  public static let enterAddress = LFLocalizable.tr("Localizable", "enter_address", fallback: "Enter address")
  /// Enter amount
  public static let enterAmount = LFLocalizable.tr("Localizable", "enter_amount", fallback: "Enter amount")
  /// Enter city
  public static let enterCity = LFLocalizable.tr("Localizable", "enter_city", fallback: "Enter city")
  /// Enter email address
  public static let enterEmailAddress = LFLocalizable.tr("Localizable", "enter_emailAddress", fallback: "Enter email address")
  /// Enter legal first name
  public static let enterFirstName = LFLocalizable.tr("Localizable", "enter_firstName", fallback: "Enter legal first name")
  /// Enter legal last name
  public static let enterLastName = LFLocalizable.tr("Localizable", "enter_lastName", fallback: "Enter legal last name")
  /// Enter payor name
  public static let enterPayorName = LFLocalizable.tr("Localizable", "enter_payor_name", fallback: "Enter payor name")
  /// Enter state
  public static let enterState = LFLocalizable.tr("Localizable", "enter_state", fallback: "Enter state")
  /// ENTER VERIFICATION CODE
  public static let enterVerificationCode = LFLocalizable.tr("Localizable", "enter_verificationCode", fallback: "ENTER VERIFICATION CODE")
  /// Enter Wallet Name
  public static let enterWalletName = LFLocalizable.tr("Localizable", "enter_wallet_name", fallback: "Enter Wallet Name")
  /// Enter zip code
  public static let enterZipcode = LFLocalizable.tr("Localizable", "enter_zipcode", fallback: "Enter zip code")
  /// E-sign consent
  public static let esignConsent = LFLocalizable.tr("Localizable", "Esign_consent", fallback: "E-sign consent")
  /// Varies, the current prevaling price as determined by Zero Hash Liquidity Services LLC at the point of transaction.
  public static let exchangeRateDescription = LFLocalizable.tr("Localizable", "exchange_rate_description", fallback: "Varies, the current prevaling price as determined by Zero Hash Liquidity Services LLC at the point of transaction.")
  /// Exchange Rate
  public static let exchangeRateTitle = LFLocalizable.tr("Localizable", "exchange_rate_title", fallback: "Exchange Rate")
  /// Expires
  public static let expires = LFLocalizable.tr("Localizable", "expires", fallback: "Expires")
  /// Explore Abortion Funds
  public static let exploreFunds = LFLocalizable.tr("Localizable", "explore_funds", fallback: "Explore Abortion Funds")
  /// Face ID
  public static let faceId = LFLocalizable.tr("Localizable", "face_id", fallback: "Face ID")
  /// Featured Funds
  public static let featuredFunds = LFLocalizable.tr("Localizable", "featured_funds", fallback: "Featured Funds")
  /// Fee
  public static let feeTitle = LFLocalizable.tr("Localizable", "fee_title", fallback: "Fee")
  /// $0
  public static let feesDescription = LFLocalizable.tr("Localizable", "fees_description", fallback: "$0")
  /// Fees
  public static let feesTitle = LFLocalizable.tr("Localizable", "fees_title", fallback: "Fees")
  /// Legal first name
  public static let firstName = LFLocalizable.tr("Localizable", "first_name", fallback: "Legal first name")
  /// Front of check
  public static let frontCheck = LFLocalizable.tr("Localizable", "front_check", fallback: "Front of check")
  /// take photo of front of check
  public static let frontTakePhoto = LFLocalizable.tr("Localizable", "front_take_photo", fallback: "take photo of front of check")
  /// Something went wrong, please try again.
  public static let genericErrorMessage = LFLocalizable.tr("Localizable", "generic_ErrorMessage", fallback: "Something went wrong, please try again.")
  /// Help & Support
  public static let helpSupport = LFLocalizable.tr("Localizable", "help_support", fallback: "Help & Support")
  /// https://www.idfpr.com/admin/dfi/dficomplaint.asp
  public static let illinoisCustomer = LFLocalizable.tr("Localizable", "illinois_customer", fallback: "https://www.idfpr.com/admin/dfi/dficomplaint.asp")
  /// In the event of an unresolved complaint, please contactthe Illinois Department of Financial Institutions at 1-888-473-4858 or submit an online complaint at 
  ///  https://www.idfpr.com/admin/dfi/dficomplaint.asp 
  /// 
  /// 
  public static let illinoisDesc = LFLocalizable.tr("Localizable", "illinois_desc", fallback: "In the event of an unresolved complaint, please contactthe Illinois Department of Financial Institutions at 1-888-473-4858 or submit an online complaint at \n https://www.idfpr.com/admin/dfi/dficomplaint.asp \n\n")
  /// Illinois Customers 
  /// 
  public static let illinoisText = LFLocalizable.tr("Localizable", "illinois_text", fallback: "Illinois Customers \n")
  /// Check Status
  public static let inReviewPopUpButtonTitle = LFLocalizable.tr("Localizable", "inReview_popUp_buttonTitle", fallback: "Check Status")
  /// Your account is currently in review and we we’ll get back to you as soon as possible.  In the meantime, you can check status below.
  public static let inReviewPopUpSubText = LFLocalizable.tr("Localizable", "inReview_popUp_sub_text", fallback: "Your account is currently in review and we we’ll get back to you as soon as possible.  In the meantime, you can check status below.")
  /// YOUR ACCOUNT IS IN REVIEW
  public static let inReviewPopUpTitle = LFLocalizable.tr("Localizable", "inReview_popUp_title", fallback: "YOUR ACCOUNT IS IN REVIEW")
  /// Instant transfer
  public static let instantTransfer = LFLocalizable.tr("Localizable", "instant_transfer", fallback: "Instant transfer")
  /// insufficient balance
  public static let insufficientBalance = LFLocalizable.tr("Localizable", "insufficient_balance", fallback: "insufficient balance")
  /// Insufficient funds
  public static let insufficientFunds = LFLocalizable.tr("Localizable", "insufficient_funds", fallback: "Insufficient funds")
  /// Ok
  public static let insuficientBalanceButton = LFLocalizable.tr("Localizable", "insuficient_balance_button", fallback: "Ok")
  /// We’re Sorry
  public static let insuficientBalanceTitle = LFLocalizable.tr("Localizable", "insuficient_balance_title", fallback: "We’re Sorry")
  /// We were unable to add money due to insufficient funds. Please try again or contact us.
  public static let insuficientBalanceError = LFLocalizable.tr("Localizable", "insuficientBalance_error", fallback: "We were unable to add money due to insufficient funds. Please try again or contact us.")
  /// Join waitlist
  public static let joinWaitlist = LFLocalizable.tr("Localizable", "join_waitlist", fallback: "Join waitlist")
  /// Legal last name
  public static let lastName = LFLocalizable.tr("Localizable", "last_name", fallback: "Legal last name")
  /// Learn about deposit limits
  public static let learnAboutLimits = LFLocalizable.tr("Localizable", "learn_about_limits", fallback: "Learn about deposit limits")
  /// Learn more
  public static let learnMore = LFLocalizable.tr("Localizable", "learn_more", fallback: "Learn more")
  /// Legal
  public static let legal = LFLocalizable.tr("Localizable", "legal", fallback: "Legal")
  /// Privacy Policy
  public static let legalPrivacyPolicy = LFLocalizable.tr("Localizable", "legal_privacy_policy", fallback: "Privacy Policy")
  /// Legal & Privacy
  public static let legalTitle = LFLocalizable.tr("Localizable", "legal_title", fallback: "Legal & Privacy")
  /// Zero Hash LLC's or Zero Hash Liquidity Services LLC's aggregate liability, including for non-delivery or delayed delivery, is limited to losses resulting solely from the gross negligence, intentional misconduct or fraud of Zero Hash or Zero Hash Liquidity Services, their affiliates or any of their officers, directors, managers, partners, employees or independent agents or contractors, as determined by a court of competent jurisdiction or arbitration panel in accordance with the terms of the User Agreement 
  /// 
  /// 
  public static let liabilityDesc = LFLocalizable.tr("Localizable", "liability_desc", fallback: "Zero Hash LLC's or Zero Hash Liquidity Services LLC's aggregate liability, including for non-delivery or delayed delivery, is limited to losses resulting solely from the gross negligence, intentional misconduct or fraud of Zero Hash or Zero Hash Liquidity Services, their affiliates or any of their officers, directors, managers, partners, employees or independent agents or contractors, as determined by a court of competent jurisdiction or arbitration panel in accordance with the terms of the User Agreement \n\n")
  /// Liability for Non-Delivery or Delayed Delivery 
  /// 
  public static let liabilityText = LFLocalizable.tr("Localizable", "liability_text", fallback: "Liability for Non-Delivery or Delayed Delivery \n")
  /// Location access
  public static let locationAccess = LFLocalizable.tr("Localizable", "location_access", fallback: "Location access")
  /// Log Out
  public static let logout = LFLocalizable.tr("Localizable", "logout", fallback: "Log Out")
  /// Mail app is not configured
  public static let mailAlert = LFLocalizable.tr("Localizable", "mail_alert", fallback: "Mail app is not configured")
  ///  www.credit.maine.gov
  public static let maineCustomer = LFLocalizable.tr("Localizable", "maine_customer", fallback: " www.credit.maine.gov")
  /// In the event of a dispute, please contact the Bureau ofConsumer Credit Protection at 1-800-332-8529 or at www.credit.maine.gov
  public static let maineCustomersDesc = LFLocalizable.tr("Localizable", "maine_customers_desc", fallback: "In the event of a dispute, please contact the Bureau ofConsumer Credit Protection at 1-800-332-8529 or at www.credit.maine.gov")
  /// Maine Customers 
  /// 
  public static let maineCustomersText = LFLocalizable.tr("Localizable", "maine_customers_text", fallback: "Maine Customers \n")
  /// https://mn.gov/commerce/consumers/your-money/inves tor-education/cryptocurrency.jsp
  public static let minnesotaCustomer = LFLocalizable.tr("Localizable", "minnesota_customer", fallback: "https://mn.gov/commerce/consumers/your-money/inves tor-education/cryptocurrency.jsp")
  /// Minnesota Customers 
  /// 
  public static let minnesotaCustomersText = LFLocalizable.tr("Localizable", "minnesota_customers_text", fallback: "Minnesota Customers \n")
  /// More
  public static let more = LFLocalizable.tr("Localizable", "more", fallback: "More")
  /// Move Money
  public static let moveMoney = LFLocalizable.tr("Localizable", "move_money", fallback: "Move Money")
  /// First name and Last name should not be more than 23 characters
  public static let nameExceedMessage = LFLocalizable.tr("Localizable", "name_exceed_message", fallback: "First name and Last name should not be more than 23 characters")
  /// Network Fee
  public static let networkFee = LFLocalizable.tr("Localizable", "network_fee", fallback: "Network Fee")
  /// Next
  public static let next = LFLocalizable.tr("Localizable", "Next", fallback: "Next")
  /// No
  public static let no = LFLocalizable.tr("Localizable", "no", fallback: "No")
  /// No transactions have been made yet
  public static let noAccounts = LFLocalizable.tr("Localizable", "no_accounts", fallback: "No transactions have been made yet")
  /// NO ATM AVAILABLE
  public static let noAtms = LFLocalizable.tr("Localizable", "no_atms", fallback: "NO ATM AVAILABLE")
  /// No SSN? Click here to enter your Passport Number
  public static let noSSN = LFLocalizable.tr("Localizable", "no_SSN", fallback: "No SSN? Click here to enter your Passport Number")
  /// No transactions
  public static let noTransactions = LFLocalizable.tr("Localizable", "no_transactions", fallback: "No transactions")
  /// Not now
  public static let notNow = LFLocalizable.tr("Localizable", "not_now", fallback: "Not now")
  /// Enable Notifications
  public static let notificationsEnable = LFLocalizable.tr("Localizable", "notifications_enable", fallback: "Enable Notifications")
  /// Yes
  public static let notifyAlertAction = LFLocalizable.tr("Localizable", "notify_alert_action", fallback: "Yes")
  /// Not now
  public static let notifyAlertDismiss = LFLocalizable.tr("Localizable", "notify_alert_dismiss", fallback: "Not now")
  /// Would you like to be notified about the status of your account or if your card has been charged?
  public static let notifyAlertSubtitle = LFLocalizable.tr("Localizable", "notify_alert_subtitle", fallback: "Would you like to be notified about the status of your account or if your card has been charged?")
  /// WOULD YOU LIKE TO BE NOTIFIED?
  public static let notifyAlertTitle = LFLocalizable.tr("Localizable", "notify_alert_title", fallback: "WOULD YOU LIKE TO BE NOTIFIED?")
  /// Notify me
  public static let notifyMe = LFLocalizable.tr("Localizable", "notifyMe", fallback: "Notify me")
  /// When this card is charged
  public static let notifyMeInfo = LFLocalizable.tr("Localizable", "notifyMe_info", fallback: "When this card is charged")
  /// Not now
  public static let notnow = LFLocalizable.tr("Localizable", "notnow", fallback: "Not now")
  /// Ok
  public static let ok = LFLocalizable.tr("Localizable", "ok", fallback: "Ok")
  /// Order Card
  public static let orderCard = LFLocalizable.tr("Localizable", "order_card", fallback: "Order Card")
  /// New code sent
  public static let otpSent = LFLocalizable.tr("Localizable", "otp_sent", fallback: "New code sent")
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
  /// Copied to clipboard
  public static let pasteboardCopy = LFLocalizable.tr("Localizable", "pasteboard_copy", fallback: "Copied to clipboard")
  /// Payor name
  public static let payorName = LFLocalizable.tr("Localizable", "payor_name", fallback: "Payor name")
  /// help@CauseCard.co
  public static let pdfEmail = LFLocalizable.tr("Localizable", "pdf_email", fallback: "help@CauseCard.co")
  /// I,
  public static let pdfstring1 = LFLocalizable.tr("Localizable", "pdfstring1", fallback: "I,")
  /// authorize,
  public static let pdfstring2 = LFLocalizable.tr("Localizable", "pdfstring2", fallback: "authorize,")
  /// to directly deposit my wages
  public static let pdfstring3 = LFLocalizable.tr("Localizable", "pdfstring3", fallback: "to directly deposit my wages")
  /// less lawful withholdings and deductions), or earnings, as applicable, to my CauseCard account, including employer receives written notification from me of its termination of my employment or enagement
  public static let pdfstring4 = LFLocalizable.tr("Localizable", "pdfstring4", fallback: "less lawful withholdings and deductions), or earnings, as applicable, to my CauseCard account, including employer receives written notification from me of its termination of my employment or enagement")
  /// 
  ///  This authorization replaces any previous direct deposit authorization and shall remain in effect until my employer receives written notification from me of its termination. The information for my CauseCard account is provided above
  public static let pdfstring5 = LFLocalizable.tr("Localizable", "pdfstring5", fallback: "\n This authorization replaces any previous direct deposit authorization and shall remain in effect until my employer receives written notification from me of its termination. The information for my CauseCard account is provided above")
  /// I wish to deposit
  public static let pdfstring6 = LFLocalizable.tr("Localizable", "pdfstring6", fallback: "I wish to deposit")
  /// PHONE NUMBER
  public static let phoneNumberTitle = LFLocalizable.tr("Localizable", "phone_number_title", fallback: "PHONE NUMBER")
  /// 855-744-7333
  public static let phonenumber = LFLocalizable.tr("Localizable", "phonenumber", fallback: "855-744-7333")
  /// Phone number
  public static let phoneNumber = LFLocalizable.tr("Localizable", "phoneNumber", fallback: "Phone number")
  /// Place on a solid surface
  public static let placeSolidSurface = LFLocalizable.tr("Localizable", "place_solid_surface", fallback: "Place on a solid surface")
  /// Connect via Debit Card
  public static let plaidConnectViaDebitCardButton = LFLocalizable.tr("Localizable", "plaid_connect_via_debit_card_button", fallback: "Connect via Debit Card")
  /// The login details for your bank have changed, please reconnect to your bank via Plaid or add Debit Card.
  public static let plaidDetailsHaveChangedError = LFLocalizable.tr("Localizable", "plaid_details_have_changed_error", fallback: "The login details for your bank have changed, please reconnect to your bank via Plaid or add Debit Card.")
  /// We’re unable to link your bank account via Plaid.
  public static let plaidErrorDescription = LFLocalizable.tr("Localizable", "plaid_error_description", fallback: "We’re unable to link your bank account via Plaid.")
  /// Link Bank via Debit Card
  public static let plaidLinkBankViaDebidCardButton = LFLocalizable.tr("Localizable", "plaid_link_bank_via_debid_card_button", fallback: "Link Bank via Debit Card")
  /// OK
  public static let plaidOkButton = LFLocalizable.tr("Localizable", "plaid_ok_button", fallback: "OK")
  /// Re-connect bank account
  public static let plaidReconnectButton = LFLocalizable.tr("Localizable", "plaid_reconnect_button", fallback: "Re-connect bank account")
  /// Price
  public static let price = LFLocalizable.tr("Localizable", "price", fallback: "Price")
  /// Privacy Policy
  public static let privacyPolicy = LFLocalizable.tr("Localizable", "privacy_policy", fallback: "Privacy Policy")
  /// Profile
  public static let profile = LFLocalizable.tr("Localizable", "profile", fallback: "Profile")
  /// Receipt
  public static let receipt = LFLocalizable.tr("Localizable", "receipt", fallback: "Receipt")
  /// Receive
  public static let receive = LFLocalizable.tr("Localizable", "receive", fallback: "Receive")
  /// Pull to refresh
  public static let refreshControl = LFLocalizable.tr("Localizable", "refresh_control", fallback: "Pull to refresh")
  /// Regulatory Disclosures
  public static let regulatoryDisclosures = LFLocalizable.tr("Localizable", "regulatory_disclosures", fallback: "Regulatory Disclosures")
  /// Replace card
  public static let replaceCard = LFLocalizable.tr("Localizable", "replaceCard", fallback: "Replace card")
  /// Resend Code
  public static let resendCode = LFLocalizable.tr("Localizable", "resend_code", fallback: "Resend Code")
  /// Rewards
  public static let rewards = LFLocalizable.tr("Localizable", "rewards", fallback: "Rewards")
  /// Rewards Terms
  public static let rewardsTerms = LFLocalizable.tr("Localizable", "rewards_terms", fallback: "Rewards Terms")
  /// The value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.
  public static let riskDisclosure = LFLocalizable.tr("Localizable", "risk_disclosure", fallback: "The value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.")
  /// Round up purchases
  public static let roundUpPurchases = LFLocalizable.tr("Localizable", "round_up_purchases", fallback: "Round up purchases")
  /// Routing Number
  public static let routingNumber = LFLocalizable.tr("Localizable", "routing_number", fallback: "Routing Number")
  /// Select
  public static let select = LFLocalizable.tr("Localizable", "select", fallback: "Select")
  /// DOGE->USD
  public static let sellCardanoDescription = LFLocalizable.tr("Localizable", "sell_Cardano_description", fallback: "DOGE->USD")
  /// Doge Sale
  public static let sellCardanoTitle = LFLocalizable.tr("Localizable", "sell_Cardano_title", fallback: "Doge Sale")
  /// Sell Rewards
  public static let sellRewards = LFLocalizable.tr("Localizable", "sell_rewards", fallback: "Sell Rewards")
  /// Send
  public static let send = LFLocalizable.tr("Localizable", "send", fallback: "Send")
  /// Withdraw
  public static let sendMoney = LFLocalizable.tr("Localizable", "send_money", fallback: "Withdraw")
  /// Send to Wallet
  public static let sendToWallet = LFLocalizable.tr("Localizable", "send_to_wallet", fallback: "Send to Wallet")
  /// Set ATM PIN
  public static let setAtmPin = LFLocalizable.tr("Localizable", "set_atm_pin", fallback: "Set ATM PIN")
  /// Your card is active. Would you like to use your card at ATMs?
  public static let setATMPINPopupInfo = LFLocalizable.tr("Localizable", "setATM_PIN_popupInfo", fallback: "Your card is active. Would you like to use your card at ATMs?")
  /// SET UP ATM PIN
  public static let setATMPINPopupTitle = LFLocalizable.tr("Localizable", "setATM_PIN_popupTitle", fallback: "SET UP ATM PIN")
  /// Your card is active. Would you like to set a card PIN?
  public static let setCardanoPINPopupInfo = LFLocalizable.tr("Localizable", "setCardano_PIN_popupInfo", fallback: "Your card is active. Would you like to set a card PIN?")
  /// SET UP CARD PIN
  public static let setCardanoPINPopupTitle = LFLocalizable.tr("Localizable", "setCardano_PIN_popupTitle", fallback: "SET UP CARD PIN")
  /// Settings
  public static let settings = LFLocalizable.tr("Localizable", "settings", fallback: "Settings")
  /// I agree to Zero Hash and Zero Hash Liquidity Services User Agreement, and I have read and understand the Zero Hash Privacy Policy and Regulatory Disclosures. I understand that the value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.
  public static let setupwalletTerms = LFLocalizable.tr("Localizable", "setupwallet_terms", fallback: "I agree to Zero Hash and Zero Hash Liquidity Services User Agreement, and I have read and understand the Zero Hash Privacy Policy and Regulatory Disclosures. I understand that the value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.")
  /// Share
  public static let share = LFLocalizable.tr("Localizable", "share", fallback: "Share")
  /// Share Fundraiser
  public static let shareFundraiser = LFLocalizable.tr("Localizable", "share_fundraiser", fallback: "Share Fundraiser")
  /// Shortcuts
  public static let shortcuts = LFLocalizable.tr("Localizable", "shortcuts", fallback: "Shortcuts")
  /// Please add your signature
  public static let signatureAlert = LFLocalizable.tr("Localizable", "signature_alert", fallback: "Please add your signature")
  /// Privacy Policy
  public static let solidPrivacyPolicy = LFLocalizable.tr("Localizable", "solid_privacyPolicy", fallback: "Privacy Policy")
  /// Encrypted using 256-BIT SSL
  public static let ssnEncryptInfo = LFLocalizable.tr("Localizable", "SSN_encrypt_info", fallback: "Encrypted using 256-BIT SSL")
  /// SECURITY CHECK: ENTER LAST 4 OF SSN
  public static let ssnHeadingNewLogin = LFLocalizable.tr("Localizable", "SSN_Heading_New_login", fallback: "SECURITY CHECK: ENTER LAST 4 OF SSN")
  /// No credit checks
  public static let ssnNoCreditCheckInfo = LFLocalizable.tr("Localizable", "SSN_noCreditCheck_info", fallback: "No credit checks")
  /// Last 4 digits of Social Security Number
  public static let ssnTitle = LFLocalizable.tr("Localizable", "SSN_Title", fallback: "Last 4 digits of Social Security Number")
  /// Last 4 digits of Social Security Number/Passport
  public static let ssnTitleNewLogin = LFLocalizable.tr("Localizable", "SSN_Title_New_login", fallback: "Last 4 digits of Social Security Number/Passport")
  /// State
  public static let state = LFLocalizable.tr("Localizable", "state", fallback: "State")
  /// Support
  public static let supportTitle = LFLocalizable.tr("Localizable", "support_title", fallback: "Support")
  /// Take photo
  public static let takePhoto = LFLocalizable.tr("Localizable", "take_photo", fallback: "Take photo")
  /// Terms
  public static let terms = LFLocalizable.tr("Localizable", "terms", fallback: "Terms")
  /// Terms of service
  public static let termsOfService = LFLocalizable.tr("Localizable", "terms_of_service", fallback: "Terms of service")
  /// By tapping ‘Continue’, you agree to our Terms, E-sign consent and Privacy Policy.
  public static let termsPrivacyPolicy = LFLocalizable.tr("Localizable", "terms_privacyPolicy", fallback: "By tapping ‘Continue’, you agree to our Terms, E-sign consent and Privacy Policy.")
  /// Using VOIP or Google Voice numbers can result in onboarding delays. We NEVER share your phone number with third parties for marketing, per our Privacy Policy.
  public static let termsVoip = LFLocalizable.tr("Localizable", "terms_voip", fallback: "Using VOIP or Google Voice numbers can result in onboarding delays. We NEVER share your phone number with third parties for marketing, per our Privacy Policy.")
  /// Terms and Conditions
  public static let termsandcondition = LFLocalizable.tr("Localizable", "termsandcondition", fallback: "Terms and Conditions")
  /// Solid Terms of service.
  public static let termsofservice = LFLocalizable.tr("Localizable", "termsofservice", fallback: "Solid Terms of service.")
  /// By tapping ‘Continue’, you agree to Solid Terms of service. Each time you initiate a transaction using your card, your Dogecoin is converted to fiat at the time of the transaction and you are responsible for any taxes under terms of the agreement.
  public static let termsofserviceText = LFLocalizable.tr("Localizable", "termsofservice_text", fallback: "By tapping ‘Continue’, you agree to Solid Terms of service. Each time you initiate a transaction using your card, your Dogecoin is converted to fiat at the time of the transaction and you are responsible for any taxes under terms of the agreement.")
  /// www.dob.texas.gov.
  public static let texasCustomer = LFLocalizable.tr("Localizable", "texas_customer", fallback: "www.dob.texas.gov.")
  /// Texas Customers 
  /// 
  public static let texasCustomersText = LFLocalizable.tr("Localizable", "texas_customers_text", fallback: "Texas Customers \n")
  /// Total donations
  public static let totalDonations = LFLocalizable.tr("Localizable", "total_donations", fallback: "Total donations")
  /// Total rewards
  public static let totalRewards = LFLocalizable.tr("Localizable", "total_rewards", fallback: "Total rewards")
  /// Touch ID
  public static let touchId = LFLocalizable.tr("Localizable", "touch_id", fallback: "Touch ID")
  /// %@ estimated network fee
  public static func tranferFee(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "tranfer_fee", String(describing: p1), fallback: "%@ estimated network fee")
  }
  /// doge@zerohash.com | 855-744-7333 
  /// 
  /// 
  /// 
  ///  Zero Hash LLC 327 N Aberdeen St Chicago, IL 60607 
  /// 
  ///  www.zerohash.com
  public static let transactionreceiptLine1 = LFLocalizable.tr("Localizable", "transactionreceipt_line1", fallback: "doge@zerohash.com | 855-744-7333 \n\n\n\n Zero Hash LLC 327 N Aberdeen St Chicago, IL 60607 \n\n www.zerohash.com")
  /// The value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.
  /// 
  ///  Cancellation Policy 
  /// 
  ///  All transactions are final. You are responsible for reviewing this receipt for accuracy land for notifying Zero Hash LLC of any suspected errors via email at support@zerohash.com within 24 hours of the trade. 
  /// 
  /// 
  /// 
  ///  Liability for Non-Delivery or Delayed Delivery 
  /// 
  ///  Zero Hash LLC's or Zero Hash Liquidity Services LLC's aggregate liability, including for non-delivery or delayed delivery, is limited to losses resulting solely from the gross negligence, intentional misconduct or fraud of Zero Hash or Zero Hash Liquidity Services, their affiliates or any of their officers, directors, managers, partners, employees or independent agents or contractors, as determined by a court of competent jurisdiction or arbitration panel in accordance with the terms of the User Agreement 
  /// 
  /// 
  /// 
  ///  Beware of Fraud 
  /// 
  ///  Cryptocurrencies and money transfer services arecommonly targeted by hackers and criminals who commitfraud. For more information on how to protect againstfraud, visit the Consumer Financial Protection Bureau'swebsite at https://www.consumerfinance.gov/consumer-tools/fraud 
  /// 
  /// 
  /// 
  ///  Illinois Customers 
  /// 
  ///  In the event of an unresolved complaint, please contactthe Illinois Department of Financial Institutions at 1-888-473-4858 or submit an online complaint at https://www.idfpr.com/admin/dfi/dficomplaint.asp 
  /// 
  /// 
  /// 
  ///  Maine Customers 
  /// 
  ///  In the event of a dispute, please contact the Bureau of Consumer Credit Protection at 1-800-332-8529 or at www.credit.maine.gov 
  /// 
  /// 
  /// 
  ///  Minnesota Customers 
  /// 
  ///  If you believe you are a victim of fraud, please contact us at 1-800-674-2975. For more information about how to protect against fraud, visit https://mn.gov/commerce/consumers/your-money/inves tor-education/cryptocurrency.jsp. 
  /// 
  /// 
  /// 
  ///  Texas Customers 
  /// 
  ///  If you have a complaint, first contact the consumer assistance division of Zero Hash LLC at 1 (855) 744-7333, if you still have an unresolved complaint regarding the company's money transmission activity, please direct your complaint to: Texas Department of Banking, 2601 North Lamar Boulevard, Austin, Texas 78705, 1-877-276-5554 (toll free), www.dob.texas.gov.
  public static let transactionreceiptLine2 = LFLocalizable.tr("Localizable", "transactionreceipt_line2", fallback: "The value of any cryptocurrency, including digital assets pegged to fiat currency, commodities, or any other asset, may go to zero.\n\n Cancellation Policy \n\n All transactions are final. You are responsible for reviewing this receipt for accuracy land for notifying Zero Hash LLC of any suspected errors via email at support@zerohash.com within 24 hours of the trade. \n\n\n\n Liability for Non-Delivery or Delayed Delivery \n\n Zero Hash LLC's or Zero Hash Liquidity Services LLC's aggregate liability, including for non-delivery or delayed delivery, is limited to losses resulting solely from the gross negligence, intentional misconduct or fraud of Zero Hash or Zero Hash Liquidity Services, their affiliates or any of their officers, directors, managers, partners, employees or independent agents or contractors, as determined by a court of competent jurisdiction or arbitration panel in accordance with the terms of the User Agreement \n\n\n\n Beware of Fraud \n\n Cryptocurrencies and money transfer services arecommonly targeted by hackers and criminals who commitfraud. For more information on how to protect againstfraud, visit the Consumer Financial Protection Bureau'swebsite at https://www.consumerfinance.gov/consumer-tools/fraud \n\n\n\n Illinois Customers \n\n In the event of an unresolved complaint, please contactthe Illinois Department of Financial Institutions at 1-888-473-4858 or submit an online complaint at https://www.idfpr.com/admin/dfi/dficomplaint.asp \n\n\n\n Maine Customers \n\n In the event of a dispute, please contact the Bureau of Consumer Credit Protection at 1-800-332-8529 or at www.credit.maine.gov \n\n\n\n Minnesota Customers \n\n If you believe you are a victim of fraud, please contact us at 1-800-674-2975. For more information about how to protect against fraud, visit https://mn.gov/commerce/consumers/your-money/inves tor-education/cryptocurrency.jsp. \n\n\n\n Texas Customers \n\n If you have a complaint, first contact the consumer assistance division of Zero Hash LLC at 1 (855) 744-7333, if you still have an unresolved complaint regarding the company's money transmission activity, please direct your complaint to: Texas Department of Banking, 2601 North Lamar Boulevard, Austin, Texas 78705, 1-877-276-5554 (toll free), www.dob.texas.gov.")
  /// YOU DON'T HAVE ANY DOGE TO TRANSFER AT THIS TIME.
  public static let transferCryptoBalance = LFLocalizable.tr("Localizable", "transfer_crypto_balance", fallback: "YOU DON'T HAVE ANY DOGE TO TRANSFER AT THIS TIME.")
  /// The estimated network fee is an approximation and the actual network fee applied on a withdrawal may differ
  public static let transferDisclaimer = LFLocalizable.tr("Localizable", "transfer_disclaimer", fallback: "The estimated network fee is an approximation and the actual network fee applied on a withdrawal may differ")
  /// TRANSFER DOGE
  public static let transferDoge = LFLocalizable.tr("Localizable", "transfer_doge", fallback: "TRANSFER DOGE")
  /// Transfer Rewards
  public static let transferRewards = LFLocalizable.tr("Localizable", "transfer_rewards", fallback: "Transfer Rewards")
  /// Deposit completed
  public static let transfercompletedtext = LFLocalizable.tr("Localizable", "transfercompletedtext", fallback: "Deposit completed")
  /// Deposit STARTED
  public static let transferstarted = LFLocalizable.tr("Localizable", "transferstarted", fallback: "Deposit STARTED")
  /// Deposit started
  public static let transferstartedtext = LFLocalizable.tr("Localizable", "transferstartedtext", fallback: "Deposit started")
  /// Upload
  public static let upload = LFLocalizable.tr("Localizable", "upload", fallback: "Upload")
  /// User Agreement
  public static let userAgreement = LFLocalizable.tr("Localizable", "userAgreement", fallback: "User Agreement")
  /// View
  public static let view = LFLocalizable.tr("Localizable", "view", fallback: "View")
  /// You are now on the waitlist. We will email you when we can operate in your state.
  public static let waitlistJoinedMessage = LFLocalizable.tr("Localizable", "waitlist_joined_message", fallback: "You are now on the waitlist. We will email you when we can operate in your state.")
  /// WAITLIST JOINED
  public static let waitlistJoinedTitle = LFLocalizable.tr("Localizable", "waitlist_joined_title", fallback: "WAITLIST JOINED")
  /// Hello, %@.  We are very sorry, but due to regulations regarding Doge, we are currently unable to open accounts for residents of New York and Hawaii.   We are currently working with regulators to resolve this.  In the meantime, we will contact you as soon as we can open your account.
  public static func waitlistMessage(_ p1: Any) -> String {
    return LFLocalizable.tr("Localizable", "waitlist_message", String(describing: p1), fallback: "Hello, %@.  We are very sorry, but due to regulations regarding Doge, we are currently unable to open accounts for residents of New York and Hawaii.   We are currently working with regulators to resolve this.  In the meantime, we will contact you as soon as we can open your account.")
  }
  /// Wallet
  public static let wallet = LFLocalizable.tr("Localizable", "wallet", fallback: "Wallet")
  /// It will add this card to Apple Wallet
  public static let walletAddcardMessage = LFLocalizable.tr("Localizable", "wallet_addcard_message", fallback: "It will add this card to Apple Wallet")
  /// This card is already added in Wallet
  public static let walletAlreadyaddedMessage = LFLocalizable.tr("Localizable", "wallet_alreadyadded_message", fallback: "This card is already added in Wallet")
  /// Zero Hash and Zero Hash Liquidity Services User Agreement
  public static let walletUseragreement = LFLocalizable.tr("Localizable", "wallet_useragreement", fallback: "Zero Hash and Zero Hash Liquidity Services User Agreement")
  /// Yes
  public static let yes = LFLocalizable.tr("Localizable", "yes", fallback: "Yes")
  /// Cryptocurrency services powered by Zero Hash
  public static let zeroHashTransactiondetail = LFLocalizable.tr("Localizable", "Zero_hash_transactiondetail", fallback: "Cryptocurrency services powered by Zero Hash")
  /// www.zerohash.com
  public static let zerohashLink = LFLocalizable.tr("Localizable", "zerohash_link", fallback: "www.zerohash.com")
  /// Zip code
  public static let zipcode = LFLocalizable.tr("Localizable", "zipcode", fallback: "Zip code")
  public enum AccountActivated {
    /// Your CauseCard account is activated! Next, add CauseCard to your Apple Pay wallet for fast and easy payments.
    public static let message = LFLocalizable.tr("Localizable", "account_activated.message", fallback: "Your CauseCard account is activated! Next, add CauseCard to your Apple Pay wallet for fast and easy payments.")
    /// Skip
    public static let skip = LFLocalizable.tr("Localizable", "account_activated.skip", fallback: "Skip")
    /// ADD TO APPLE PAY
    public static let title = LFLocalizable.tr("Localizable", "account_activated.title", fallback: "ADD TO APPLE PAY")
  }
  public enum Accounts {
    /// CauseCard Account
    public static let cardAccountDetails = LFLocalizable.tr("Localizable", "accounts.card_account_details", fallback: "CauseCard Account")
    /// Connect New Accounts
    public static let connectNewAccounts = LFLocalizable.tr("Localizable", "accounts.connect_new_accounts", fallback: "Connect New Accounts")
    /// Connected Accounts
    public static let connectedAccounts = LFLocalizable.tr("Localizable", "accounts.connected_accounts", fallback: "Connected Accounts")
    /// Deposit Limits
    public static let depositLimits = LFLocalizable.tr("Localizable", "accounts.deposit_limits", fallback: "Deposit Limits")
    /// Limits
    public static let limits = LFLocalizable.tr("Localizable", "accounts.limits", fallback: "Limits")
    /// Accounts
    public static let navigationTitle = LFLocalizable.tr("Localizable", "accounts.navigation_title", fallback: "Accounts")
  }
  public enum AddBank {
    public enum AddDebitCard {
      /// We're sorry, but we're not able to link your Debit Card.
      public static let errorMessage = LFLocalizable.tr("Localizable", "add_bank.add_debit_card.error_message", fallback: "We're sorry, but we're not able to link your Debit Card.")
      /// ADD A DEBIT CARD
      public static let title = LFLocalizable.tr("Localizable", "add_bank.add_debit_card.title", fallback: "ADD A DEBIT CARD")
    }
    public enum CardDoesNotExist {
      /// This card does not exist. Please check that the entered card details are correct.
      public static let errorMessage = LFLocalizable.tr("Localizable", "add_bank.card_does_not_exist.error_message", fallback: "This card does not exist. Please check that the entered card details are correct.")
      /// CARD DOESN’T EXIST
      public static let title = LFLocalizable.tr("Localizable", "add_bank.card_does_not_exist.title", fallback: "CARD DOESN’T EXIST")
    }
  }
  public enum AddFunds {
    public enum BankTransfers {
      /// Send from your bank to %@
      public static func subtitle(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "add_funds.bank_transfers.subtitle", String(describing: p1), fallback: "Send from your bank to %@")
      }
      /// Bank Transfers
      public static let title = LFLocalizable.tr("Localizable", "add_funds.bank_transfers.title", fallback: "Bank Transfers")
    }
    public enum DebitDeposits {
      /// Add money from your Debit Card
      public static let subtitle = LFLocalizable.tr("Localizable", "add_funds.debit_deposits.subtitle", fallback: "Add money from your Debit Card")
      /// Debit Deposits
      public static let title = LFLocalizable.tr("Localizable", "add_funds.debit_deposits.title", fallback: "Debit Deposits")
    }
    public enum DirectDeposit {
      /// Get paid up to 2 days faster
      public static let subtitle = LFLocalizable.tr("Localizable", "add_funds.direct_deposit.subtitle", fallback: "Get paid up to 2 days faster")
      /// Direct Deposit
      public static let title = LFLocalizable.tr("Localizable", "add_funds.direct_deposit.title", fallback: "Direct Deposit")
    }
    public enum OneTimeTransfers {
      /// Good for small amounts
      public static let subtitle = LFLocalizable.tr("Localizable", "add_funds.one_time_transfers.subtitle", fallback: "Good for small amounts")
      /// One-time Bank Transfers
      public static let title = LFLocalizable.tr("Localizable", "add_funds.one_time_transfers.title", fallback: "One-time Bank Transfers")
    }
    public enum Short {
      public enum DebitDeposits {
        /// Connect your bank with a Debit Card
        public static let subtitle = LFLocalizable.tr("Localizable", "add_funds.short.debit_deposits.subtitle", fallback: "Connect your bank with a Debit Card")
        /// Debit Card
        public static let title = LFLocalizable.tr("Localizable", "add_funds.short.debit_deposits.title", fallback: "Debit Card")
      }
      public enum OneTimeTransfers {
        /// Connect your bank with Plaid
        public static let subtitle = LFLocalizable.tr("Localizable", "add_funds.short.one_time_transfers.subtitle", fallback: "Connect your bank with Plaid")
        /// Bank to Bank
        public static let title = LFLocalizable.tr("Localizable", "add_funds.short.one_time_transfers.title", fallback: "Bank to Bank")
      }
    }
  }
  public enum AddToAppleWallet {
    /// Add To Apple Wallet
    public static let title = LFLocalizable.tr("Localizable", "add_to_apple_wallet.title", fallback: "Add To Apple Wallet")
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
  public enum AvailableBalance {
    /// %@ available
    public static func subtitle(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "available_balance.subtitle", String(describing: p1), fallback: "%@ available")
    }
  }
  public enum BalanceAlert {
    /// Deposit
    public static let cta = LFLocalizable.tr("Localizable", "balance_alert.cta", fallback: "Deposit")
    public enum Low {
      /// Your balance is below %@
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "balance_alert.low.message", String(describing: p1), fallback: "Your balance is below %@")
      }
      /// Low Balance Alert
      public static let title = LFLocalizable.tr("Localizable", "balance_alert.low.title", fallback: "Low Balance Alert")
    }
    public enum Negative {
      /// Negative Balance
      public static let title = LFLocalizable.tr("Localizable", "balance_alert.negative.title", fallback: "Negative Balance")
      public enum Message {
        /// Please deposit cash
        public static let cash = LFLocalizable.tr("Localizable", "balance_alert.negative.message.cash", fallback: "Please deposit cash")
        /// Please deposit Doge
        public static let crypto = LFLocalizable.tr("Localizable", "balance_alert.negative.message.crypto", fallback: "Please deposit Doge")
      }
    }
  }
  public enum BankTransfers {
    /// Login to your bank, and find the transfers section of your bank’s app or website
    public static let bulletOne = LFLocalizable.tr("Localizable", "bank_transfers.bullet_one", fallback: "Login to your bank, and find the transfers section of your bank’s app or website")
    /// Select CauseCard as the recipient and transfer up to $25k at a time.
    public static let bulletThree = LFLocalizable.tr("Localizable", "bank_transfers.bullet_three", fallback: "Select CauseCard as the recipient and transfer up to $25k at a time.")
    /// If it’s your first transfer, you’ll need to add your CauseCard as an external account. Enter you routing and account number, and select Checking as account type.
    public static let bulletTwo = LFLocalizable.tr("Localizable", "bank_transfers.bullet_two", fallback: "If it’s your first transfer, you’ll need to add your CauseCard as an external account. Enter you routing and account number, and select Checking as account type.")
    /// Some banks require a one-time test deposit to verify your account. If so, check your CauseCard transactions after 1-2 days, and enter the test deposit amounts in the bank’s app or website.
    public static let disclosure = LFLocalizable.tr("Localizable", "bank_transfers.disclosure", fallback: "Some banks require a one-time test deposit to verify your account. If so, check your CauseCard transactions after 1-2 days, and enter the test deposit amounts in the bank’s app or website.")
    /// Done
    public static let done = LFLocalizable.tr("Localizable", "bank_transfers.done", fallback: "Done")
    /// How to transfer money from your bank to %@:
    public static func howTo(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "bank_transfers.how_to", String(describing: p1), fallback: "How to transfer money from your bank to %@:")
    }
    /// BANK TRANSFERS
    public static let title = LFLocalizable.tr("Localizable", "bank_transfers.title", fallback: "BANK TRANSFERS")
  }
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
  public enum BuySellAmount {
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "buy_sell_amount.continue", fallback: "Continue")
    /// Minimum amount should be $0.10
    public static let minimumCash = LFLocalizable.tr("Localizable", "buy_sell_amount.minimum_cash", fallback: "Minimum amount should be $0.10")
    public enum BuyCrypto {
      /// HOW MUCH DOGE DO YOU WANT TO BUY
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_amount.buy_crypto.title", fallback: "HOW MUCH DOGE DO YOU WANT TO BUY")
    }
    public enum BuyDonation {
      /// HOW MUCH WOULD YOU LIKE TO DONATE
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_amount.buy_donation.title", fallback: "HOW MUCH WOULD YOU LIKE TO DONATE")
    }
    public enum SellCrypto {
      /// HOW MUCH OF YOUR DOGE DO YOU WANT TO SELL
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_amount.sell_crypto.title", fallback: "HOW MUCH OF YOUR DOGE DO YOU WANT TO SELL")
    }
  }
  public enum BuySellCash {
    /// + Add Money
    public static let addMoney = LFLocalizable.tr("Localizable", "buy_sell_cash.add_money", fallback: "+ Add Money")
    /// Cash Balance
    public static let balance = LFLocalizable.tr("Localizable", "buy_sell_cash.balance", fallback: "Cash Balance")
  }
  public enum BuySellDetail {
    /// Confirm
    public static let confirm = LFLocalizable.tr("Localizable", "buy_sell_detail.confirm", fallback: "Confirm")
    public enum Amount {
      /// Amount
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_detail.amount.title", fallback: "Amount")
      /// $%.2f
      public static func valueCash(_ p1: Float) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_detail.amount.value_cash", p1, fallback: "$%.2f")
      }
      /// %.2f %@
      public static func valueCrypto(_ p1: Float, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_detail.amount.value_crypto", p1, String(describing: p2), fallback: "%.2f %@")
      }
    }
    public enum BuyCrypto {
      /// USD->DOGE
      public static let apiDescription = LFLocalizable.tr("Localizable", "buy_sell_detail.buy_crypto.api_description", fallback: "USD->DOGE")
      /// Doge Purchase
      public static let apiTitle = LFLocalizable.tr("Localizable", "buy_sell_detail.buy_crypto.api_title", fallback: "Doge Purchase")
      /// CONFIRM YOUR DOGE PURCHASE OF %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_detail.buy_crypto.title", String(describing: p1), fallback: "CONFIRM YOUR DOGE PURCHASE OF %@")
      }
    }
    public enum BuyDonation {
      /// One-time Donation
      public static let apiDescription = LFLocalizable.tr("Localizable", "buy_sell_detail.buy_donation.api_description", fallback: "One-time Donation")
      /// Donation
      public static let apiTitle = LFLocalizable.tr("Localizable", "buy_sell_detail.buy_donation.api_title", fallback: "Donation")
      /// CONFIRM YOUR DONATION OF %@
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_detail.buy_donation.title", String(describing: p1), fallback: "CONFIRM YOUR DONATION OF %@")
      }
    }
    public enum Disclosure {
      /// Orders may not be canceled or reversed once submitted by you. By submitting a withdrawal request, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal
      public static let crypto = LFLocalizable.tr("Localizable", "buy_sell_detail.disclosure.crypto", fallback: "Orders may not be canceled or reversed once submitted by you. By submitting a withdrawal request, you are requesting an on-chain transaction that is not reversible or recallable. You are responsible for reviewing the recipient address and ensuring it is the correct address for the selected asset for withdrawal")
      /// 100%% of funds are tax deductible and granted to designated nonprofit: %@. EIN: %@.
      /// 
      /// Donations made to ShoppingGives Foundation
      /// EIN: 83-1352270
      public static func donation(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_detail.disclosure.donation", String(describing: p1), String(describing: p2), fallback: "100%% of funds are tax deductible and granted to designated nonprofit: %@. EIN: %@.\n\nDonations made to ShoppingGives Foundation\nEIN: 83-1352270")
      }
    }
    public enum Fee {
      /// Fees
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_detail.fee.title", fallback: "Fees")
    }
    public enum InsuficientBalanceError {
      /// We were unable to buy crypto due to insufficient funds. Please try again or contact us.
      public static let message = LFLocalizable.tr("Localizable", "buy_sell_detail.insuficientBalance_error.message", fallback: "We were unable to buy crypto due to insufficient funds. Please try again or contact us.")
    }
    public enum Price {
      /// Price
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_detail.price.title", fallback: "Price")
      /// $%.3f
      public static func value(_ p1: Float) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_detail.price.value", p1, fallback: "$%.3f")
      }
    }
    public enum SellCrypto {
      /// DOGE->USD
      public static let apiDescription = LFLocalizable.tr("Localizable", "buy_sell_detail.sell_crypto.api_description", fallback: "DOGE->USD")
      /// Doge Sale
      public static let apiTitle = LFLocalizable.tr("Localizable", "buy_sell_detail.sell_crypto.api_title", fallback: "Doge Sale")
      /// SELL %@ OF DOGE
      public static func title(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_detail.sell_crypto.title", String(describing: p1), fallback: "SELL %@ OF DOGE")
      }
    }
    public enum Symbol {
      /// Symbol
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_detail.symbol.title", fallback: "Symbol")
    }
    public enum Total {
      /// Total
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_detail.total.title", fallback: "Total")
      /// $%.2f
      public static func value(_ p1: Float) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_detail.total.value", p1, fallback: "$%.2f")
      }
    }
  }
  public enum BuySellInput {
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "buy_sell_input.continue", fallback: "Continue")
    public enum BuyAnnotation {
      /// You currently have %@ available to buy Dogecoin. If this amount is less than expected, please contact support.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_input.buy_annotation.description", String(describing: p1), fallback: "You currently have %@ available to buy Dogecoin. If this amount is less than expected, please contact support.")
      }
    }
    public enum BuyCrypto {
      /// BUY DOGE
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_input.buy_crypto.title", fallback: "BUY DOGE")
    }
    public enum BuyDonation {
      /// Donation
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_input.buy_donation.title", fallback: "Donation")
    }
    public enum BuyDonationAnnotation {
      /// You currently have %@ available to make a donation. If this amount is less than expected, please contact support.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_input.buy_donation_annotation.description", String(describing: p1), fallback: "You currently have %@ available to make a donation. If this amount is less than expected, please contact support.")
      }
    }
    public enum SellAnnotation {
      /// You currently have %@ Dogecoin available to sell. Doge Rewards are not available to sell until 48 hours after they are earned.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_input.sell_annotation.description", String(describing: p1), fallback: "You currently have %@ Dogecoin available to sell. Doge Rewards are not available to sell until 48 hours after they are earned.")
      }
    }
    public enum SellCrypto {
      /// %@ available to sell
      public static func subtitle(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "buy_sell_input.sell_crypto.subtitle", String(describing: p1), fallback: "%@ available to sell")
      }
      /// SELL DOGE
      public static let title = LFLocalizable.tr("Localizable", "buy_sell_input.sell_crypto.title", fallback: "SELL DOGE")
    }
  }
  public enum CancelTransfer {
    /// Ok
    public static let ok = LFLocalizable.tr("Localizable", "cancel_transfer.ok", fallback: "Ok")
    /// Cancel Deposit
    public static let title = LFLocalizable.tr("Localizable", "cancel_transfer.title", fallback: "Cancel Deposit")
    public enum Fail {
      /// We were unable to cancel your deposit. Please try again or contact support.
      public static let message = LFLocalizable.tr("Localizable", "cancel_transfer.fail.message", fallback: "We were unable to cancel your deposit. Please try again or contact support.")
      /// Something went wrong
      public static let title = LFLocalizable.tr("Localizable", "cancel_transfer.fail.title", fallback: "Something went wrong")
    }
    public enum Success {
      /// Your deposit has been successfully cancelled.
      public static let message = LFLocalizable.tr("Localizable", "cancel_transfer.success.message", fallback: "Your deposit has been successfully cancelled.")
      /// Success!
      public static let title = LFLocalizable.tr("Localizable", "cancel_transfer.success.title", fallback: "Success!")
    }
  }
  public enum Card {
    /// Share
    public static let share = LFLocalizable.tr("Localizable", "card.share", fallback: "Share")
    public enum Message {
      /// I earned %@ by making a %@ purchase with CauseCard.
      public static func crypto(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "card.message.crypto", String(describing: p1), String(describing: p2), fallback: "I earned %@ by making a %@ purchase with CauseCard.")
      }
      /// Supporting %@ - %@.
      public static func donation(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "card.message.donation", String(describing: p1), String(describing: p2), fallback: "Supporting %@ - %@.")
      }
      public enum ShareDonation {
        /// I donated %@ to %@ using CauseCard. Join us in supporting %@.
        public static func amount(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
          return LFLocalizable.tr("Localizable", "card.message.share_donation.amount", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "I donated %@ to %@ using CauseCard. Join us in supporting %@.")
        }
        /// We're raising money for %@ using CauseCard. Join us in supporting %@.
        public static func generic(_ p1: Any, _ p2: Any) -> String {
          return LFLocalizable.tr("Localizable", "card.message.share_donation.generic", String(describing: p1), String(describing: p2), fallback: "We're raising money for %@ using CauseCard. Join us in supporting %@.")
        }
      }
    }
    public enum Share {
      /// I earned %@ back by using my Visa CauseCard. Get one here: %@
      public static func cashback(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "card.share.cashback", String(describing: p1), String(describing: p2), fallback: "I earned %@ back by using my Visa CauseCard. Get one here: %@")
      }
      /// I earned %@ by using my Visa CauseCard. Get one here: %@
      public static func crypto(_ p1: Any, _ p2: Any) -> String {
        return LFLocalizable.tr("Localizable", "card.share.crypto", String(describing: p1), String(describing: p2), fallback: "I earned %@ by using my Visa CauseCard. Get one here: %@")
      }
    }
    public enum Title {
      /// Cashback
      public static let cashback = LFLocalizable.tr("Localizable", "card.title.cashback", fallback: "Cashback")
      /// Doge Earned
      public static let crypto = LFLocalizable.tr("Localizable", "card.title.crypto", fallback: "Doge Earned")
      /// Donation
      public static let donation = LFLocalizable.tr("Localizable", "card.title.donation", fallback: "Donation")
    }
  }
  public enum CardName {
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "card_name.continue", fallback: "Continue")
    /// If you would like, we can print your chosen name or nickname on your CauseCard instead of your legal name.
    public static let message = LFLocalizable.tr("Localizable", "card_name.message", fallback: "If you would like, we can print your chosen name or nickname on your CauseCard instead of your legal name.")
    /// Chosen  should not be more than 23 characters
    public static let nameLength = LFLocalizable.tr("Localizable", "card_name.name_length", fallback: "Chosen  should not be more than 23 characters")
    /// (OPTIONAL)
    public static let `optional` = LFLocalizable.tr("Localizable", "card_name.optional", fallback: "(OPTIONAL)")
    /// Enter nickname or chosen name
    public static let placeholder = LFLocalizable.tr("Localizable", "card_name.placeholder", fallback: "Enter nickname or chosen name")
    /// CUSTOMIZE CARD %@
    public static func title(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "card_name.title", String(describing: p1), fallback: "CUSTOMIZE CARD %@")
    }
    /// Use my Legal Name
    public static let userLegalName = LFLocalizable.tr("Localizable", "card_name.user_legal_name", fallback: "Use my Legal Name")
  }
  public enum CardsDetail {
    /// Change PIN
    public static let changePin = LFLocalizable.tr("Localizable", "cards_detail.change_pin", fallback: "Change PIN")
    /// Donations
    public static let donations = LFLocalizable.tr("Localizable", "cards_detail.donations", fallback: "Donations")
    /// Round up purchases
    public static let roundUp = LFLocalizable.tr("Localizable", "cards_detail.round_up", fallback: "Round up purchases")
    /// Security
    public static let security = LFLocalizable.tr("Localizable", "cards_detail.security", fallback: "Security")
    /// Show card number
    public static let showCardNumber = LFLocalizable.tr("Localizable", "cards_detail.show_card_number", fallback: "Show card number")
    public enum ActivateCard {
      /// To start using your card, please activate it now
      public static let message = LFLocalizable.tr("Localizable", "cards_detail.activate_card.message", fallback: "To start using your card, please activate it now")
      /// Activate Card
      public static let primary = LFLocalizable.tr("Localizable", "cards_detail.activate_card.primary", fallback: "Activate Card")
      /// Not now
      public static let secondary = LFLocalizable.tr("Localizable", "cards_detail.activate_card.secondary", fallback: "Not now")
      /// Activate Card
      public static let title = LFLocalizable.tr("Localizable", "cards_detail.activate_card.title", fallback: "Activate Card")
    }
    public enum Deals {
      /// Deals
      public static let title = LFLocalizable.tr("Localizable", "cards_detail.deals.title", fallback: "Deals")
      /// Donate up to 8% of purchase
      public static func value(_ p1: Int) -> String {
        return LFLocalizable.tr("Localizable", "cards_detail.deals.value", p1, fallback: "Donate up to 8% of purchase")
      }
    }
    public enum LockCard {
      /// Stop card from being used
      public static let subtitle = LFLocalizable.tr("Localizable", "cards_detail.lock_card.subtitle", fallback: "Stop card from being used")
      /// Lock card
      public static let title = LFLocalizable.tr("Localizable", "cards_detail.lock_card.title", fallback: "Lock card")
    }
    public enum RoundUp {
      /// ROUND UP
      public static let title = LFLocalizable.tr("Localizable", "cards_detail.round_up.title", fallback: "ROUND UP")
    }
  }
  public enum Cashback {
    /// Latest rewards
    public static let latest = LFLocalizable.tr("Localizable", "cashback.latest", fallback: "Latest rewards")
    /// See all
    public static let seeAll = LFLocalizable.tr("Localizable", "cashback.see_all", fallback: "See all")
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
  public enum ConfirmationCryptoSend {
    /// Amount
    public static let amount = LFLocalizable.tr("Localizable", "confirmation_crypto_send.amount", fallback: "Amount")
    /// Confirm Transfer
    public static let title = LFLocalizable.tr("Localizable", "confirmation_crypto_send.title", fallback: "Confirm Transfer")
    /// To
    public static let to = LFLocalizable.tr("Localizable", "confirmation_crypto_send.to", fallback: "To")
    /// Wallet address
    public static let walletAddress = LFLocalizable.tr("Localizable", "confirmation_crypto_send.wallet_address", fallback: "Wallet address")
    public enum Confirm {
      /// Confirm
      public static let button = LFLocalizable.tr("Localizable", "confirmation_crypto_send.confirm.button", fallback: "Confirm")
    }
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
  public enum CryptoSend {
    /// SEND DOGE
    public static let title = LFLocalizable.tr("Localizable", "crypto_send.title", fallback: "SEND DOGE")
  }
  public enum CryptoSendAnnotation {
    /// You currently have %@ Dogecoin available to send. Doge Rewards are not available to send until 48 hours after they are earned.
    public static func description(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "crypto_send_annotation.description", String(describing: p1), fallback: "You currently have %@ Dogecoin available to send. Doge Rewards are not available to send until 48 hours after they are earned.")
    }
  }
  public enum DashboardCash {
    /// Deposit
    public static let addMoney = LFLocalizable.tr("Localizable", "dashboard_cash.add_money", fallback: "Deposit")
    /// Bank Statements
    public static let bankStatements = LFLocalizable.tr("Localizable", "dashboard_cash.bank_statements", fallback: "Bank Statements")
    /// Latest Transactions
    public static let lastTransactions = LFLocalizable.tr("Localizable", "dashboard_cash.last_transactions", fallback: "Latest Transactions")
    /// See all
    public static let seeAll = LFLocalizable.tr("Localizable", "dashboard_cash.see_all", fallback: "See all")
    /// Withdraw
    public static let sendMoney = LFLocalizable.tr("Localizable", "dashboard_cash.send_money", fallback: "Withdraw")
    /// More ways to deposit
    public static let waysToAdd = LFLocalizable.tr("Localizable", "dashboard_cash.ways_to_add", fallback: "More ways to deposit")
  }
  public enum DashboardCrypto {
    /// Buy
    public static let buy = LFLocalizable.tr("Localizable", "dashboard_crypto.buy", fallback: "Buy")
    /// Change
    public static let change = LFLocalizable.tr("Localizable", "dashboard_crypto.change", fallback: "Change")
    /// Close
    public static let close = LFLocalizable.tr("Localizable", "dashboard_crypto.close", fallback: "Close")
    /// Cryptocurrency services powered by Zero Hash
    public static let disclosure = LFLocalizable.tr("Localizable", "dashboard_crypto.disclosure", fallback: "Cryptocurrency services powered by Zero Hash")
    /// High
    public static let high = LFLocalizable.tr("Localizable", "dashboard_crypto.high", fallback: "High")
    /// Latest Transactions
    public static let lastTransactions = LFLocalizable.tr("Localizable", "dashboard_crypto.last_transactions", fallback: "Latest Transactions")
    /// Low
    public static let low = LFLocalizable.tr("Localizable", "dashboard_crypto.low", fallback: "Low")
    /// Open
    public static let `open` = LFLocalizable.tr("Localizable", "dashboard_crypto.open", fallback: "Open")
    /// See all
    public static let seeAll = LFLocalizable.tr("Localizable", "dashboard_crypto.see_all", fallback: "See all")
    /// Sell
    public static let sell = LFLocalizable.tr("Localizable", "dashboard_crypto.sell", fallback: "Sell")
    /// Today
    public static let today = LFLocalizable.tr("Localizable", "dashboard_crypto.today", fallback: "Today")
    /// Transfer
    public static let transfer = LFLocalizable.tr("Localizable", "dashboard_crypto.transfer", fallback: "Transfer")
    /// Volume
    public static let volume = LFLocalizable.tr("Localizable", "dashboard_crypto.volume", fallback: "Volume")
    /// Wallet address
    public static let walletAddress = LFLocalizable.tr("Localizable", "dashboard_crypto.wallet_address", fallback: "Wallet address")
    public enum BuyBalancePopup {
      /// Add Money
      public static let primary = LFLocalizable.tr("Localizable", "dashboard_crypto.buy_balance_popup.primary", fallback: "Add Money")
      /// Not now
      public static let secondary = LFLocalizable.tr("Localizable", "dashboard_crypto.buy_balance_popup.secondary", fallback: "Not now")
      /// PLEASE ADD TO YOUR CASH BALANCE TO BUY DOGE.
      public static let title = LFLocalizable.tr("Localizable", "dashboard_crypto.buy_balance_popup.title", fallback: "PLEASE ADD TO YOUR CASH BALANCE TO BUY DOGE.")
    }
    public enum SellBalancePopup {
      /// YOU DON'T HAVE ANY DOGE TO SELL AT THIS TIME.
      public static let title = LFLocalizable.tr("Localizable", "dashboard_crypto.sell_balance_popup.title", fallback: "YOU DON'T HAVE ANY DOGE TO SELL AT THIS TIME.")
    }
  }
  public enum DepositDenied {
    /// DEPOSIT DENIED
    public static let title = LFLocalizable.tr("Localizable", "deposit_denied.title", fallback: "DEPOSIT DENIED")
    public enum DebitCard {
      /// This deposit has been blocked by your bank. Please contact them to enable your debit card.
      public static let message = LFLocalizable.tr("Localizable", "deposit_denied.debit_card.message", fallback: "This deposit has been blocked by your bank. Please contact them to enable your debit card.")
    }
  }
  public enum DepositLimit {
    /// This deposit was blocked because it is over your bank's current withdraw limit. Please contact your bank to raise the limit.
    public static let bank = LFLocalizable.tr("Localizable", "deposit_limit.bank", fallback: "This deposit was blocked because it is over your bank's current withdraw limit. Please contact your bank to raise the limit.")
    /// Close
    public static let close = LFLocalizable.tr("Localizable", "deposit_limit.close", fallback: "Close")
    /// You have reached your daily deposit limit.
    public static let daily = LFLocalizable.tr("Localizable", "deposit_limit.daily", fallback: "You have reached your daily deposit limit.")
    /// We currently have a %@ per transaction limit, please try again by depositing %@ or under.
    public static func debitCard(_ p1: Any, _ p2: Any) -> String {
      return LFLocalizable.tr("Localizable", "deposit_limit.debit_card", String(describing: p1), String(describing: p2), fallback: "We currently have a %@ per transaction limit, please try again by depositing %@ or under.")
    }
    /// Learn about limits
    public static let learn = LFLocalizable.tr("Localizable", "deposit_limit.learn", fallback: "Learn about limits")
    /// You have reached your monthly deposit limit.
    public static let monthly = LFLocalizable.tr("Localizable", "deposit_limit.monthly", fallback: "You have reached your monthly deposit limit.")
    /// DEPOSIT LIMIT REACHED
    public static let title = LFLocalizable.tr("Localizable", "deposit_limit.title", fallback: "DEPOSIT LIMIT REACHED")
    public enum Daily {
      /// We're sorry, your deposit crossed your daily limits. Please contact support to increase your limits.
      public static let message = LFLocalizable.tr("Localizable", "deposit_limit.daily.message", fallback: "We're sorry, your deposit crossed your daily limits. Please contact support to increase your limits.")
    }
    public enum Monthly {
      /// We're sorry, your deposit crossed your monthly limits. Please contact support to increase your limits.
      public static let message = LFLocalizable.tr("Localizable", "deposit_limit.monthly.message", fallback: "We're sorry, your deposit crossed your monthly limits. Please contact support to increase your limits.")
    }
    public enum Transaction {
      /// Transaction Limit
      public static let titleGeneric = LFLocalizable.tr("Localizable", "deposit_limit.transaction.title_generic", fallback: "Transaction Limit")
      /// %@ Transaction Limit
      public static func titleSpecific(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "deposit_limit.transaction.title_specific", String(describing: p1), fallback: "%@ Transaction Limit")
      }
    }
  }
  public enum DepositLimits {
    /// ACH Deposit
    public static let achDeposit = LFLocalizable.tr("Localizable", "deposit_limits.ach_deposit", fallback: "ACH Deposit")
    /// Request limit increase with support
    public static let chatOption = LFLocalizable.tr("Localizable", "deposit_limits.chat_option", fallback: "Request limit increase with support")
    /// Daily:
    public static let daily = LFLocalizable.tr("Localizable", "deposit_limits.daily", fallback: "Daily:")
    /// Debit Card Deposit
    public static let debitCardDeposit = LFLocalizable.tr("Localizable", "deposit_limits.debit_card_deposit", fallback: "Debit Card Deposit")
    /// Direct Deposit
    public static let directDeposit = LFLocalizable.tr("Localizable", "deposit_limits.direct_deposit", fallback: "Direct Deposit")
    /// Set up Direct Deposit
    public static let directDepositOption = LFLocalizable.tr("Localizable", "deposit_limits.direct_deposit_option", fallback: "Set up Direct Deposit")
    /// Ways to increase limits
    public static let increaseOptions = LFLocalizable.tr("Localizable", "deposit_limits.increase_options", fallback: "Ways to increase limits")
    /// Monthly:
    public static let monthly = LFLocalizable.tr("Localizable", "deposit_limits.monthly", fallback: "Monthly:")
    /// Verify your account with Plaid
    public static let plaidOption = LFLocalizable.tr("Localizable", "deposit_limits.plaid_option", fallback: "Verify your account with Plaid")
    /// Deposit Limits
    public static let title = LFLocalizable.tr("Localizable", "deposit_limits.title", fallback: "Deposit Limits")
    /// Transfer from your bank
    public static let transferOption = LFLocalizable.tr("Localizable", "deposit_limits.transfer_option", fallback: "Transfer from your bank")
    /// Unlimited
    public static let unlimited = LFLocalizable.tr("Localizable", "deposit_limits.unlimited", fallback: "Unlimited")
    /// Wire or Bank Transfer
    public static let wireBank = LFLocalizable.tr("Localizable", "deposit_limits.wire_bank", fallback: "Wire or Bank Transfer")
    public enum PlaidSuccess {
      /// Ok
      public static let button = LFLocalizable.tr("Localizable", "deposit_limits.plaid_success.button", fallback: "Ok")
      /// You have successfully verified your account
      public static let message = LFLocalizable.tr("Localizable", "deposit_limits.plaid_success.message", fallback: "You have successfully verified your account")
      /// Congratulations!
      public static let title = LFLocalizable.tr("Localizable", "deposit_limits.plaid_success.title", fallback: "Congratulations!")
    }
  }
  public enum DirectDepositBenefits {
    /// Done
    public static let done = LFLocalizable.tr("Localizable", "direct_deposit_benefits.done", fallback: "Done")
    /// Payday up to 2 days early
    public static let itemOne = LFLocalizable.tr("Localizable", "direct_deposit_benefits.item_one", fallback: "Payday up to 2 days early")
    /// FDIC-insured through Evolve Bank and Trust
    public static let itemTwo = LFLocalizable.tr("Localizable", "direct_deposit_benefits.item_two", fallback: "FDIC-insured through Evolve Bank and Trust")
    /// BENEFITS OF DIRECT DEPOSIT WITH CAUSECARD
    public static let title = LFLocalizable.tr("Localizable", "direct_deposit_benefits.title", fallback: "BENEFITS OF DIRECT DEPOSIT WITH CAUSECARD")
  }
  public enum DonationThanks {
    /// Invite your friends and family to fight for Reproductive Rights by signing up for CauseCard.
    public static let invite = LFLocalizable.tr("Localizable", "donation_thanks.invite", fallback: "Invite your friends and family to fight for Reproductive Rights by signing up for CauseCard.")
    /// Share fundraiser
    public static let share = LFLocalizable.tr("Localizable", "donation_thanks.share", fallback: "Share fundraiser")
    /// Every donation counts as a step closer.
    public static let subtitle = LFLocalizable.tr("Localizable", "donation_thanks.subtitle", fallback: "Every donation counts as a step closer.")
    /// THANK YOU FOR YOUR DONATION!
    public static let title = LFLocalizable.tr("Localizable", "donation_thanks.title", fallback: "THANK YOU FOR YOUR DONATION!")
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
    /// 100% of the donations you make are tax deductible and go to charity. 
    public static func text(_ p1: Int) -> String {
      return LFLocalizable.tr("Localizable", "donations_disclosure.text", p1, fallback: "100% of the donations you make are tax deductible and go to charity. ")
    }
    public enum Alert {
      /// Powered by ShoppingGives 
      public static let poweredBy = LFLocalizable.tr("Localizable", "donations_disclosure.alert.powered_by", fallback: "Powered by ShoppingGives ")
      /// DONATIONS
      public static let title = LFLocalizable.tr("Localizable", "donations_disclosure.alert.title", fallback: "DONATIONS")
    }
  }
  public enum EditNicknameOfWallet {
    /// Create new name for %@
    public static func createNickname(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "edit_nickname_of_wallet.create_nickname", String(describing: p1), fallback: "Create new name for %@")
    }
    /// You can change it at any time
    public static let disclosures = LFLocalizable.tr("Localizable", "edit_nickname_of_wallet.disclosures", fallback: "You can change it at any time")
    /// Enter name
    public static let placeholder = LFLocalizable.tr("Localizable", "edit_nickname_of_wallet.placeholder", fallback: "Enter name")
    /// Save
    public static let saveButton = LFLocalizable.tr("Localizable", "edit_nickname_of_wallet.save_button", fallback: "Save")
    /// Wallet address name
    public static let textFieldTitle = LFLocalizable.tr("Localizable", "edit_nickname_of_wallet.textField_title", fallback: "Wallet address name")
    /// EDIT WALLET ADDRESS
    public static let title = LFLocalizable.tr("Localizable", "edit_nickname_of_wallet.title", fallback: "EDIT WALLET ADDRESS")
    public enum NameExits {
      /// This wallet address name already exists
      public static let inlineError = LFLocalizable.tr("Localizable", "edit_nickname_of_wallet.name_exits.inline_error", fallback: "This wallet address name already exists")
    }
  }
  public enum EditRewards {
    /// Change rewards
    public static let navigationTitle = LFLocalizable.tr("Localizable", "edit_rewards.navigation_title", fallback: "Change rewards")
    /// Please select your rewards
    public static let title = LFLocalizable.tr("Localizable", "edit_rewards.title", fallback: "Please select your rewards")
  }
  public enum EnterNicknameOfWallet {
    /// Create a name for %@
    public static func createNickname(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.create_nickname", String(describing: p1), fallback: "Create a name for %@")
    }
    /// You can change it at any time
    public static let disclosures = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.disclosures", fallback: "You can change it at any time")
    /// Enter name
    public static let placeholder = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.placeholder", fallback: "Enter name")
    /// Save
    public static let saveButton = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.save_button", fallback: "Save")
    /// SAVE WALLET ADDRESS
    public static let saveTitle = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.save_title", fallback: "SAVE WALLET ADDRESS")
    /// Wallet address name
    public static let textFieldTitle = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.textField_title", fallback: "Wallet address name")
    public enum NameExits {
      /// This wallet address name already exists
      public static let inlineError = LFLocalizable.tr("Localizable", "enter_nickname_of_wallet.name_exits.inline_error", fallback: "This wallet address name already exists")
    }
  }
  public enum EnterSsn {
    /// Encrypted using 256-BIT SSL
    public static let bulletOne = LFLocalizable.tr("Localizable", "enter_ssn.bullet_one", fallback: "Encrypted using 256-BIT SSL")
    /// No credit checks, doesn't impact credit score
    public static let bulletTwo = LFLocalizable.tr("Localizable", "enter_ssn.bullet_two", fallback: "No credit checks, doesn't impact credit score")
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
      /// A valid SSN or Passport is required by our bank, Evolve Bank and Trust, to create a FDIC insured checking account. Your SSN is only stored with the bank and not accessible through CauseCard.
      public static let message = LFLocalizable.tr("Localizable", "enter_ssn.alert.message", fallback: "A valid SSN or Passport is required by our bank, Evolve Bank and Trust, to create a FDIC insured checking account. Your SSN is only stored with the bank and not accessible through CauseCard.")
      /// Ok
      public static let ok = LFLocalizable.tr("Localizable", "enter_ssn.alert.ok", fallback: "Ok")
      /// WHY DO WE NEED SSN?
      public static let title = LFLocalizable.tr("Localizable", "enter_ssn.alert.title", fallback: "WHY DO WE NEED SSN?")
    }
  }
  public enum FundCard {
    /// CauseCard is a Pre-paid Debit Card, which means there are no credit checks, interest payments or overdrafts. However, you have to deposit money to your account before you can use. Start by connecting your bank:
    public static let message = LFLocalizable.tr("Localizable", "fund_card.message", fallback: "CauseCard is a Pre-paid Debit Card, which means there are no credit checks, interest payments or overdrafts. However, you have to deposit money to your account before you can use. Start by connecting your bank:")
    /// Skip
    public static let skip = LFLocalizable.tr("Localizable", "fund_card.skip", fallback: "Skip")
    /// FUND YOUR CAUSECARD
    public static let title = LFLocalizable.tr("Localizable", "fund_card.title", fallback: "FUND YOUR CAUSECARD")
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
  public enum FundraiserReceipt {
    /// Donations made to %@. EIN: %@
    public static func charity(_ p1: Any, _ p2: Any) -> String {
      return LFLocalizable.tr("Localizable", "fundraiser_receipt.charity", String(describing: p1), String(describing: p2), fallback: "Donations made to %@. EIN: %@")
    }
    /// 100%% of funds are tax deductible and granted to designated nonprofit: %@.
    public static func fundraiser(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "fundraiser_receipt.fundraiser", String(describing: p1), fallback: "100%% of funds are tax deductible and granted to designated nonprofit: %@.")
    }
    /// Privacy Policy
    public static let privacy = LFLocalizable.tr("Localizable", "fundraiser_receipt.privacy", fallback: "Privacy Policy")
    /// Terms & Conditions
    public static let terms = LFLocalizable.tr("Localizable", "fundraiser_receipt.terms", fallback: "Terms & Conditions")
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
    /// %@ DOGE
    public static func crypto(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "grid_value.crypto", String(describing: p1), fallback: "%@ DOGE")
    }
  }
  public enum Home {
    public enum Title {
      /// Accounts
      public static let account = LFLocalizable.tr("Localizable", "home.title.account", fallback: "Accounts")
      /// Cash
      public static let cash = LFLocalizable.tr("Localizable", "home.title.cash", fallback: "Cash")
      /// Causes
      public static let causes = LFLocalizable.tr("Localizable", "home.title.causes", fallback: "Causes")
      /// Doge
      public static let crypto = LFLocalizable.tr("Localizable", "home.title.crypto", fallback: "Doge")
      /// Rewards
      public static let rewards = LFLocalizable.tr("Localizable", "home.title.rewards", fallback: "Rewards")
    }
  }
  public enum InitialView {
    /// CauseCard
    public static let title = LFLocalizable.tr("Localizable", "initial_view.title", fallback: "CauseCard")
  }
  public enum KycStatus {
    public enum Declined {
      /// Based on the information you entered, we were unable to create a Depository account at this time. We will be in touch via email.
      public static let message = LFLocalizable.tr("Localizable", "kyc_status.declined.message", fallback: "Based on the information you entered, we were unable to create a Depository account at this time. We will be in touch via email.")
      /// Done
      public static let primary = LFLocalizable.tr("Localizable", "kyc_status.declined.primary", fallback: "Done")
      /// WE'RE SORRY
      public static let title = LFLocalizable.tr("Localizable", "kyc_status.declined.title", fallback: "WE'RE SORRY")
    }
    public enum Idv {
      /// Please verify your identity with a valid Driver’s License, ID or Passport.
      public static let message = LFLocalizable.tr("Localizable", "kyc_status.idv.message", fallback: "Please verify your identity with a valid Driver’s License, ID or Passport.")
      /// Continue
      public static let primary = LFLocalizable.tr("Localizable", "kyc_status.idv.primary", fallback: "Continue")
      /// DRIVER’S LICENSE, ID OR PASSPORT
      public static let title = LFLocalizable.tr("Localizable", "kyc_status.idv.title", fallback: "DRIVER’S LICENSE, ID OR PASSPORT")
    }
    public enum InReview {
      /// Hi %@, we are still verifying your account details. This is common when VOIP or Google voice phone numbers are used, or addresses / emails change. Please contact support and we will help verify the details. Thank you for your patience.
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "kyc_status.in_review.message", String(describing: p1), fallback: "Hi %@, we are still verifying your account details. This is common when VOIP or Google voice phone numbers are used, or addresses / emails change. Please contact support and we will help verify the details. Thank you for your patience.")
      }
      /// Check Account Status
      public static let primary = LFLocalizable.tr("Localizable", "kyc_status.in_review.primary", fallback: "Check Account Status")
      /// Contact Support
      public static let secondary = LFLocalizable.tr("Localizable", "kyc_status.in_review.secondary", fallback: "Contact Support")
      /// VERIFYING ACCOUNT DETAILS
      public static let title = LFLocalizable.tr("Localizable", "kyc_status.in_review.title", fallback: "VERIFYING ACCOUNT DETAILS")
    }
  }
  public enum KycWait {
    /// We're confiming your account details. This could take up to 30 seconds.
    public static let message = LFLocalizable.tr("Localizable", "kyc_wait.message", fallback: "We're confiming your account details. This could take up to 30 seconds.")
    /// Thank you for waiting
    public static let title = LFLocalizable.tr("Localizable", "kyc_wait.title", fallback: "Thank you for waiting")
  }
  public enum LinkDirectDeposit {
    /// See all the benefits
    public static let allBenefits = LFLocalizable.tr("Localizable", "link_direct_deposit.all_benefits", fallback: "See all the benefits")
    /// Direct Deposit
    public static let navigationTitle = LFLocalizable.tr("Localizable", "link_direct_deposit.navigation_title", fallback: "Direct Deposit")
    public enum Automatic {
      /// Get Started
      public static let cta = LFLocalizable.tr("Localizable", "link_direct_deposit.automatic.cta", fallback: "Get Started")
      /// Automatic Setup
      public static let header = LFLocalizable.tr("Localizable", "link_direct_deposit.automatic.header", fallback: "Automatic Setup")
      /// Tell us who pays you, and we'll help you get set up.
      public static let message = LFLocalizable.tr("Localizable", "link_direct_deposit.automatic.message", fallback: "Tell us who pays you, and we'll help you get set up.")
      /// FIND YOUR EMPLOYER
      public static let title = LFLocalizable.tr("Localizable", "link_direct_deposit.automatic.title", fallback: "FIND YOUR EMPLOYER")
    }
    public enum Manual {
      /// Account number
      public static let account = LFLocalizable.tr("Localizable", "link_direct_deposit.manual.account", fallback: "Account number")
      /// Fill out a form
      public static let cta = LFLocalizable.tr("Localizable", "link_direct_deposit.manual.cta", fallback: "Fill out a form")
      /// Manual Setup
      public static let header = LFLocalizable.tr("Localizable", "link_direct_deposit.manual.header", fallback: "Manual Setup")
      /// Give these to your employer and they'll handle the rest.
      public static let message = LFLocalizable.tr("Localizable", "link_direct_deposit.manual.message", fallback: "Give these to your employer and they'll handle the rest.")
      /// Routing number
      public static let routing = LFLocalizable.tr("Localizable", "link_direct_deposit.manual.routing", fallback: "Routing number")
      /// USE ACCOUNT DETAILS
      public static let title = LFLocalizable.tr("Localizable", "link_direct_deposit.manual.title", fallback: "USE ACCOUNT DETAILS")
    }
  }
  public enum Location {
    public enum Denied {
      /// Open Settings
      public static let cta = LFLocalizable.tr("Localizable", "location.denied.cta", fallback: "Open Settings")
      /// Please grant location access to find ATMs nearby.
      public static let message = LFLocalizable.tr("Localizable", "location.denied.message", fallback: "Please grant location access to find ATMs nearby.")
    }
    public enum Details {
      /// Directions
      public static let cta = LFLocalizable.tr("Localizable", "location.details.cta", fallback: "Directions")
      ///  %.2f mi
      public static func distance(_ p1: Float) -> String {
        return LFLocalizable.tr("Localizable", "location.details.distance", p1, fallback: " %.2f mi")
      }
    }
    public enum Navigation {
      /// Open in Apple Maps
      public static let apple = LFLocalizable.tr("Localizable", "location.navigation.apple", fallback: "Open in Apple Maps")
      /// Cancel
      public static let cancel = LFLocalizable.tr("Localizable", "location.navigation.cancel", fallback: "Cancel")
      /// Open in Google Maps
      public static let google = LFLocalizable.tr("Localizable", "location.navigation.google", fallback: "Open in Google Maps")
    }
  }
  public enum Logout {
    /// Log Out
    public static let title = LFLocalizable.tr("Localizable", "logout.title", fallback: "Log Out")
    public enum Alert {
      /// No
      public static let primary = LFLocalizable.tr("Localizable", "logout.alert.primary", fallback: "No")
      /// Yes
      public static let secondary = LFLocalizable.tr("Localizable", "logout.alert.secondary", fallback: "Yes")
      /// Are you sure you want to log out?
      public static let title = LFLocalizable.tr("Localizable", "logout.alert.title", fallback: "Are you sure you want to log out?")
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
    public enum Close {
      /// Close
      public static let button = LFLocalizable.tr("Localizable", "popup.close.button", fallback: "Close")
    }
    public enum ContactSupport {
      /// Contact Support
      public static let button = LFLocalizable.tr("Localizable", "popup.contact_support.button", fallback: "Contact Support")
    }
    public enum Error {
      /// ERROR
      public static let title = LFLocalizable.tr("Localizable", "popup.error.title", fallback: "ERROR")
    }
    public enum Ok {
      /// OK
      public static let button = LFLocalizable.tr("Localizable", "popup.ok.button", fallback: "OK")
    }
    public enum Okay {
      /// Okay
      public static let button = LFLocalizable.tr("Localizable", "popup.okay.button", fallback: "Okay")
    }
    public enum Retry {
      /// Retry
      public static let button = LFLocalizable.tr("Localizable", "popup.retry.button", fallback: "Retry")
    }
    public enum TryAgain {
      /// Try again
      public static let button = LFLocalizable.tr("Localizable", "popup.try_again.button", fallback: "Try again")
    }
    public enum WeAreSorry {
      /// WE ARE SORRY
      public static let title = LFLocalizable.tr("Localizable", "popup.we_are_sorry.title", fallback: "WE ARE SORRY")
    }
  }
  public enum Profile {
    /// Account & Settings
    public static let accountSettings = LFLocalizable.tr("Localizable", "profile.account_settings", fallback: "Account & Settings")
    /// Address
    public static let address = LFLocalizable.tr("Localizable", "profile.address", fallback: "Address")
    /// ATM's Nearby
    public static let atm = LFLocalizable.tr("Localizable", "profile.atm", fallback: "ATM's Nearby")
    /// Bank Statements
    public static let bankStatements = LFLocalizable.tr("Localizable", "profile.bank_statements", fallback: "Bank Statements")
    /// Failed to load your donations
    public static let contributionToast = LFLocalizable.tr("Localizable", "profile.contribution_toast", fallback: "Failed to load your donations")
    /// Delete Account
    public static let deleteAccount = LFLocalizable.tr("Localizable", "profile.delete_account", fallback: "Delete Account")
    /// Deposit Limits
    public static let depositLimits = LFLocalizable.tr("Localizable", "profile.deposit_limits", fallback: "Deposit Limits")
    /// Email
    public static let email = LFLocalizable.tr("Localizable", "profile.email", fallback: "Email")
    /// Help & support
    public static let help = LFLocalizable.tr("Localizable", "profile.help", fallback: "Help & support")
    /// Notifications
    public static let notifications = LFLocalizable.tr("Localizable", "profile.notifications", fallback: "Notifications")
    /// OR
    public static let or = LFLocalizable.tr("Localizable", "profile.or", fallback: "OR")
    /// Phone Number
    public static let phoneNumber = LFLocalizable.tr("Localizable", "profile.phone_number", fallback: "Phone Number")
    /// Current Rewards
    public static let rewards = LFLocalizable.tr("Localizable", "profile.rewards", fallback: "Current Rewards")
    /// Stickers
    public static let stickers = LFLocalizable.tr("Localizable", "profile.stickers", fallback: "Stickers")
    /// Taxes
    public static let taxes = LFLocalizable.tr("Localizable", "profile.taxes", fallback: "Taxes")
    /// Profile
    public static let title = LFLocalizable.tr("Localizable", "profile.title", fallback: "Profile")
    /// Total donated
    public static let totalDonated = LFLocalizable.tr("Localizable", "profile.total_donated", fallback: "Total donated")
    /// Total donations
    public static let totalDonations = LFLocalizable.tr("Localizable", "profile.total_donations", fallback: "Total donations")
    /// Version %@
    public static func version(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "profile.version", String(describing: p1), fallback: "Version %@")
    }
    public enum DeleteAccount {
      /// No
      public static let primary = LFLocalizable.tr("Localizable", "profile.delete_account.primary", fallback: "No")
      /// Yes
      public static let secondary = LFLocalizable.tr("Localizable", "profile.delete_account.secondary", fallback: "Yes")
      /// Are you sure you want to delete your account?
      public static let title = LFLocalizable.tr("Localizable", "profile.delete_account.title", fallback: "Are you sure you want to delete your account?")
    }
  }
  public enum PushNotification {
    /// We were unable to load the notification right now.
    /// Please try again.
    public static let error = LFLocalizable.tr("Localizable", "push_notification.error", fallback: "We were unable to load the notification right now.\nPlease try again.")
    /// Retry
    public static let retry = LFLocalizable.tr("Localizable", "push_notification.retry", fallback: "Retry")
  }
  public enum ReferralCampaign {
    /// %d days
    public static func day(_ p1: Int) -> String {
      return LFLocalizable.tr("Localizable", "referral_campaign.day", p1, fallback: "%d days")
    }
    /// %d weeks
    public static func week(_ p1: Int) -> String {
      return LFLocalizable.tr("Localizable", "referral_campaign.week", p1, fallback: "%d weeks")
    }
  }
  public enum Referrals {
    /// Copy invite link
    public static let copy = LFLocalizable.tr("Localizable", "referrals.copy", fallback: "Copy invite link")
    /// We are unable to fetch the referral campaigns now. Please try again.
    public static let error = LFLocalizable.tr("Localizable", "referrals.error", fallback: "We are unable to fetch the referral campaigns now. Please try again.")
    /// Send your invite link to a friend, and we will match their donations for the first %@, or up to %@. This is tax deductable donations in your name.
    public static func info(_ p1: Any, _ p2: Any) -> String {
      return LFLocalizable.tr("Localizable", "referrals.info", String(describing: p1), String(describing: p2), fallback: "Send your invite link to a friend, and we will match their donations for the first %@, or up to %@. This is tax deductable donations in your name.")
    }
    /// Retry
    public static let retry = LFLocalizable.tr("Localizable", "referrals.retry", fallback: "Retry")
    /// Send invite link
    public static let send = LFLocalizable.tr("Localizable", "referrals.send", fallback: "Send invite link")
    /// MAKE DONATIONS WITH FRIENDS
    public static let title = LFLocalizable.tr("Localizable", "referrals.title", fallback: "MAKE DONATIONS WITH FRIENDS")
    /// Invite link copied to clipboard.
    public static let toastMessage = LFLocalizable.tr("Localizable", "referrals.toast_message", fallback: "Invite link copied to clipboard.")
    public enum Example {
      /// If the friend you invited earns 500 Doge in a week, you will also get 500 Doge. Your bonus will be paid each Friday to your DogeCard wallet within the first %@.
      public static func crypto(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "referrals.example.crypto", String(describing: p1), fallback: "If the friend you invited earns 500 Doge in a week, you will also get 500 Doge. Your bonus will be paid each Friday to your DogeCard wallet within the first %@.")
      }
      /// If your friend donates %@ in the first %@, we will donate %@ to your selected cause. The donation will be made in your name and is tax deductable.
      public static func donation(_ p1: Any, _ p2: Any, _ p3: Any) -> String {
        return LFLocalizable.tr("Localizable", "referrals.example.donation", String(describing: p1), String(describing: p2), String(describing: p3), fallback: "If your friend donates %@ in the first %@, we will donate %@ to your selected cause. The donation will be made in your name and is tax deductable.")
      }
      /// HOW IT WORKS
      public static let title = LFLocalizable.tr("Localizable", "referrals.example.title", fallback: "HOW IT WORKS")
    }
  }
  public enum ReferralsRow {
    /// Make donations
    public static let message = LFLocalizable.tr("Localizable", "referrals_row.message", fallback: "Make donations")
    /// Invite Friends
    public static let title = LFLocalizable.tr("Localizable", "referrals_row.title", fallback: "Invite Friends")
  }
  public enum RewardTypes {
    /// We were unable to load your rewards right now.
    /// Please try again.
    public static let error = LFLocalizable.tr("Localizable", "reward_types.error", fallback: "We were unable to load your rewards right now.\nPlease try again.")
    /// Current Rewards
    public static let navigationTitle = LFLocalizable.tr("Localizable", "reward_types.navigation_title", fallback: "Current Rewards")
    /// Retry
    public static let retry = LFLocalizable.tr("Localizable", "reward_types.retry", fallback: "Retry")
    public enum Card {
      /// Watch how to video
      public static let cta = LFLocalizable.tr("Localizable", "reward_types.card.cta", fallback: "Watch how to video")
      /// Earn about 1 Doge for every $10 of Credit Card bill paid. Watch this how-to video.
      public static let subtitle = LFLocalizable.tr("Localizable", "reward_types.card.subtitle", fallback: "Earn about 1 Doge for every $10 of Credit Card bill paid. Watch this how-to video.")
      /// Pay your Credit Card Bill with DogeCard
      public static let title = LFLocalizable.tr("Localizable", "reward_types.card.title", fallback: "Pay your Credit Card Bill with DogeCard")
    }
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
    /// Skip
    public static let skip = LFLocalizable.tr("Localizable", "round_up.skip", fallback: "Skip")
    /// ROUND UPS
    public static let title = LFLocalizable.tr("Localizable", "round_up.title", fallback: "ROUND UPS")
  }
  public enum SavedWalletAddress {
    /// Name, or Wallet Address
    public static let textFieldPlaceholder = LFLocalizable.tr("Localizable", "saved_wallet_address.textField_placeholder", fallback: "Name, or Wallet Address")
    public enum DeletePopup {
      /// Would you like to delete saved wallet: %@?
      public static func message(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "saved_wallet_address.delete_popup.message", String(describing: p1), fallback: "Would you like to delete saved wallet: %@?")
      }
      /// Delete
      public static let primaryButton = LFLocalizable.tr("Localizable", "saved_wallet_address.delete_popup.primary_button", fallback: "Delete")
      /// Delete Saved wallet address
      public static let title = LFLocalizable.tr("Localizable", "saved_wallet_address.delete_popup.title", fallback: "Delete Saved wallet address")
    }
    public enum DeleteSuccess {
      /// Wallet address deleted
      public static let message = LFLocalizable.tr("Localizable", "saved_wallet_address.delete_success.message", fallback: "Wallet address deleted")
    }
    public enum SaveSuccess {
      /// Wallet address saved
      public static let message = LFLocalizable.tr("Localizable", "saved_wallet_address.save_success.message", fallback: "Wallet address saved")
    }
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
  public enum SelectCause {
    /// Continue
    public static let `continue` = LFLocalizable.tr("Localizable", "select_cause.continue", fallback: "Continue")
    /// Select cause you are interested in
    public static let subtitle = LFLocalizable.tr("Localizable", "select_cause.subtitle", fallback: "Select cause you are interested in")
    /// Causes to support
    public static let title = LFLocalizable.tr("Localizable", "select_cause.title", fallback: "Causes to support")
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
    /// Welcome to %@, please select your rewards. You can change anytime.
    public static func subtitle(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "select_rewards.subtitle", String(describing: p1), fallback: "Welcome to %@, please select your rewards. You can change anytime.")
    }
    /// Select Rewards
    public static let title = LFLocalizable.tr("Localizable", "select_rewards.title", fallback: "Select Rewards")
  }
  public enum SetCardPin {
    /// This PIN can be used at ATMs and for purchases, and is not used to get access to the app.
    public static let message = LFLocalizable.tr("Localizable", "set_card_pin.message", fallback: "This PIN can be used at ATMs and for purchases, and is not used to get access to the app.")
    /// SET CARD PIN
    public static let title = LFLocalizable.tr("Localizable", "set_card_pin.title", fallback: "SET CARD PIN")
    public enum Success {
      /// Your card's PIN is now set. Use it for purchases and at ATMs.
      public static let message = LFLocalizable.tr("Localizable", "set_card_pin.success.message", fallback: "Your card's PIN is now set. Use it for purchases and at ATMs.")
      /// CARD PIN SET
      public static let title = LFLocalizable.tr("Localizable", "set_card_pin.success.title", fallback: "CARD PIN SET")
    }
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
      /// I'm using CauseCard to support %@ by making passive donations through my everyday purchases.
      public static func fundraiser(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "share.card.fundraiser", String(describing: p1), fallback: "I'm using CauseCard to support %@ by making passive donations through my everyday purchases.")
      }
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
      /// There are currently no taxes
      public static let message = LFLocalizable.tr("Localizable", "taxes.empty.message", fallback: "There are currently no taxes")
      /// NO TAXES
      public static let title = LFLocalizable.tr("Localizable", "taxes.empty.title", fallback: "NO TAXES")
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
  public enum TransactionDetail {
    /// Balance: %@
    public static func balanceCash(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transaction_detail.balance_cash", String(describing: p1), fallback: "Balance: %@")
    }
    /// Balance: %@ DOGE
    public static func balanceCrypto(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transaction_detail.balance_crypto", String(describing: p1), fallback: "Balance: %@ DOGE")
    }
    /// Current rewards
    public static let currentRewards = LFLocalizable.tr("Localizable", "transaction_detail.current_rewards", fallback: "Current rewards")
    /// Description
    public static let description = LFLocalizable.tr("Localizable", "transaction_detail.description", fallback: "Description")
    /// Donation
    public static let donation = LFLocalizable.tr("Localizable", "transaction_detail.donation", fallback: "Donation")
    /// Vendor
    public static let merchant = LFLocalizable.tr("Localizable", "transaction_detail.merchant", fallback: "Vendor")
    /// Paid To
    public static let paidTo = LFLocalizable.tr("Localizable", "transaction_detail.paid_to", fallback: "Paid To")
    /// Received From
    public static let receivedFrom = LFLocalizable.tr("Localizable", "transaction_detail.received_from", fallback: "Received From")
    /// Reward
    public static let reward = LFLocalizable.tr("Localizable", "transaction_detail.reward", fallback: "Reward")
    /// Source
    public static let source = LFLocalizable.tr("Localizable", "transaction_detail.source", fallback: "Source")
    /// Title
    public static let title = LFLocalizable.tr("Localizable", "transaction_detail.title", fallback: "Title")
    /// Total Donated: %@
    public static func totalDonated(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transaction_detail.total_donated", String(describing: p1), fallback: "Total Donated: %@")
    }
    /// Transaction Id
    public static let transactionId = LFLocalizable.tr("Localizable", "transaction_detail.transaction_id", fallback: "Transaction Id")
    /// Status
    public static let transactionStatus = LFLocalizable.tr("Localizable", "transaction_detail.transaction_status", fallback: "Status")
    /// Transaction Type
    public static let transactionType = LFLocalizable.tr("Localizable", "transaction_detail.transaction_type", fallback: "Transaction Type")
    public enum SaveWalletPopup {
      /// Save wallet address
      public static let button = LFLocalizable.tr("Localizable", "transaction_detail.save_wallet_popup.button", fallback: "Save wallet address")
      /// Would you like to save this wallet address to use again?
      public static let description = LFLocalizable.tr("Localizable", "transaction_detail.save_wallet_popup.description", fallback: "Would you like to save this wallet address to use again?")
      /// SAVE WALLET ADDRESS
      public static let title = LFLocalizable.tr("Localizable", "transaction_detail.save_wallet_popup.title", fallback: "SAVE WALLET ADDRESS")
    }
  }
  public enum TransactionReceipt {
    /// Account ID
    public static let accountId = LFLocalizable.tr("Localizable", "transaction_receipt.account_id", fallback: "Account ID")
    /// Cashback
    public static let cashback = LFLocalizable.tr("Localizable", "transaction_receipt.cashback", fallback: "Cashback")
    /// Date and Time
    public static let dateTime = LFLocalizable.tr("Localizable", "transaction_receipt.date_time", fallback: "Date and Time")
    /// Fee
    public static let fee = LFLocalizable.tr("Localizable", "transaction_receipt.fee", fallback: "Fee")
    /// One time donation
    public static let oneTimeDonation = LFLocalizable.tr("Localizable", "transaction_receipt.one_time_donation", fallback: "One time donation")
    /// Order Type
    public static let orderType = LFLocalizable.tr("Localizable", "transaction_receipt.order_type", fallback: "Order Type")
    /// Price
    public static let price = LFLocalizable.tr("Localizable", "transaction_receipt.price", fallback: "Price")
    /// Quantity
    public static let quantity = LFLocalizable.tr("Localizable", "transaction_receipt.quantity", fallback: "Quantity")
    /// Rewards donation
    public static let rewardsDonation = LFLocalizable.tr("Localizable", "transaction_receipt.rewards_donation", fallback: "Rewards donation")
    /// Round up donation
    public static let roundUpDonation = LFLocalizable.tr("Localizable", "transaction_receipt.round_up_donation", fallback: "Round up donation")
    /// Tax deductible donation
    public static let taxDeductibleDonation = LFLocalizable.tr("Localizable", "transaction_receipt.tax_deductible_donation", fallback: "Tax deductible donation")
    /// Trading Pair
    public static let tradingPair = LFLocalizable.tr("Localizable", "transaction_receipt.trading_pair", fallback: "Trading Pair")
    /// Transaction number
    public static let transactionId = LFLocalizable.tr("Localizable", "transaction_receipt.transaction_id", fallback: "Transaction number")
    /// Transaction value
    public static let transactionValue = LFLocalizable.tr("Localizable", "transaction_receipt.transaction_value", fallback: "Transaction value")
  }
  public enum TransactionRewardsStatus {
    /// Completed
    public static let completed = LFLocalizable.tr("Localizable", "transaction_rewards_status.completed", fallback: "Completed")
    /// Pending
    public static let pending = LFLocalizable.tr("Localizable", "transaction_rewards_status.pending", fallback: "Pending")
  }
  public enum TransactionRow {
    /// Pending
    public static let pending = LFLocalizable.tr("Localizable", "transaction_row.pending", fallback: "Pending")
    public enum FundraiserDonation {
      /// Donation
      public static let generic = LFLocalizable.tr("Localizable", "transaction_row.fundraiser_donation.generic", fallback: "Donation")
      /// Donation by %@
      public static func user(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transaction_row.fundraiser_donation.user", String(describing: p1), fallback: "Donation by %@")
      }
    }
  }
  public enum Transactions {
    /// Transactions
    public static let title = LFLocalizable.tr("Localizable", "transactions.title", fallback: "Transactions")
  }
  public enum Transfer {
    /// Checking **** %@
    public static func checking(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transfer.checking", String(describing: p1), fallback: "Checking **** %@")
    }
    /// Deposit
    public static let credit = LFLocalizable.tr("Localizable", "transfer.credit", fallback: "Deposit")
    /// Deposit completed
    public static let creditCompleted = LFLocalizable.tr("Localizable", "transfer.credit_completed", fallback: "Deposit completed")
    /// Deposit started
    public static let creditStarted = LFLocalizable.tr("Localizable", "transfer.credit_started", fallback: "Deposit started")
    /// Withdraw
    public static let debit = LFLocalizable.tr("Localizable", "transfer.debit", fallback: "Withdraw")
    /// Debit Card **** %@
    public static func debitCard(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transfer.debit_card", String(describing: p1), fallback: "Debit Card **** %@")
    }
    /// Withdraw completed
    public static let debitCompleted = LFLocalizable.tr("Localizable", "transfer.debit_completed", fallback: "Withdraw completed")
    /// Withdraw started
    public static let debitStarted = LFLocalizable.tr("Localizable", "transfer.debit_started", fallback: "Withdraw started")
    /// Limits reached
    public static let limitsReached = LFLocalizable.tr("Localizable", "transfer.limits_reached", fallback: "Limits reached")
    /// Savings **** %@
    public static func saving(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "transfer.saving", String(describing: p1), fallback: "Savings **** %@")
    }
    public enum WithdrawAnnotation {
      /// You currently have %@ available to withdraw. Rewards are not available to withdraw until 48 hours after they are earned.
      public static func description(_ p1: Any) -> String {
        return LFLocalizable.tr("Localizable", "transfer.withdraw_annotation.description", String(describing: p1), fallback: "You currently have %@ available to withdraw. Rewards are not available to withdraw until 48 hours after they are earned.")
      }
    }
  }
  public enum TransferDebitSuggestion {
    /// For instant deposits, connect and deposit with your Debit Card
    public static let body = LFLocalizable.tr("Localizable", "transfer_debit_suggestion.body", fallback: "For instant deposits, connect and deposit with your Debit Card")
    /// Connect Debit Card
    public static let connect = LFLocalizable.tr("Localizable", "transfer_debit_suggestion.connect", fallback: "Connect Debit Card")
    /// Get Faster Deposits
    public static let title = LFLocalizable.tr("Localizable", "transfer_debit_suggestion.title", fallback: "Get Faster Deposits")
  }
  public enum TransferStatus {
    public enum Deposit {
      /// Deposit completed
      public static let completed = LFLocalizable.tr("Localizable", "transfer_status.deposit.completed", fallback: "Deposit completed")
      /// Deposit started
      public static let started = LFLocalizable.tr("Localizable", "transfer_status.deposit.started", fallback: "Deposit started")
    }
    public enum Reward {
      /// Reward completed
      public static let completed = LFLocalizable.tr("Localizable", "transfer_status.reward.completed", fallback: "Reward completed")
      /// Reward pending
      public static let started = LFLocalizable.tr("Localizable", "transfer_status.reward.started", fallback: "Reward pending")
    }
    public enum Withdraw {
      /// Withdraw completed
      public static let completed = LFLocalizable.tr("Localizable", "transfer_status.withdraw.completed", fallback: "Withdraw completed")
      /// Withdraw started
      public static let started = LFLocalizable.tr("Localizable", "transfer_status.withdraw.started", fallback: "Withdraw started")
    }
  }
  public enum UnspecifiedRewards {
    /// Select a reward
    public static let cta = LFLocalizable.tr("Localizable", "unspecified_rewards.cta", fallback: "Select a reward")
    /// You can choose between
    public static let title = LFLocalizable.tr("Localizable", "unspecified_rewards.title", fallback: "You can choose between")
  }
  public enum UpdateApp {
    /// You’re on an older version of the %@ app. Please update to the latest version.
    public static func message(_ p1: Any) -> String {
      return LFLocalizable.tr("Localizable", "update_app.message", String(describing: p1), fallback: "You’re on an older version of the %@ app. Please update to the latest version.")
    }
    /// UPDATE APP
    public static let title = LFLocalizable.tr("Localizable", "update_app.title", fallback: "UPDATE APP")
  }
  public enum UserRewardType {
    public enum Cashback {
      /// 0.75% on every qualifying purchase
      public static func subtitle(_ p1: Int) -> String {
        return LFLocalizable.tr("Localizable", "user_reward_type.cashback.subtitle", p1, fallback: "0.75% on every qualifying purchase")
      }
      /// Instant Cashback
      public static let title = LFLocalizable.tr("Localizable", "user_reward_type.cashback.title", fallback: "Instant Cashback")
    }
    public enum Donation {
      /// 0.75% donated to a charity you choose
      public static func subtitle(_ p1: Int) -> String {
        return LFLocalizable.tr("Localizable", "user_reward_type.donation.subtitle", p1, fallback: "0.75% donated to a charity you choose")
      }
      /// Donate to Charity
      public static let title = LFLocalizable.tr("Localizable", "user_reward_type.donation.title", fallback: "Donate to Charity")
    }
  }
  public enum Welcome {
    /// Explore App
    public static let exploreApp = LFLocalizable.tr("Localizable", "welcome.explore_app", fallback: "Explore App")
    /// HOW IT WORKS:
    public static let howItWorks = LFLocalizable.tr("Localizable", "welcome.how_it_works", fallback: "HOW IT WORKS:")
    /// Create a AvalancheCard account
    public static let item1 = LFLocalizable.tr("Localizable", "welcome.item1", fallback: "Create a AvalancheCard account")
    /// Use your AvalancheCard for everyday purchases
    public static let item2 = LFLocalizable.tr("Localizable", "welcome.item2", fallback: "Use your AvalancheCard for everyday purchases")
    /// Give more by rounding up your purchases.
    public static let item3 = LFLocalizable.tr("Localizable", "welcome.item3", fallback: "Give more by rounding up your purchases.")
    /// Continue
    public static let orderCard = LFLocalizable.tr("Localizable", "welcome.order_card", fallback: "Continue")
    /// The AvalancheCard is an easy way to earn Avalanche with everyday purchases.  You can also buy, sell and spend Avalanche with the AvalancheCard app.
    public static let subtitle = LFLocalizable.tr("Localizable", "welcome.subtitle", fallback: "The AvalancheCard is an easy way to earn Avalanche with everyday purchases.  You can also buy, sell and spend Avalanche with the AvalancheCard app.")
    /// Welcome!
    public static let title = LFLocalizable.tr("Localizable", "welcome.title", fallback: "Welcome!")
  }
  public enum WireTransfers {
    /// Account Name:
    public static let accountName = LFLocalizable.tr("Localizable", "wire_transfers.account_name", fallback: "Account Name:")
    /// Account Number:
    public static let accountNumber = LFLocalizable.tr("Localizable", "wire_transfers.account_number", fallback: "Account Number:")
    /// Account Type
    public static let accountType = LFLocalizable.tr("Localizable", "wire_transfers.account_type", fallback: "Account Type")
    /// Bank Address:
    public static let bankAddress = LFLocalizable.tr("Localizable", "wire_transfers.bank_address", fallback: "Bank Address:")
    /// Bank Name:
    public static let bankName = LFLocalizable.tr("Localizable", "wire_transfers.bank_name", fallback: "Bank Name:")
    /// Routing Number:
    public static let routingNumber = LFLocalizable.tr("Localizable", "wire_transfers.routing_number", fallback: "Routing Number:")
    /// WIRE TRANSFERS
    public static let title = LFLocalizable.tr("Localizable", "wire_transfers.title", fallback: "WIRE TRANSFERS")
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
