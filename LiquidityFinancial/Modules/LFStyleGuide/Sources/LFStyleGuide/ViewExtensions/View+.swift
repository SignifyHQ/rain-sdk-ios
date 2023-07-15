import SwiftUI

extension View {
  /// hidden
  @ViewBuilder public func hidden(_ shouldHide: Bool) -> some View {
    switch shouldHide {
      case true: hidden()
      case false: self
    }
  }
}
