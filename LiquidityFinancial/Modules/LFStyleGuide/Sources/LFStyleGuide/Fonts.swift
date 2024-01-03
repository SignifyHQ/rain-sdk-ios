// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit.NSFont
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIFont
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "FontConvertible.Font", message: "This typealias will be removed in SwiftGen 7.0")
public typealias Font = FontConvertible.Font

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Fonts

// swiftlint:disable identifier_name line_length type_body_length
public enum Fonts {
  
  static var cardanoFont: Bool {
    LFStyleGuide.target == .Cardano ? true : false
  }
  
  static var montserratFont: Bool {
    LFStyleGuide.target == .DogeCard || LFStyleGuide.target == .DogeCardNobank || LFStyleGuide.target == .CauseCard
  }
  
  static var orbitroFont: Bool {
    LFStyleGuide.target == .DogeCard || LFStyleGuide.target == .DogeCardNobank || LFStyleGuide.target == .CauseCard
  }
  
  public static var black: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.black
    case .Cardano: return Chivo.black
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.black
    default : return Inter.black
    }
  }
  public static var bold: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.bold
    case .Cardano: return Chivo.bold
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.bold
    default : return Inter.bold
    }
  }
  public static var extraBold: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.extraBold
    case .Cardano: return Chivo.extraBold
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.bold
    default : return Inter.extraBold
    }
  }
  public static var extraLight: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.extraLight
    case .Cardano: return Chivo.extraLight
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.light
    default : return Inter.extraLight
    }
  }
  public static var light: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.light
    case .Cardano: return Chivo.light
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.light
    default : return Inter.light
    }
  }
  public static var medium: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.medium
    case .Cardano: return Chivo.medium
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.medium
    default : return Inter.medium
    }
  }
  public static var regular: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.regular
    case .Cardano: return Chivo.regular
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.regular
    default : return Lato.regular
    }
  }
  public static var semiBold: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.semiBold
    case .Cardano: return Chivo.semiBold
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.bold
    default : return Inter.semiBold
    }
  }
  public static var thin: FontConvertible {
    switch LFStyleGuide.target {
    case .Avalanche: return Inter.thin
    case .Cardano: return Chivo.thin
    case .DogeCard, .DogeCardNobank, .CauseCard, .PrideCard, .PawsCard: return Lato.light
    default : return Inter.thin
    }
  }
  
  /// This is font just active for Cardano App
  /// so should call it on correct the located.
  public static var blackItalic: FontConvertible {
    if cardanoFont {
      return FontConvertible(name: "Chivo-BlackItalic", family: "Chivo", path: "Chivo-BlackItalic.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var boldItalic: FontConvertible {
    if cardanoFont {
      return FontConvertible(name: "Chivo-BoldItalic", family: "Chivo", path: "Chivo-BoldItalic.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var extraBoldItalic: FontConvertible {
    if cardanoFont {
      return FontConvertible(name: "Chivo-ExtraBoldItalic", family: "Chivo", path: "Chivo-ExtraBoldItalic.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var extraLightItalic: FontConvertible {
    if cardanoFont {
      return FontConvertible(name: "Chivo-ExtraLightItalic", family: "Chivo", path: "Chivo-ExtraLightItalic.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var lightItalic: FontConvertible {
    if cardanoFont {
      return FontConvertible(name: "Chivo-LightItalic", family: "Chivo", path: "Chivo-LightItalic.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var mediumItalic: FontConvertible {
    if cardanoFont {
      return FontConvertible(name: "Chivo-MediumItalic", family: "Chivo", path: "Chivo-MediumItalic.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var semiBoldItalic: FontConvertible {
    if cardanoFont {
      return FontConvertible(name: "Chivo-SemiBoldItalic", family: "Chivo", path: "Chivo-SemiBoldItalic.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var thinItalic: FontConvertible {
    if cardanoFont {
      return FontConvertible(name: "Chivo-ThinItalic", family: "Chivo", path: "Chivo-ThinItalic.ttf")
    }
    fatalError("The target not support the font.")
  }
  
  public static var montserratBlack: FontConvertible {
    if montserratFont {
      return FontConvertible(name: "Montserrat-Black", family: "Montserrat", path: "Montserrat-Black.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var montserratMedium: FontConvertible {
    if montserratFont {
      return FontConvertible(name: "Montserrat-Medium", family: "Montserrat", path: "Montserrat-Medium.ttf")
    }
    fatalError("The target not support the font.")
  }
  public static var orbitronBold: FontConvertible {
    return FontConvertible(name: "Orbitron-Bold", family: "Orbitron", path: "Orbitron-Bold.ttf")
  }
  public static var orbitronMedium: FontConvertible {
    return FontConvertible(name: "Orbitron-Medium", family: "Orbitron", path: "Orbitron-Medium.ttf")
  }
  
  public enum Chivo {
    public static let black = FontConvertible(name: "Chivo-Black", family: "Chivo", path: "Chivo-Black.ttf")
    public static let blackItalic = FontConvertible(name: "Chivo-BlackItalic", family: "Chivo", path: "Chivo-BlackItalic.ttf")
    public static let bold = FontConvertible(name: "Chivo-Bold", family: "Chivo", path: "Chivo-Bold.ttf")
    public static let boldItalic = FontConvertible(name: "Chivo-BoldItalic", family: "Chivo", path: "Chivo-BoldItalic.ttf")
    public static let extraBold = FontConvertible(name: "Chivo-ExtraBold", family: "Chivo", path: "Chivo-ExtraBold.ttf")
    public static let extraBoldItalic = FontConvertible(name: "Chivo-ExtraBoldItalic", family: "Chivo", path: "Chivo-ExtraBoldItalic.ttf")
    public static let extraLight = FontConvertible(name: "Chivo-ExtraLight", family: "Chivo", path: "Chivo-ExtraLight.ttf")
    public static let extraLightItalic = FontConvertible(name: "Chivo-ExtraLightItalic", family: "Chivo", path: "Chivo-ExtraLightItalic.ttf")
    public static let italic = FontConvertible(name: "Chivo-Italic", family: "Chivo", path: "Chivo-Italic.ttf")
    public static let light = FontConvertible(name: "Chivo-Light", family: "Chivo", path: "Chivo-Light.ttf")
    public static let lightItalic = FontConvertible(name: "Chivo-LightItalic", family: "Chivo", path: "Chivo-LightItalic.ttf")
    public static let medium = FontConvertible(name: "Chivo-Medium", family: "Chivo", path: "Chivo-Medium.ttf")
    public static let mediumItalic = FontConvertible(name: "Chivo-MediumItalic", family: "Chivo", path: "Chivo-MediumItalic.ttf")
    public static let regular = FontConvertible(name: "Chivo-Regular", family: "Chivo", path: "Chivo-Regular.ttf")
    public static let semiBold = FontConvertible(name: "Chivo-SemiBold", family: "Chivo", path: "Chivo-SemiBold.ttf")
    public static let semiBoldItalic = FontConvertible(name: "Chivo-SemiBoldItalic", family: "Chivo", path: "Chivo-SemiBoldItalic.ttf")
    public static let thin = FontConvertible(name: "Chivo-Thin", family: "Chivo", path: "Chivo-Thin.ttf")
    public static let thinItalic = FontConvertible(name: "Chivo-ThinItalic", family: "Chivo", path: "Chivo-ThinItalic.ttf")
    public static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, extraBold, extraBoldItalic, extraLight, extraLightItalic, italic, light, lightItalic, medium, mediumItalic, regular, semiBold, semiBoldItalic, thin, thinItalic]
  }
  public enum Inter {
    public static let black = FontConvertible(name: "Inter-Black", family: "Inter", path: "Inter-Black.ttf")
    public static let bold = FontConvertible(name: "Inter-Bold", family: "Inter", path: "Inter-Bold.ttf")
    public static let extraBold = FontConvertible(name: "Inter-ExtraBold", family: "Inter", path: "Inter-ExtraBold.ttf")
    public static let extraLight = FontConvertible(name: "Inter-ExtraLight", family: "Inter", path: "Inter-ExtraLight.ttf")
    public static let light = FontConvertible(name: "Inter-Light", family: "Inter", path: "Inter-Light.ttf")
    public static let medium = FontConvertible(name: "Inter-Medium", family: "Inter", path: "Inter-Medium.ttf")
    public static let regular = FontConvertible(name: "Inter-Regular", family: "Inter", path: "Inter-Regular.ttf")
    public static let semiBold = FontConvertible(name: "Inter-SemiBold", family: "Inter", path: "Inter-SemiBold.ttf")
    public static let thin = FontConvertible(name: "Inter-Thin", family: "Inter", path: "Inter-Thin.ttf")
    public static let all: [FontConvertible] = [black, bold, extraBold, extraLight, light, medium, regular, semiBold, thin]
  }
  public enum Lato {
    public static let black = FontConvertible(name: "Lato-Black", family: "Lato", path: "Lato-Black.ttf")
    public static let blackItalic = FontConvertible(name: "Lato-BlackItalic", family: "Lato", path: "Lato-BlackItalic.ttf")
    public static let bold = FontConvertible(name: "Lato-Bold", family: "Lato", path: "Lato-Bold.ttf")
    public static let boldItalic = FontConvertible(name: "Lato-BoldItalic", family: "Lato", path: "Lato-BoldItalic.ttf")
    public static let hairline = FontConvertible(name: "Lato-Hairline", family: "Lato", path: "Lato-Thin.ttf")
    public static let hairlineItalic = FontConvertible(name: "Lato-HairlineItalic", family: "Lato", path: "Lato-ThinItalic.ttf")
    public static let italic = FontConvertible(name: "Lato-Italic", family: "Lato", path: "Lato-Italic.ttf")
    public static let light = FontConvertible(name: "Lato-Light", family: "Lato", path: "Lato-Light.ttf")
    public static let lightItalic = FontConvertible(name: "Lato-LightItalic", family: "Lato", path: "Lato-LightItalic.ttf")
    public static let medium = FontConvertible(name: "Lato-Medium", family: "Lato", path: "Lato-Medium.ttf")
    public static let mediumItalic = FontConvertible(name: "Lato-MediumItalic", family: "Lato", path: "Lato-MediumItalic.ttf")
    public static let regular = FontConvertible(name: "Lato-Regular", family: "Lato", path: "Lato-Regular.ttf")
    public static let all: [FontConvertible] = [black, blackItalic, bold, boldItalic, hairline, hairlineItalic, italic, light, lightItalic, medium, mediumItalic, regular]
  }
  public enum Montserrat {
    public static let black = FontConvertible(name: "Montserrat-Black", family: "Montserrat", path: "Montserrat-Black.ttf")
    public static let medium = FontConvertible(name: "Montserrat-Medium", family: "Montserrat", path: "Montserrat-Medium.ttf")
    public static let all: [FontConvertible] = [black, medium]
  }
  public enum Orbitron {
    public static let bold = FontConvertible(name: "Orbitron-Bold", family: "Orbitron", path: "Orbitron-Bold.ttf")
    public static let medium = FontConvertible(name: "Orbitron-Medium", family: "Orbitron", path: "Orbitron-Medium.ttf")
    public static let all: [FontConvertible] = [bold, medium]
  }

  public static func registerAllCustomFonts() {
    var allCustomFonts: [FontConvertible] = []
    switch LFStyleGuide.target {
    case .Avalanche:
      allCustomFonts.append(contentsOf: Inter.all + Orbitron.all)
    case .Cardano:
      allCustomFonts.append(contentsOf: Chivo.all + Orbitron.all)
    case .DogeCard, .CauseCard, .PrideCard:
      allCustomFonts.append(contentsOf: Lato.all + Montserrat.all + Orbitron.all)
    default :
      allCustomFonts.append(contentsOf: Inter.all + Orbitron.all)
    }
    allCustomFonts.forEach { $0.register() }
  }
}
// swiftlint:enable identifier_name line_length type_body_length

// MARK: - Implementation Details

public struct FontConvertible {
  public let name: String
  public let family: String
  public let path: String

  #if os(macOS)
  public typealias Font = NSFont
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Font = UIFont
  #endif

  public func font(size: CGFloat) -> Font {
    guard let font = Font(font: self, size: size) else {
      fatalError("Unable to initialize font '\(name)' (\(family))")
    }
    return font
  }

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public func swiftUIFont(size: CGFloat) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, size: size)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  public func swiftUIFont(fixedSize: CGFloat) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, fixedSize: fixedSize)
  }

  @available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
  public func swiftUIFont(size: CGFloat, relativeTo textStyle: SwiftUI.Font.TextStyle) -> SwiftUI.Font {
    return SwiftUI.Font.custom(self, size: size, relativeTo: textStyle)
  }
  #endif

  public func register() {
    // swiftlint:disable:next conditional_returns_on_newline
    guard let url = url else { return }
    CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
  }

  fileprivate func registerIfNeeded() {
    #if os(iOS) || os(tvOS) || os(watchOS)
    if !UIFont.fontNames(forFamilyName: family).contains(name) {
      register()
    }
    #elseif os(macOS)
    if let url = url, CTFontManagerGetScopeForURL(url as CFURL) == .none {
      register()
    }
    #endif
  }

  fileprivate var url: URL? {
    // swiftlint:disable:next implicit_return
    return Bundle.main.url(forResource: path, withExtension: nil)
  }
}

public extension FontConvertible.Font {
  convenience init?(font: FontConvertible, size: CGFloat) {
    font.registerIfNeeded()
    self.init(name: font.name, size: size)
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Font {
  static func custom(_ font: FontConvertible, size: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, size: size)
  }
}

@available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, *)
public extension SwiftUI.Font {
  static func custom(_ font: FontConvertible, fixedSize: CGFloat) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, fixedSize: fixedSize)
  }

  static func custom(
    _ font: FontConvertible,
    size: CGFloat,
    relativeTo textStyle: SwiftUI.Font.TextStyle
  ) -> SwiftUI.Font {
    font.registerIfNeeded()
    return custom(font.name, size: size, relativeTo: textStyle)
  }
}
#endif
