import SwiftUI

public extension View {
  /// Adds the current view inside a vertical ScrollView if its content doesn't fit on the given space.
  func scrollOnOverflow(showsIndicators: Bool = false) -> some View {
    modifier(ScrollOnOverflowViewModifier(showsIndicators: showsIndicators))
  }
}

struct ScrollOnOverflowViewModifier: ViewModifier {
  let showsIndicators: Bool
  @State private var contentOverflow: Bool = false

  func body(content: Content) -> some View {
    GeometryReader { geometry in
      content
        .background(
          GeometryReader { contentGeometry in
            Color.clear.onAppear {
              contentOverflow = contentGeometry.size.height > geometry.size.height
            }
          }
        )
        .wrappedInScrollView(when: contentOverflow, showsIndicators: showsIndicators)
    }
  }
}

private extension View {
  @ViewBuilder
  func wrappedInScrollView(when condition: Bool, showsIndicators: Bool) -> some View {
    if condition {
      ScrollView(showsIndicators: showsIndicators) {
        self
      }
    } else {
      self
    }
  }
}
