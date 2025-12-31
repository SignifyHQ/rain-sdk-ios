#if os(iOS)

import SwiftUI

@available(iOS 15, *)
struct SheetModifier: ViewModifier {
  let detents: [Detents]
  func body(content: Content) -> some View {
    SheetView(detents: detents) {
      content
    }
  }
}

public extension View {
  func customPresentationDetents(height: CGFloat) -> some View {
    Group {
      if #available(iOS 16.0, *) {
        self.presentationDetents([.height(height)])
      } else {
        self.presentationDetents([.medium])
      }
    }
  }

  func presentationDetents(_ detents: [Detents]) -> some View {
    modifier(SheetModifier(detents: detents))
  }
}

#endif
