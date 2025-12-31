import LFUtilities
import SwiftUI

public struct DefaultTextField: View {
  var title: String?
  var placeholder: String
  var isDividerShown: Bool
  var value: Binding<String>
  var tint: Color
  var limit: Int
  var keyboardType: UIKeyboardType
  var submitLabel: SubmitLabel
  var autoCapitalization: TextInputAutocapitalization
  let font: SwiftUI.Font
  let textColor: Color
  let placeholderColor: Color
  
  @FocusState private var isFocused: Bool
  
  @Binding private var errorMessage: String?
  @Binding var isLoading: Bool
  
  public init(
    title: String? = nil,
    placeholder: String,
    isDividerShown: Bool = true,
    value: Binding<String>,
    tint: Color = Colors.backgroundLight.swiftUIColor,
    limit: Int = 200,
    keyboardType: UIKeyboardType = .alphabet,
    submitLabel: SubmitLabel = .return,
    autoCapitalization: TextInputAutocapitalization = .sentences,
    font: SwiftUI.Font = Fonts.regular.swiftUIFont(size: 16),
    textColor: Color = Colors.label.swiftUIColor,
    placeholderColor: Color = Colors.textSecondary2.swiftUIColor,
    errorMessage: Binding<String?> = .constant(nil),
    isloading: Binding<Bool> = .constant(false)
  ) {
    self.title = title
    self.placeholder = placeholder
    self.isDividerShown = isDividerShown
    self.value = value
    self.tint = tint
    self.limit = limit
    self.keyboardType = keyboardType
    self.submitLabel = submitLabel
    self.autoCapitalization = autoCapitalization
    self.font = font
    self.textColor = textColor
    self.placeholderColor = placeholderColor
    self._errorMessage = errorMessage
    self._isLoading = isloading
  }
  
  public var body: some View {
    VStack(
      alignment: .leading,
      spacing: 8
    ) {
      if let title {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
      }
      
      DefaultTextFieldWrapper(
        errorValue: $errorMessage,
        isLoading: $isLoading,
        isDividerShown: isDividerShown
      ) {
        TextField(
          "",
          text: value
        )
        .tint(tint)
        .keyboardType(keyboardType)
        .submitLabel(submitLabel)
        .multilineTextAlignment(.leading)
        .modifier(
          DefaultPlaceholderStyle(
            showPlaceHolder: value.wrappedValue.isEmpty,
            placeholder: placeholder,
            font: font,
            color: placeholderColor
          )
        )
        .defaultPrimaryFieldStyle(
          font: font,
          color: textColor
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(autoCapitalization)
        .limitInputLength(
          value: value,
          length: limit
        )
        .focused($isFocused)
      }
    }
  }
}
