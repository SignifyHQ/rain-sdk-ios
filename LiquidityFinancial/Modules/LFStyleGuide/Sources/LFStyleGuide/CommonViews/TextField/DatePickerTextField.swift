import SwiftUI

public struct DatePickerTextField: View {
  public init(placeHolderText: String, value: Binding<Date?>, dateValue: Binding<String>) {
    self.placeHolderText = placeHolderText
    _value = value
    _dateValue = dateValue
  }

  let placeHolderText: String
  @Binding var value: Date?
  @Binding var dateValue: String

  public var body: some View {
    TextFieldWrapper {
      DateTextField(placeholder: "mm / dd / yyyy", date: $value)
        .font(Fonts.Inter.regular.swiftUIFont(size: 16))
    }
  }
}
