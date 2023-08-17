import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct ShoppingGivesAlert: View {
  let type: Kind
  @Environment(\.openURL) private var openURL
  
  var body: some View {
    TextTappable(attributedText: attributedText, linkTextAttributes: linkAttributes, links: [terms, privacy, ein], openLink: openLink(value:))
  }
  
  private var attributedText: NSAttributedString {
    let message = format
    
    let attributes: [NSAttributedString.Key: Any] = [
      .font: Fonts.regular.font(size: 16),
      .foregroundColor: ModuleColors.label.swiftUIColor.opacity(0.75).uiColor,
      .paragraphStyle: titleParagraphStyle
    ]
    
    let result = NSMutableAttributedString(string: message, attributes: attributes)
    let einRange = result.mutableString.range(of: ein)
    result.addAttributes([.font: Fonts.regular.font(size: 16)], range: einRange)
    
    return result
  }
  
  private var linkAttributes: [NSAttributedString.Key: Any] {
    [
      .font: Fonts.bold.font(size: 16),
      .foregroundColor: ModuleColors.label.swiftUIColor.uiColor,
      .underlineStyle: NSUnderlineStyle.single.rawValue,
      .paragraphStyle: titleParagraphStyle
    ]
  }
  
  private var titleParagraphStyle: NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = .center
    style.lineHeightMultiple = 1.33
    return style
  }
  
  private var format: String {
    switch type {
    case .taxDeductions:
      return LFLocalizable.AlertAttributedText.taxDeductions(ein, terms, privacy)
    case .roundUp:
      return LFLocalizable.AlertAttributedText.roundUp(ein, terms, privacy)
    }
  }
  
  private var ein: String {
    LFLocalizable.AlertAttributedText.ein
  }
  
  private var terms: String {
    LFLocalizable.AlertAttributedText.terms
  }
  
  private var privacy: String {
    LFLocalizable.AlertAttributedText.privacy
  }
  
  private func openLink(value: String) {
    var url: URL?
    if value == terms {
      url = .init(string: "https://shoppinggives.com/terms-of-use/consumer/")
    } else if value == privacy {
      url = .init(string: "https://shoppinggives.com/privacy-policy/")
    }
    if let url {
      openURL(url)
    }
  }
}

extension ShoppingGivesAlert {
  enum Kind {
    case taxDeductions
    case roundUp
  }
}

#if DEBUG
struct ShoppingGivesAlert_Previews: PreviewProvider {
  static var previews: some View {
    ShoppingGivesAlert(type: .taxDeductions)
  }
}
#endif
