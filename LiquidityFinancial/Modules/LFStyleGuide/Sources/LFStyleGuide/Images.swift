// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Images {
  public enum Accounts {
    public static let bankStatements = ImageAsset(name: "bankStatements")
    public static let bankTransfers = ImageAsset(name: "bankTransfers")
    public static let connectedAccounts = ImageAsset(name: "connectedAccounts")
    public static let debitDeposit = ImageAsset(name: "debitDeposit")
    public static let directDeposit = ImageAsset(name: "directDeposit")
    public static let limits = ImageAsset(name: "limits")
    public static let oneTime = ImageAsset(name: "oneTime")
    public static let verification = ImageAsset(name: "verification")
    public static let walletAddress = ImageAsset(name: "walletAddress")
  }
  public enum Charity {
    public static let charityAddress = ImageAsset(name: "charityAddress")
    public static let charityEin = ImageAsset(name: "charityEin")
    public static let charityNavigator = ImageAsset(name: "charityNavigator")
    public static let charityStar = ImageAsset(name: "charityStar")
    public static let charityStatus = ImageAsset(name: "charityStatus")
    public static let charityWeb = ImageAsset(name: "charityWeb")
  }
  public enum Common {
    public static let barcodeShare = ImageAsset(name: "barcode_share")
    public static let chat = ImageAsset(name: "chat")
    public static let dash = ImageAsset(name: "dash")
    public static let errorWarning = ImageAsset(name: "errorWarning")
    public static let gear = ImageAsset(name: "gear")
    public static let line = ImageAsset(name: "line")
    public static let lock = ImageAsset(name: "lock")
    public static let receipt = ImageAsset(name: "receipt")
    public static let rightArrowSmall = ImageAsset(name: "rightArrowSmall")
    public static let termsCheckboxSelected = ImageAsset(name: "termsCheckboxSelected")
    public static let termsCheckboxDeselected = ImageAsset(name: "termsCheckbox_deselected")
    public static let tickCircle = ImageAsset(name: "tickCircle")
    public static let upArrowCircle = ImageAsset(name: "upArrowCircle")
    public static let xMark = ImageAsset(name: "xMark")
  }
  public static let deleteIconBlue = ImageAsset(name: "Delete_icon_Blue")
  public enum Home {
    public static let tabAccount = ImageAsset(name: "tabAccount")
    public static let tabCash = ImageAsset(name: "tabCash")
    public static let tabCauses = ImageAsset(name: "tabCauses")
    public static let tabCrypto = ImageAsset(name: "tabCrypto")
    public static let tabRewards = ImageAsset(name: "tabRewards")
  }
  public enum NewUser {
    public static let accountActivated = ImageAsset(name: "accountActivated")
    public static let fundCard = ImageAsset(name: "fundCard")
    public static let roundUp = ImageAsset(name: "roundUp")
  }
  public enum Profile {
    public static let address = ImageAsset(name: "address")
    public static let atm = ImageAsset(name: "atm")
    public static let email = ImageAsset(name: "email")
    public static let help = ImageAsset(name: "help")
    public static let legal = ImageAsset(name: "legal")
    public static let notifications = ImageAsset(name: "notifications")
    public static let phone = ImageAsset(name: "phone")
    public static let profile = ImageAsset(name: "profile")
    public static let rewards = ImageAsset(name: "rewards")
    public static let search = ImageAsset(name: "search")
    public static let taxes = ImageAsset(name: "taxes")
  }
  public enum Rewards {
    public static let rewardsCashback = ImageAsset(name: "rewardsCashback")
    public static let rewardsDonation = ImageAsset(name: "rewardsDonation")
  }
  public enum Share {
    public static let shareEmail = ImageAsset(name: "shareEmail")
    public static let shareFacebook = ImageAsset(name: "shareFacebook")
    public static let shareInstagram = ImageAsset(name: "shareInstagram")
    public static let shareLink = ImageAsset(name: "shareLink")
    public static let shareMessages = ImageAsset(name: "shareMessages")
    public static let shareSnapchat = ImageAsset(name: "shareSnapchat")
    public static let shareTikTok = ImageAsset(name: "shareTikTok")
    public static let shareTwitter = ImageAsset(name: "shareTwitter")
    public static let shareWhatsapp = ImageAsset(name: "shareWhatsapp")
  }
  public enum Social {
    public static let facebook = ImageAsset(name: "facebook")
    public static let instagram = ImageAsset(name: "instagram")
    public static let twitter = ImageAsset(name: "twitter")
  }
  public enum Transactions {
    public static let txCardPurchase = ImageAsset(name: "txCardPurchase")
    public static let txCardRefund = ImageAsset(name: "txCardRefund")
    public static let txCashDeposit = ImageAsset(name: "txCashDeposit")
    public static let txCashWithdrawal = ImageAsset(name: "txCashWithdrawal")
    public static let txCashback = ImageAsset(name: "txCashback")
    public static let txDonation = ImageAsset(name: "txDonation")
    public static let txFees = ImageAsset(name: "txFees")
    public static let txOther = ImageAsset(name: "txOther")
  }
  public enum Welcome {
    public static let welcome1 = ImageAsset(name: "welcome1")
    public static let welcome2 = ImageAsset(name: "welcome2")
    public static let welcome3 = ImageAsset(name: "welcome3")
  }
  public static let zerohash = ImageAsset(name: "Zerohash")
  public static let accountNumber = ImageAsset(name: "accountNumber")
  public static let activateSuccessCard = ImageAsset(name: "activateSuccessCard")
  public static let add = ImageAsset(name: "add")
  public static let addMoney = ImageAsset(name: "addMoney")
  public static let addToAppleWallet = ImageAsset(name: "addToAppleWallet")
  public static let adminMenu = ImageAsset(name: "admin.menu")
  public static let appleWallet = ImageAsset(name: "appleWallet")
  public static let backButton = ImageAsset(name: "backButton")
  public static let bolt = ImageAsset(name: "bolt")
  public static let buy = ImageAsset(name: "buy")
  public static let calendar = ImageAsset(name: "calendar")
  public static let cameraIcon = ImageAsset(name: "camera_icon")
  public static let card = ImageAsset(name: "card")
  public static let cardAvailable = ImageAsset(name: "cardAvailable")
  public static let cardDetails = ImageAsset(name: "cardDetails")
  public static let cardUnavailable = ImageAsset(name: "cardUnavailable")
  public static let cashbackCard = ImageAsset(name: "cashbackCard")
  public static let checkboxSelected = ImageAsset(name: "checkboxSelected")
  public static let checkboxUnselected = ImageAsset(name: "checkboxUnselected")
  public static let copy = ImageAsset(name: "copy")
  public static let copyBackground = ImageAsset(name: "copyBackground")
  public static let copyFill = ImageAsset(name: "copyFill")
  public static let currentLocation = ImageAsset(name: "current.location")
  public static let deals = ImageAsset(name: "deals")
  public enum DirectDepostLogos {
    public static let companyIcon1 = ImageAsset(name: "company-icon-1")
    public static let companyIcon2 = ImageAsset(name: "company-icon-2")
    public static let companyIcon3 = ImageAsset(name: "company-icon-3")
    public static let companyIcon4 = ImageAsset(name: "company-icon-4")
    public static let companyIcon5 = ImageAsset(name: "company-icon-5")
    public static let companyIcon6 = ImageAsset(name: "company-icon-6")
  }
  public static let donateAction = ImageAsset(name: "donateAction")
  public static let donation = ImageAsset(name: "donation")
  public static let download = ImageAsset(name: "download")
  public static let drivelicense = ImageAsset(name: "drivelicense")
  public static let edit = ImageAsset(name: "edit")
  public static let emptyCardCash = ImageAsset(name: "emptyCardCash")
  public static let emptyList = ImageAsset(name: "emptyList")
  public static let error = ImageAsset(name: "error")
  public static let flashOffCircle = ImageAsset(name: "flashOffCircle")
  public static let flashOnCircle = ImageAsset(name: "flashOnCircle")
  public static let home = ImageAsset(name: "home")
  public static let icChat = ImageAsset(name: "ic_chat")
  public static let icError = ImageAsset(name: "ic_error")
  public static let icLogo = ImageAsset(name: "ic_logo")
  public static let icPaperplaneFill = ImageAsset(name: "ic_paperplane.fill")
  public static let info = ImageAsset(name: "info")
  public static let logo = ImageAsset(name: "logo")
  public static let loveHandshake = ImageAsset(name: "loveHandshake")
  public static let map = ImageAsset(name: "map")
  public static let mapAnnotation = ImageAsset(name: "mapAnnotation")
  public static let personAndBackgroundDotted = ImageAsset(name: "person.and.background.dotted")
  public static let referrals = ImageAsset(name: "referrals")
  public static let referralsInbox = ImageAsset(name: "referralsInbox")
  public static let routingNumber = ImageAsset(name: "routingNumber")
  public static let scanDebitCardPhoto = ImageAsset(name: "scan.debit.card.photo")
  public static let selectFundraiser = ImageAsset(name: "selectFundraiser")
  public static let selectRewards = ImageAsset(name: "selectRewards")
  public static let sell = ImageAsset(name: "sell")
  public static let sendMoney = ImageAsset(name: "sendMoney")
  public static let shareAction = ImageAsset(name: "shareAction")
  public static let shield = ImageAsset(name: "shield")
  public static let ssn = ImageAsset(name: "ssn")
  public static let statusCompleted = ImageAsset(name: "statusCompleted")
  public static let statusPending = ImageAsset(name: "statusPending")
  public static let stickerPlaceholder = ImageAsset(name: "stickerPlaceholder")
  public static let transfer = ImageAsset(name: "transfer")
  public static let trash = ImageAsset(name: "trash")
  public static let unspecifiedRewards = ImageAsset(name: "unspecifiedRewards")
  public static let usdSymbol = ImageAsset(name: "usdSymbol")
  public static let userPlaceholder = ImageAsset(name: "userPlaceholder")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = Bundle.main
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = Bundle.main
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle.main
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = Bundle.main
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = Bundle.main
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = Bundle.main
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif
