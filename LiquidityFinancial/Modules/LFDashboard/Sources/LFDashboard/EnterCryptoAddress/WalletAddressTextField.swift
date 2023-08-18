import Combine
import iPhoneNumberField
import SwiftUI
import LFUtilities
import LFStyleGuide

struct WalletAddressTextField: View {
  @FocusState private var isFocus: Bool
  @Binding private var value: String
  @Binding private var numberOfShakes: Int

  let placeHolderText: String
  let textFieldTitle: String?
  let errorMessage: String?
  let clearValue: (() -> Void)?
  let scanTap: (() -> Void)?

  private var disposeBag = Set<AnyCancellable>()

  init(
    placeHolderText: String,
    value: Binding<String>,
    errorMessage: String? = nil,
    textFieldTitle: String? = nil,
    clearValue: (() -> Void)? = nil,
    scanTap: (() -> Void)? = nil,
    numberOfShakes: Binding<Int> = .constant(0)
  ) {
    _value = value
    _numberOfShakes = numberOfShakes
    self.placeHolderText = placeHolderText
    self.errorMessage = errorMessage
    self.textFieldTitle = textFieldTitle
    self.clearValue = clearValue
    self.scanTap = scanTap
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      headerTitle
      walletScanTextField
      dividerLine
      inlineError
    }
    .padding(.horizontal, 0)
    .padding(.top, 5)
    .padding(.bottom, 3)
  }
}

// MARK: View Components

private extension WalletAddressTextField {
  @ViewBuilder var headerTitle: some View {
    if let textFieldTitle = textFieldTitle {
      Text(textFieldTitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }

  @ViewBuilder var dividerLine: some View {
    Divider()
      .background(Colors.label.swiftUIColor.opacity(0.25))
      .frame(height: 1)
      .padding(.horizontal, 0)
  }

  @ViewBuilder var inlineError: some View {
    if let errorMessage = errorMessage {
      Text(errorMessage)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.error.swiftUIColor)
        .padding(.horizontal, 0)
        .shakeAnimation(with: numberOfShakes)
    }
  }

  var walletScanTextField: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 12) {
        textField
          .padding(.leading, value.isEmpty ? 0 : 12)
          .padding(.vertical, 10)
        trailingImageView
      }
      .frame(height: 34)
    }
    .padding(.leading, 10)
    .background(value.isEmpty ? Color.clear : Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(8)
  }

  var textField: some View {
    TextField("", text: $value)
      .placeholderStyle(showPlaceholder: value.isEmpty, placeholder: placeHolderText)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .autocapitalization(.none)
      .disableAutocorrection(true)
      .keyboardType(.alphabet)
      .onChange(of: value, perform: onTextChanged)
  }
  
  @ViewBuilder var trailingImageView: some View {
    if value.isEmpty {
      GenImages.Images.icScanner.swiftUIImage
        .onTapGesture {
          scanTap?()
        }
    } else {
      GenImages.CommonImages.icXMark.swiftUIImage
        .padding(.trailing, 10)
        .foregroundColor(Colors.label.swiftUIColor)
        .onTapGesture {
          clearValue?()
        }
    }
  }
}

// MARK: UI Helpers

private extension WalletAddressTextField {
  func limitText() {
    let upperLimit = Constants.MaxCharacterLimit.address.value
    if value.count > upperLimit {
      value = String(value.prefix(upperLimit))
    }
  }

  func onTextChanged(newValue: String) {
    limitText()
  }
}
