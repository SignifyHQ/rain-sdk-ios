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
public enum GenImages {
  public enum CommonImages {
    public static let zerohash = ImageAsset(name: "Zerohash")
    public static let calendar = ImageAsset(name: "calendar")
    public static let checkmark = ImageAsset(name: "checkmark")
    public static let dash = ImageAsset(name: "dash")
    public static let icAccount = ImageAsset(name: "ic_account")
    public static let icAssets = ImageAsset(name: "ic_assets")
    public static let icAvax = ImageAsset(name: "ic_avax")
    public static let icBack = ImageAsset(name: "ic_back")
    public static let icCash = ImageAsset(name: "ic_cash")
    public static let icChat = ImageAsset(name: "ic_chat")
    public static let icCopy = ImageAsset(name: "ic_copy")
    public static let icDeals = ImageAsset(name: "ic_deals")
    public static let icDocument = ImageAsset(name: "ic_document")
    public static let icError = ImageAsset(name: "ic_error")
    public static let icGear = ImageAsset(name: "ic_gear")
    public static let icHome = ImageAsset(name: "ic_home")
    public static let icLock = ImageAsset(name: "ic_lock")
    public static let icProfile = ImageAsset(name: "ic_profile")
    public static let icRewards = ImageAsset(name: "ic_rewards")
    public static let icRightArrow = ImageAsset(name: "ic_rightArrow")
    public static let icSearch = ImageAsset(name: "ic_search")
    public static let icTicketCircle = ImageAsset(name: "ic_ticketCircle")
    public static let icTrash = ImageAsset(name: "ic_trash")
    public static let icUsd = ImageAsset(name: "ic_usd")
    public static let icUsdc = ImageAsset(name: "ic_usdc")
    public static let icWellcome1 = ImageAsset(name: "ic_wellcome_1")
    public static let icWellcome2 = ImageAsset(name: "ic_wellcome_2")
    public static let icWellcome3 = ImageAsset(name: "ic_wellcome_3")
    public static let icXMark = ImageAsset(name: "ic_xMark")
    public static let icXError = ImageAsset(name: "ic_x_error")
    public static let info = ImageAsset(name: "info")
    public static let map = ImageAsset(name: "map")
    public static let netspend = ImageAsset(name: "netspend")
    public static let netspendLogo = ImageAsset(name: "netspend_logo")
    public static let rewardsCashback = ImageAsset(name: "rewardsCashback")
    public static let rewardsDonation = ImageAsset(name: "rewardsDonation")
    public static let termsCheckboxDeselected = ImageAsset(name: "termsCheckboxDeselected")
    public static let termsCheckboxSelected = ImageAsset(name: "termsCheckboxSelected")
    public static let usdSymbol = ImageAsset(name: "usdSymbol")
  }
  public enum Images {
    public static let availableCard = ImageAsset(name: "availableCard")
    public static let connectedAppleWallet = ImageAsset(name: "connectedAppleWallet")
    public static let emptyCard = ImageAsset(name: "emptyCard")
    public static let icKycQuestion = ImageAsset(name: "ic_kyc_question_?")
    public static let icKycQuestionCheck = ImageAsset(name: "ic_kyc_question_check")
    public static let icLogo = ImageAsset(name: "ic_logo")
    public static let physicalCard = ImageAsset(name: "physicalCard")
    public static let statusCompleted = ImageAsset(name: "statusCompleted")
    public static let statusPending = ImageAsset(name: "statusPending")
    public static let unavailableCard = ImageAsset(name: "unavailableCard")
    public static let virtualCard = ImageAsset(name: "virtualCard")
  }
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
