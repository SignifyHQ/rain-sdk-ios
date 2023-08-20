import Combine
import LFServices
import LFUtilities
import SwiftUI
import UIKit
import CurrencyFormatter
import CurrencyTextField

public struct CurrencyTextFieldView: View {
  @FocusState private var keyboardFocus: Bool
  @Binding var value: String
  var fontSize: CGFloat
  var fontColor: Color
  var placeHolderText: String?
  var alignment: TextAlignment
  private let isFocusOnStart: Bool
  
  public init(
    fontSize: CGFloat,
    fontColor: Color,
    placeHolderText: String,
    value: Binding<String>,
    textAlignment: TextAlignment,
    isFocusOnStart: Bool = false
  ) {
    _value = value
    self.fontSize = fontSize
    self.fontColor = fontColor
    self.placeHolderText = placeHolderText
    alignment = textAlignment
    self.isFocusOnStart = isFocusOnStart
  }
  
  public var body: some View {
    HStack {
      CurrencyTextField(
        configuration: .init(
          placeholder: placeHolderText ?? "$0.00",
          text: $value,
          clearsWhenValueIsZero: true,
          formatter: .constant(.defaultdata),
          textFieldConfiguration: { uiTextField in
            uiTextField.font = Fonts.bold.font(size: fontSize)
            uiTextField.textColor = fontColor.uiColor
            uiTextField.keyboardType = .numberPad
            
            if alignment == .trailing {
              uiTextField.textAlignment = .right
            } else if alignment == .center {
              uiTextField.textAlignment = .center
            } else {
              uiTextField.textAlignment = .left
            }
          }
        )
      )
      .task {
        if isFocusOnStart {
          keyboardFocus = true
        }
      }
      .focused($keyboardFocus)
    }
  }
}

extension CurrencyFormatter {
  static let defaultdata: CurrencyFormatter = .init {
    $0.maxValue = 100_000
    $0.minValue = 0
    $0.currency = .dollar
    $0.hasDecimals = true
    $0.maxIntegers = Constants.MaxCharacterLimit.amountLimit.value
    $0.locale = CurrencyLocale.englishUnitedStates
  }
}
