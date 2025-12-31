import Combine
import SwiftUI
import LFUtilities

public struct TextFieldInputModifer: ViewModifier {
  @Binding public var value: String
  public let restriction: TextRestriction

  public func body(content: Content) -> some View {
    content
      .onReceive(Just(value)) { newValue in
        restrictText(newValue: newValue)
      }
  }

  private func restrictText(newValue: String) {
    if restriction == .none {
      return
    } else {
      let filtered = newValue.filter { restriction.allowedInput.contains($0) }
      if filtered != newValue {
        value = filtered
      }
    }
  }
}

public extension View {
  func restrictInput(value: Binding<String>, restriction: TextRestriction) -> some View {
    modifier(TextFieldInputModifer(value: value, restriction: restriction))
  }
}
