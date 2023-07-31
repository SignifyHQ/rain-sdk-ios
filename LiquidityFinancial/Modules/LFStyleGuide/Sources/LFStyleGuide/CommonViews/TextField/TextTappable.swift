import SwiftUI
import LFUtilities

public struct TextTappable: UIViewRepresentable {
  public init(
    text: String,
    textAlignment: NSTextAlignment = .natural,
    fontSize: CGFloat = Constants.FontSize.small.value,
    links: [String],
    style: AttributeStyle = .fillColor,
    openLink: @escaping (String) -> Void) {
      attributedText = Self.buildAttributedText(text: text, textAlignment: textAlignment, fontSize: fontSize)
      linkTextAttributes = Self.buildLinkTextAttributes(fontSize: fontSize, style: style)
      self.links = links
      self.openLink = openLink
    }
  
  public init(
    attributedText: NSAttributedString,
    links: [String],
    style: AttributeStyle = .fillColor,
    openLink: @escaping (String) -> Void
  ) {
    self.attributedText = attributedText
    linkTextAttributes = Self.buildLinkTextAttributes(fontSize: 14, style: style)
    self.links = links
    self.openLink = openLink
  }
  
  public init(
    attributedText: NSAttributedString,
    linkTextAttributes: [NSAttributedString.Key: Any],
    links: [String],
    openLink: @escaping (String) -> Void
  ) {
    self.attributedText = attributedText
    self.linkTextAttributes = linkTextAttributes
    self.links = links
    self.openLink = openLink
  }
  
  let attributedText: NSAttributedString
  let linkTextAttributes: [NSAttributedString.Key: Any]
  let links: [String]
  let openLink: (String) -> Void
  
  public func makeUIView(context: Context) -> UITextView {
    let textView = UITextView()
    textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textView.isEditable = false
    textView.isSelectable = true
    textView.backgroundColor = UIColor.clear
    textView.delegate = context.coordinator
    textView.isScrollEnabled = false
    textView.textAlignment = .center
    textView.attributedText = attributedText
    textView.linkTextAttributes = linkTextAttributes
    return textView
  }
  
  public func updateUIView(_ uiView: UITextView, context _: Context) {
    let stringarr = NSMutableAttributedString(attributedString: uiView.attributedText)
    for strlink in links {
      let link = strlink.replacingOccurrences(of: " ", with: "_")
      stringarr.addAttribute(.link, value: String(format: "https://%@", link), range: (stringarr.string as NSString).range(of: strlink))
    }
    uiView.attributedText = stringarr
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }
  
  private static func buildAttributedText(text: String, textAlignment: NSTextAlignment, fontSize: CGFloat) -> NSAttributedString {
    let titleParagraphStyle = NSMutableParagraphStyle()
    titleParagraphStyle.alignment = textAlignment
    
    let regularAttributes: [NSAttributedString.Key: Any] = [
      .font: Fonts.regular.font(size: fontSize),
      .foregroundColor: Colors.label.color,
      .paragraphStyle: titleParagraphStyle
    ]
    return NSMutableAttributedString(string: text, attributes: regularAttributes)
  }
  
  private static func buildLinkTextAttributes(fontSize: CGFloat, style: AttributeStyle) -> [NSAttributedString.Key: Any] {
    [
      .underlineStyle: style == .fillColor ? 0 : 1,
      .font: style == .fillColor ? Fonts.bold.font(size: fontSize) : Fonts.regular.font(size: fontSize),
      .foregroundColor: style == .fillColor ? Colors.primary.color : Colors.label.color
    ]
  }
}

  // MARK: - Coordinator
extension TextTappable {
  public class Coordinator: NSObject, UITextViewDelegate {
    public var parent: TextTappable
    
    public init(parent: TextTappable) {
      self.parent = parent
    }
    
    public func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange, interaction _: UITextItemInteraction) -> Bool {
      let strPlain = URL.absoluteString.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "_", with: " ")
      if parent.links.contains(strPlain) {
        parent.openLink(strPlain)
      }
      return false
    }
  }
}

  // MARK: AttributeStyle
extension TextTappable {
  public enum AttributeStyle {
    case fillColor
    case underlined
  }
}
