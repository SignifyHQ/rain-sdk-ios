import SwiftUI

public extension View {
  func onTapGestureIf(_ condition: Bool, perform action: @escaping () -> Void) -> some View {
    applyIf(condition) {
      $0.onTapGesture(simultaneous: true, perform: action)
    }
  }
  
  @ViewBuilder
  func onTapGesture(count: Int = 1, simultaneous: Bool, perform action: @escaping () -> Void) -> some View {
#if os(tvOS)
    // `TapGesture` isn't supported on tvOS.
    self
#else
    if simultaneous {
      simultaneousGesture(TapGesture(count: count).onEnded {
        action()
      })
    } else {
      onTapGesture(count: count, perform: action)
    }
#endif
  }
}
