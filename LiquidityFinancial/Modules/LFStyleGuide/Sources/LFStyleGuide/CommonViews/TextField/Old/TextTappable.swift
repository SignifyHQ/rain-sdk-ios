import SwiftUI
import UIKit
import LFUtilities

public struct TextTappable: UIViewRepresentable {
  public init(
    text: String,
    textAlignment: NSTextAlignment = .natural,
    verticalTextAlignment: VerticalTextAlignment = .center,
    textColor: UIColor = Colors.label.color,
    fontSize: CGFloat = Constants.FontSize.small.value,
    links: [String],
    style: AttributeStyle = .fillColor(Colors.primary.color),
    weight: FontWeight = .bold,
    openLink: @escaping (String) -> Void) {
      attributedText = Self.buildAttributedText(
        text: text,
        textColor: textColor,
        textAlignment: textAlignment,
        fontSize: fontSize
      )
      
      linkTextAttributes = Self.buildLinkTextAttributes(fontSize: fontSize, style: style, weight: weight)
      
      self.links = links
      self.openLink = openLink
      self.verticalTextAlignment = verticalTextAlignment
    }
  
  public init(
    attributedText: NSAttributedString,
    links: [String],
    style: AttributeStyle = .fillColor(Colors.primary.color),
    weight: FontWeight = .bold,
    openLink: @escaping (String) -> Void
  ) {
    self.attributedText = attributedText
    self.links = links
    self.openLink = openLink
    
    linkTextAttributes = Self.buildLinkTextAttributes(fontSize: 14, style: style, weight: weight)
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
  var verticalTextAlignment: VerticalTextAlignment = .center
  
  public func makeUIView(
    context: Context
  ) -> UITextView {
    let textView = ResizingTextView()
    textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    textView.isEditable = false
    textView.isSelectable = true
    textView.backgroundColor = UIColor.clear
    textView.delegate = context.coordinator
    textView.isScrollEnabled = false
    
    textView.textAlignment = .center
    textView.contentInset = .zero
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    textView.attributedText = attributedText
    textView.linkTextAttributes = linkTextAttributes
    
    return textView
  }
  
  public func updateUIView(
    _ uiView: UITextView,
    context _: Context
  ) {
    let stringarr = NSMutableAttributedString(attributedString: attributedText)
    
    for strlink in links {
      let link = strlink.replacingOccurrences(of: " ", with: "_")
      let allRanges = (stringarr.string as NSString).ranges(of: strlink)
      
      for range in allRanges {
        stringarr.addAttribute(.link, value: String(format: "https://%@", link), range: range)
      }
    }
    
    uiView.attributedText = stringarr
    
    DispatchQueue.main.async {
      uiView.textContainerInset = .zero
      
      let viewHeight = uiView.bounds.height
      guard viewHeight > 0 else {
        return
      }
      
      let contentSize = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude))
      
      var verticalPadding: CGFloat = 0
      if contentSize.height < viewHeight {
        switch verticalTextAlignment {
        case .top:
          verticalPadding = 0
        case .center:
          verticalPadding = (viewHeight - contentSize.height) / 2
        case .bottom:
          verticalPadding = viewHeight - contentSize.height
        }
      }
      
      let newInset = UIEdgeInsets(
        top: max(0, verticalPadding),
        left: 0,
        bottom: max(0, verticalPadding),
        right: 0
      )
      
      if uiView.textContainerInset != newInset {
        uiView.textContainerInset = newInset
      }
    }
  }
  
  public func makeCoordinator(
  ) -> Coordinator {
    Coordinator(parent: self)
  }
  
  private static func buildAttributedText(
    text: String,
    textColor: UIColor,
    textAlignment: NSTextAlignment,
    fontSize: CGFloat
  ) -> NSAttributedString {
    let titleParagraphStyle = NSMutableParagraphStyle()
    
    titleParagraphStyle.alignment = textAlignment
    titleParagraphStyle.lineSpacing = 2
    
    let regularAttributes: [NSAttributedString.Key: Any] = [
      .font: Fonts.regular.font(size: fontSize),
      .foregroundColor: textColor,
      .paragraphStyle: titleParagraphStyle
    ]
    
    return NSMutableAttributedString(string: text, attributes: regularAttributes)
  }
  
  private static func buildLinkTextAttributes(
    fontSize: CGFloat,
    style: AttributeStyle,
    weight: FontWeight
  ) -> [NSAttributedString.Key: Any] {
    let underlineStyle: Int
    let font: UIFont = weight.font(size: fontSize)
    let foregroundColor: UIColor
    
    switch style {
    case .fillColor(let color):
      underlineStyle = 0
      foregroundColor = color
    case .underlined(let color):
      underlineStyle = 1
      foregroundColor = color
    }
    
    return [
      .underlineStyle: underlineStyle,
      .font: font,
      .foregroundColor: foregroundColor
    ]
  }
}

  // MARK: - Coordinator
extension TextTappable {
  public class Coordinator: NSObject, UITextViewDelegate {
    public var parent: TextTappable
    
    public init(
      parent: TextTappable
    ) {
      self.parent = parent
    }
    
    public func textView(
      _: UITextView,
      shouldInteractWith URL: URL,
      in _: NSRange,
      interaction _: UITextItemInteraction
    ) -> Bool {
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
    case fillColor(UIColor)
    case underlined(UIColor)
  }
  
  public enum FontWeight {
    case regular
    case bold
    
    func font(size: CGFloat) -> UIFont {
      switch self {
      case .regular: return .systemFont(ofSize: size)
      case .bold:    return .boldSystemFont(ofSize: size)
      }
    }
  }
}

private extension NSString {
  func ranges(of searchString: String) -> [NSRange] {
    var ranges: [NSRange] = []
    var searchRange = NSRange(location: 0, length: self.length)
    
    while searchRange.location < self.length {
      let foundRange = self.range(of: searchString, options: [], range: searchRange)
      
      if foundRange.location != NSNotFound {
        ranges.append(foundRange)
        searchRange.location = foundRange.location + foundRange.length
        searchRange.length = self.length - searchRange.location
      } else {
        break
      }
    }
    return ranges
  }
}

public enum VerticalTextAlignment {
  case top
  case center
  case bottom
}

// MARK: ResizingTextView
private extension TextTappable {
  final class ResizingTextView: UITextView {
    override var intrinsicContentSize: CGSize {
      let size = sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
      return CGSize(width: UIView.noIntrinsicMetric, height: size.height)
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      invalidateIntrinsicContentSize()
    }
  }
}
