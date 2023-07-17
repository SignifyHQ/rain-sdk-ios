import SwiftUI

public extension View {
    /// hidden
  @ViewBuilder
  func hidden(_ shouldHide: Bool) -> some View {
    switch shouldHide {
    case true: hidden()
    case false: self
    }
  }
  
  func isHidden(hidden: Bool = false, remove: Bool = false) -> some View {
    modifier(
      IsHidden(
        hidden: hidden,
        remove: remove)
    )
  }
  
  func floatingShadow() -> some View {
    shadow(color: Color(white: 0, opacity: 0.08), radius: 8, x: 0, y: 4)
  }
}

struct IsHidden: ViewModifier {
  var hidden = false
  var remove = false
  func body(content: Content) -> some View {
    if hidden {
      if remove {
        
      } else {
        content.hidden()
      }
    } else {
      content
    }
  }
}
