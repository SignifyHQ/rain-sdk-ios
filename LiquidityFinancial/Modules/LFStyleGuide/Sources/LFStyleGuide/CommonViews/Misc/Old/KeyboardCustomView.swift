import SwiftUI
import LFUtilities

public struct KeyboardCustomView: View {
  @Binding private var value: String
  @State private var rawValue = Const.zero
  @State private var hasDecimalSeparator = false
  private let maxFractionDigits: Int
  private let disable: Bool
  private let action: (() -> Void)?
  private let columns: [GridItem] = .init(repeating: GridItem(.flexible()), count: 3)
  private let maxIntegerDigits: Int = Constants.MaxCharacterLimit.amountLimit.value
  
  public init(value: Binding<String>,
              action: @escaping (() -> Void),
              maxFractionDigits: Int = 2,
              disable: Bool = false) {
  _value = value
  self.action = action
  self.maxFractionDigits = maxFractionDigits
  self.disable = disable
  }
  
  public var body: some View {
    LazyVGrid(columns: columns, spacing: 28) {
      ForEach(Array(Const.KeyPad.enumerated()), id: \.offset) { _, key in
        Button {
          onPressedKeyPad(key)
        } label: {
          if key == Const.backArrowKey {
            Image(systemName: "arrow.backward")
              .font(Fonts.regular.swiftUIFont(size: 20))
          } else {
            Text(key)
              .font(Fonts.bold.swiftUIFont(size: 28))
          }
        }
        .frame(width: 32)
        .foregroundColor(Colors.label.swiftUIColor)
      }
    }
    .onChange(of: value) { newValue in
      hasDecimalSeparator = newValue.contains(Const.decimalSeparator)
      rawValue = newValue.removeGroupingSeparator()
    }
    .disabled(disable)
  }
}

  // MARK: - Private UI Helpers Function

private extension KeyboardCustomView {
  func onPressedKeyPad(_ key: String) {
    action?()
    let numberSeparation = rawValue.components(separatedBy: Const.decimalSeparator)
    let fractionDigits = hasDecimalSeparator ? numberSeparation.last?.count ?? 0 : 0
    let integerDigits = numberSeparation.first?.count ?? 0
    let isNaN = key == Const.backArrowKey || key == Const.decimalSeparator
    if (integerDigits < maxIntegerDigits && !hasDecimalSeparator) ||
        (fractionDigits < maxFractionDigits && hasDecimalSeparator) ||
        isNaN {
      handleKeyWasPressed(key)
    }
  }
  
  func handleKeyWasPressed(_ key: String) {
    switch key {
    case Const.decimalSeparator where hasDecimalSeparator: break
    case Const.decimalSeparator where value == Const.zero: value += key
    case Const.zero where hasDecimalSeparator: value += key
    case Const.backArrowKey:
      value.removeLast()
      formatValue(with: key)
    case _ where value == Const.zero: value = key
    default:
      value.append(key)
      formatValue(with: key)
    }
  }
  
  func formatValue(with key: String) {
    if key != Const.decimalSeparator {
      let formattedValue = value
        .removeGroupingSeparator()
        .convertToDecimalFormat()
        .formattedAmount(maxFractionDigits: maxFractionDigits)
      value = formattedValue.isEmpty ? Const.zero : formattedValue
    }
  }
}

  // MARK: - Keyboard Constant

private extension KeyboardCustomView {
  enum Const {
    static let zero = "0"
    static let groupSeparator = Locale.current.groupingSeparator ?? ","
    static let decimalSeparator = Locale.current.decimalSeparator ?? "."
    static let backArrowKey = "backArrow"
    static let KeyPad = ["1", "2", "3", "4", "5", "6", "7", "8", "9", Const.decimalSeparator, Const.zero, Const.backArrowKey]
  }
}
