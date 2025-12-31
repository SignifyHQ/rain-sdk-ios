import UIKit
import SwiftUI

extension FontConvertible {
  public func uiFont(
    size: CGFloat
  ) -> UIFont {
    return self.font(size: size)
  }
  
  public func uiFont(
    style: UIFont.TextStyle
  ) -> UIFont {
    let metrics = UIFontMetrics(forTextStyle: style)
    let rawFont = self.font(size: UIFont.preferredFont(forTextStyle: style).pointSize)
    return metrics.scaledFont(for: rawFont)
  }
}
