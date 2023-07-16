import SwiftUI
import LFUtilities

public struct TextFieldWrapper<Content: View>: View {
  public init(
    errorValue: Binding<String?> = .constant(nil),
    @ViewBuilder content: () -> Content
  ) {
    self.content = content()
    _errorValue = errorValue
  }
  
  let content: Content
  @Binding var errorValue: String?
  
  public var body: some View {
    VStack(spacing: 16) {
      HStack {
        content
        GenImages.Images.icError.swiftUIImage
          .hidden(errorValue == nil)
      }
      Divider()
        .background(errorValue == nil ? Colors.label.swiftUIColor.opacity(0.25) : Colors.error.swiftUIColor)
        .frame(height: 1, alignment: .center)
      if let errorValue {
        Text(errorValue)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.error.swiftUIColor)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
    }
  }
}
