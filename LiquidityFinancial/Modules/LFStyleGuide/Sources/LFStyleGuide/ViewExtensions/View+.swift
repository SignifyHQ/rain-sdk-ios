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
  
  func floatingShadow() -> some View {
    shadow(color: Color(white: 0, opacity: 0.08), radius: 8, x: 0, y: 4)
  }
}
