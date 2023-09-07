import SwiftUI

// swiftlint:disable force_unwrapping
public struct DateTextField: UIViewRepresentable {
  private let textField = UITextField()
  private let datePicker = UIDatePicker()
  private let helper = Helper()

  var placeholder: String
  @Binding var date: Date?
  @Environment(\.colorScheme) var colorScheme

  public func makeUIView(context _: Context) -> UITextField {
    let calendar = Calendar(identifier: .gregorian)

    let currentDate = Date()
    var components = DateComponents()
    components.calendar = calendar
    components.year = -18
    components.month = -1
    let maxDate = calendar.date(byAdding: components, to: currentDate)!

    components.year = -100
    let minDate = calendar.date(byAdding: components, to: currentDate)!

    components.year = -20
    let initialDate = calendar.date(byAdding: components, to: currentDate)!

    datePicker.datePickerMode = .date
    datePicker.minimumDate = minDate
    datePicker.maximumDate = maxDate
    datePicker.date = initialDate
    datePicker.preferredDatePickerStyle = .wheels
    datePicker.addTarget(helper, action: #selector(helper.dateValueChanged), for: .valueChanged)
    datePicker.backgroundColor = UIColor.white
    datePicker.setValue(UIColor.black, forKey: "textColor")
    datePicker.overrideUserInterfaceStyle = .light

    textField.placeholder = placeholder
    textField.inputView = datePicker
    textField.textColor = UIColor(Colors.label.swiftUIColor)
    textField.font = UIFont(name: Fonts.regular.name, size: 16)
    textField.attributedPlaceholder = NSAttributedString(
      string: placeholder,
      attributes: [
        NSAttributedString.Key.foregroundColor: UIColor(Colors.label.swiftUIColor.opacity(0.25))
      ]
    )
    textField.rightViewMode = UITextField.ViewMode.always
    let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
    let image = UIImage(named: GenImages.CommonImages.calendar.name, in: .module, with: .none)
    imageView.image = image
    imageView.tintColor = UIColor(Colors.label.swiftUIColor)
    textField.rightView = imageView

    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: helper, action: #selector(helper.doneButtonTapped))

    toolbar.setItems([flexibleSpace, doneButton, flexibleSpace], animated: true)
    toolbar.barTintColor = UIColor.white

    textField.inputAccessoryView = toolbar
    textField.inputAccessoryView?.backgroundColor = UIColor.white

    helper.onDoneButtonTapped = {
      date = datePicker.date
      textField.resignFirstResponder()
    }

    return textField
  }

  public func updateUIView(_ uiView: UITextField, context _: Context) {
    // date = datePicker.date
    if let selectedDate = date {
      uiView.text = DateFormatter.textField.string(from: selectedDate)
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator()
  }

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
