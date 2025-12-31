import LFUtilities
import SwiftUI

public struct DefaultDateTextField: UIViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  @Binding var date: Date?
  
  var placeholder: String
  
  private let textField = UITextField()
  private let datePicker = UIDatePicker()
  private let helper = Helper()
  
  public func makeUIView(
    context: Context
  ) -> UITextField {
    setupDatePicker()
    setupTextField()
    
    return textField
  }

  public func updateUIView(
    _ uiView: UITextField,
    context _: Context
  ) {
    guard let date
    else {
      return
    }
   
    uiView.text = LiquidityDateFormatter.textFieldDate.parseToString(from: date)
  }

  public func makeCoordinator(
  ) -> Coordinator {
    Coordinator()
  }
}

// MARK: - Private Functions
private extension DefaultDateTextField {
  func setupDatePicker() {
    let calendar = Calendar(identifier: .gregorian)
    let currentDate = Date()
    
    let max18YoDate = calculateDate(
      byAdding: DateComponents(year: Constants.DateTextField.maxYearOffset),
      to: currentDate,
      using: calendar
    )
    
    guard let max18YoDate
    else {
      return
    }
    
    datePicker.datePickerMode = .date
    datePicker.date = max18YoDate
    
    datePicker.preferredDatePickerStyle = .wheels
    
    datePicker.backgroundColor = Colors.backgroundPrimary.swiftUIColor.uiColor
    datePicker.setValue(Colors.titlePrimary.swiftUIColor.uiColor, forKey: "textColor")
    
    datePicker.addTarget(helper, action: #selector(helper.dateValueChanged), for: .valueChanged)
    helper.onDateValueChanged = {
      self.date = self.datePicker.date
    }
  }
  
  func setupTextField() {
    textField.inputView = datePicker
    
    textField.font = UIFont(name: Fonts.regular.name, size: 16)
    
    textField.textColor = .init(Colors.titlePrimary.swiftUIColor)
    textField.tintColor = .init(Colors.backgroundLight.swiftUIColor)
    
    textField.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        .foregroundColor: UIColor(Colors.titlePrimary.swiftUIColor.opacity(0.25))
      ]
    )
  }
  
  func setupToolbar() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: "Done", style: .done, target: helper, action: #selector(Helper.doneButtonTapped))
    doneButton.tintColor = Colors.titlePrimary.swiftUIColor.uiColor
    
    toolbar.setItems([flexibleSpace, doneButton], animated: true)
    
    toolbar.barTintColor = Colors.backgroundPrimary.swiftUIColor.uiColor
    
    textField.inputAccessoryView = toolbar
    textField.inputAccessoryView?.backgroundColor = Colors.backgroundPrimary.swiftUIColor.uiColor
    
    helper.onDoneButtonTapped = {
      self.date = self.datePicker.date
      self.textField.resignFirstResponder()
    }
  }
  
  func calculateDate(
    byAdding components: DateComponents,
    to date: Date,
    using calendar: Calendar
  ) -> Date? {
    calendar.date(byAdding: components, to: date)
  }
}

// MARK: - Helper Class
extension DefaultDateTextField {
  class Helper {
    var onDateValueChanged: (() -> Void)?
    var onDoneButtonTapped: (() -> Void)?
    
    @objc func dateValueChanged() {
      onDateValueChanged?()
    }
    
    @objc func doneButtonTapped() {
      onDoneButtonTapped?()
    }
  }
}
