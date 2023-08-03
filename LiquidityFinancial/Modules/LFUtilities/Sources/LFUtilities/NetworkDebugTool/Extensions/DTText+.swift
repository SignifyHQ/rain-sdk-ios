import SwiftUI

extension Text {
  init(attString: NSAttributedString) {
    self.init("")

    attString.enumerateAttributes(in: NSRange(location: 0, length: attString.length), options: []) { attrs, range, _ in

      var attribute = Text(attString.attributedSubstring(from: range).string)

      if let color = attrs[NSAttributedString.Key.foregroundColor] as? UIColor {
        attribute = attribute.foregroundColor(Color(color))
      }

      if let font = attrs[NSAttributedString.Key.font] as? UIFont {
        attribute = attribute.font(.init(font))
      }

      if let kern = attrs[NSAttributedString.Key.kern] as? CGFloat {
        attribute = attribute.kerning(kern)
      }

      if let striked = attrs[NSAttributedString.Key.strikethroughStyle] as? NSNumber, striked != 0 {
        if let strikeColor = (attrs[NSAttributedString.Key.strikethroughColor] as? UIColor) {
          attribute = attribute.strikethrough(true, color: Color(strikeColor))
        } else {
          attribute = attribute.strikethrough(true)
        }
      }

      if let baseline = attrs[NSAttributedString.Key.baselineOffset] as? NSNumber {
        attribute = attribute.baselineOffset(CGFloat(baseline.floatValue))
      }

      if let underline = attrs[NSAttributedString.Key.underlineStyle] as? NSNumber, underline != 0 {
        if let underlineColor = (attrs[NSAttributedString.Key.underlineColor] as? UIColor) {
          attribute = attribute.underline(true, color: Color(underlineColor))
        } else {
          attribute = attribute.underline(true)
        }
      }

      let newValue = self + attribute
      self = newValue
    }
  }
}
