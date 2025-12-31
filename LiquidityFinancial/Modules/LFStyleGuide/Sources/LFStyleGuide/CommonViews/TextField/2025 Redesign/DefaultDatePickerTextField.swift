import LFUtilities
import SwiftUI

public struct DefaultDatePickerTextField: View {
  var title: String?
  let placeholder: String
  
  @Binding var value: Date?
  @Binding private var errorMessage: String?
  
  public init(
    title: String? = nil,
    placeholder: String,
    value: Binding<Date?>,
    errorMessage: Binding<String?> = .constant(nil)
  ) {
    self.title = title
    self.placeholder = placeholder
    self._value = value
    self._errorMessage = errorMessage
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
        errorValue: $errorMessage
      ) {
        DefaultDateTextField(
          date: $value,
          placeholder: placeholder
        )
        .font(Fonts.regular.swiftUIFont(size: 16))
      }
    }
  }
}
