import Foundation
import SwiftUI
import UIKit

struct DBHighlightEditorView: UIViewRepresentable {
  @Binding var text: String
  var highlightText: String

  func makeUIView(context: Context) -> UITextView {
    let textView = DBTextView()
    textView.font = UIFont(name: "Courier", size: 14)
    textView.dataDetectorTypes = UIDataDetectorTypes.link
    textView.text = text
    return textView
  }

  func updateUIView(_ uiView: UITextView, context: Context) {
    guard let textView = (uiView as? DBTextView) else { return }
    if highlightText.isEmpty == false {
      _ = textView.highlights(text: highlightText)
    } else {
      let attributedString = NSMutableAttributedString(attributedString: textView.attributedText)
      attributedString.addAttribute(.backgroundColor, value: UIColor.clear, range: NSRange(location: 0, length: textView.attributedText.length))
      attributedString.addAttribute(.font, value: UIFont(name: "Courier", size: 14)!, range: NSRange(location: 0, length: textView.attributedText.length))
      textView.attributedText = attributedString
    }
  }
}

class DBTextView: UITextView {
  func highlights(text: String?, with color: UIColor = UIColor.green, font: UIFont = UIFont.systemFont(ofSize: 14), highlightedFont: UIFont = UIFont.boldSystemFont(ofSize: 14)) -> [NSTextCheckingResult] {
    guard let keywordSearch = text?.lowercased(), let textViewText = self.text?.lowercased() else { return [] }

    let attributed = NSMutableAttributedString(string: textViewText)
    attributed.addAttribute(.font, value: font, range: NSRange(location: 0, length: attributedText.length))
    if #available(iOS 13.0, *) {
      attributed.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: self.attributedText.length))
    }

    do {
      let regex = try NSRegularExpression(pattern: keywordSearch, options: .caseInsensitive)
      let matches = regex.matches(in: textViewText, options: [], range: NSMakeRange(0, textViewText.count))

      matches.forEach {
        attributed.addAttribute(.backgroundColor, value: color, range: $0.range)
        attributed.addAttribute(.font, value: highlightedFont, range: $0.range)
      }
      attributedText = attributed

      return matches

    } catch {
      print(error)
    }
    return []
  }

  func convertRange(range: NSRange) -> UITextRange? {
    let beginning = beginningOfDocument
    if let start = position(from: beginning, offset: range.location),
       let end = position(from: start, offset: range.length)
    {
      return textRange(from: start, to: end)
    }
    return nil
  }
}
