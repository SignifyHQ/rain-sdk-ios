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
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum ModuleImages {
  internal static let icCharityStar = ImageAsset(name: "Ic_charityStar")
  internal static let icDownload = ImageAsset(name: "Ic_download")
  internal enum NewUser {
    internal static let accountActivated = ImageAsset(name: "accountActivated")
    internal static let fundCard = ImageAsset(name: "fundCard")
    internal static let roundUp = ImageAsset(name: "roundUp")
  }
  internal enum RoundUps {
    internal static let roundUpsCard = ImageAsset(name: "roundUpsCard")
    internal static let roundUpsCause = ImageAsset(name: "roundUpsCause")
    internal static let roundUpsCycle = ImageAsset(name: "roundUpsCycle")
  }
  internal enum Share {
    internal static let shareEmail = ImageAsset(name: "shareEmail")
    internal static let shareFacebook = ImageAsset(name: "shareFacebook")
    internal static let shareInstagram = ImageAsset(name: "shareInstagram")
    internal static let shareLink = ImageAsset(name: "shareLink")
    internal static let shareMessages = ImageAsset(name: "shareMessages")
    internal static let shareSnapchat = ImageAsset(name: "shareSnapchat")
    internal static let shareTikTok = ImageAsset(name: "shareTikTok")
    internal static let shareTwitter = ImageAsset(name: "shareTwitter")
    internal static let shareWhatsapp = ImageAsset(name: "shareWhatsapp")
  }
  internal static let bgCashbackCard = ImageAsset(name: "bg_cashbackCard")
  internal static let bgHeaderSelectReward = ImageAsset(name: "bg_header_select_reward")
  internal static let icAddress = ImageAsset(name: "ic_address")
  internal static let icCharityStatus = ImageAsset(name: "ic_charity_status")
  internal static let icDonate = ImageAsset(name: "ic_donate")
  internal static let icEin = ImageAsset(name: "ic_ein")
  internal static let icMore = ImageAsset(name: "ic_more")
  internal static let icNavigation = ImageAsset(name: "ic_navigation")
  internal static let icReferrals = ImageAsset(name: "ic_referrals")
  internal static let icRewardsCashback = ImageAsset(name: "ic_rewards_cashback")
  internal static let icRewardsDonation = ImageAsset(name: "ic_rewards_donation")
  internal static let icShared = ImageAsset(name: "ic_shared")
  internal static let icUsdSymbol = ImageAsset(name: "ic_usd_symbol")
  internal static let icWebsite = ImageAsset(name: "ic_website")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
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
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
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
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
