import SwiftUI
import LFUtilities

public struct DateTextField: UIViewRepresentable {
  @Environment(\.colorScheme) var colorScheme
  @Binding var date: Date?
  
  var placeholder: String
  
  private let textField = UITextField()
  private let datePicker = UIDatePicker()
  private let helper = Helper()
  
  public func makeUIView(context: Context) -> UITextField {
    setupDatePicker()
    setupTextField()
    setupToolbar()
    
    return textField
  }

  public func updateUIView(_ uiView: UITextField, context _: Context) {
    guard let date else {
      return
    }
   
    uiView.text = LiquidityDateFormatter.textFieldDate.parseToString(from: date)
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator()
  }
}

// MARK: - Helper Class
extension DateTextField {
  class Helper {
    var onDateValueChanged: (() -> Void)?
    var onDoneButtonTapped: (() -> Void)?
    
    @objc
    func dateValueChanged() {
      onDateValueChanged?()
    }
    
    @objc
    func doneButtonTapped() {
      onDoneButtonTapped?()
    }
  }
}

// MARK: - Private Functions
private extension DateTextField {
  func setupDatePicker() {
    let calendar = Calendar(identifier: .gregorian)
    let currentDate = Date()
    let maxDate = calculateDate(
      byAdding: DateComponents(year: Constants.DateTextField.maxYearOffset),
      to: currentDate,
      using: calendar
    )
    let minDate = calculateDate(
      byAdding: DateComponents(year: Constants.DateTextField.minYearOffset),
      to: currentDate,
      using: calendar
    )
    let initialDate = calculateDate(
      byAdding: DateComponents(
        year: Constants.DateTextField.initialYearOffset,
        month: Constants.DateTextField.maxMonthOffset
      ),
      to: currentDate,
      using: calendar
    )
    
    guard let maxDate, let minDate, let initialDate else {
      return
    }
    
    datePicker.datePickerMode = .date
    datePicker.minimumDate = minDate
    datePicker.maximumDate = maxDate
    datePicker.date = initialDate
    datePicker.preferredDatePickerStyle = .wheels
    datePicker.addTarget(helper, action: #selector(helper.dateValueChanged), for: .valueChanged)
    datePicker.backgroundColor = .white
    datePicker.setValue(UIColor.black, forKey: "textColor")
    datePicker.overrideUserInterfaceStyle = .light
  }
  
  func setupTextField() {
    textField.placeholder = placeholder
    textField.inputView = datePicker
    textField.textColor = .init(Colors.label.swiftUIColor)
    textField.font = UIFont(name: Fonts.regular.name, size: 16)
    textField.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        .foregroundColor: UIColor(Colors.label.swiftUIColor.opacity(0.25))
      ]
    )
    textField.rightViewMode = .always
    
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    imageView.image = UIImage(named: GenImages.CommonImages.calendar.name, in: .module, with: nil)
    imageView.tintColor = UIColor(Colors.label.swiftUIColor)
    textField.rightView = imageView
  }
  
  func setupToolbar() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: helper, action: #selector(Helper.doneButtonTapped))
    
    toolbar.setItems([flexibleSpace, doneButton, flexibleSpace], animated: true)
    toolbar.barTintColor = .white
    
    textField.inputAccessoryView = toolbar
    textField.inputAccessoryView?.backgroundColor = .white
    
    helper.onDoneButtonTapped = {
      self.date = self.datePicker.date
      self.textField.resignFirstResponder()
    }
  }
  
  func calculateDate(byAdding components: DateComponents, to date: Date, using calendar: Calendar) -> Date? {
    calendar.date(byAdding: components, to: date)
  }
}
