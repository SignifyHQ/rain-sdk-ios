import SwiftUI

// MARK: - TextFieldLimitModifer
struct TextFieldLimitModifer: ViewModifier {
  @Binding var value: String
  var length: Int
  
  func body(content: Content) -> some View {
    content
      .onChange(of: $value.wrappedValue) {
        value = String($0.prefix(length))
      }
  }
}

// MARK: - View Extension
public extension View {
  func limitInputLength(value: Binding<String>, length: Int) -> some View {
    modifier(TextFieldLimitModifer(value: value, length: length))
  }
}
