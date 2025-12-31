import SwiftUI

struct ShakeAnimationModifier: ViewModifier, Animatable {
  var shakes: CGFloat = 0

  var animatableData: CGFloat {
    get {
      shakes
    } set {
      shakes = newValue
    }
  }

  func body(content: Content) -> some View {
    content
      .offset(x: sin(shakes * .pi * 2) * 5)
  }
}

public extension View {
  // Shake Animation
  func shakeAnimation(with shakes: Int) -> some View {
    modifier(ShakeAnimationModifier(shakes: CGFloat(shakes)))
  }
}
