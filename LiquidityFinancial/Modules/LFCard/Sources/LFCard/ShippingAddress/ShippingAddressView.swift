import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct ShippingAddressView: View {
  @Environment(\.dismiss) private var dismiss
  @FocusState var keyboardFocus: Focus?
  @Binding var shippingAddress: ShippingAddress
  @State private var mainAddress: String = ""
  @State private var subAddress: String = ""
  @State private var city: String = ""
  @State private var state: String = ""
  @State private var zipCode: String = ""
  
  var isDisableButton: Bool {
    mainAddress.isEmpty || city.isEmpty || state.isEmpty || zipCode.isEmpty
  }
  
  enum Focus: Int, Hashable {
    case address1
    case address2
    case city
    case state
    case zip
  }
  
  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ScrollView {
          ZStack {
            content
              .onChange(of: keyboardFocus) {
                proxy.scrollTo($0)
              }
          }
        }
      }
      button
    }
    .background(Colors.background.swiftUIColor)
  }
}

private extension ShippingAddressView {
  var content: some View {
    VStack(alignment: .leading, spacing: 32) {
      Text(
        LFLocalizable.ShippingAddress.Screen.title(LFUtility.appName.uppercased())
      )
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)
      enterAddressView
    }
    .padding(.horizontal, 30)
  }
  var enterAddressView: some View {
    VStack(alignment: .leading, spacing: 23) {
      mainAddressTextField
      subAddressTextField
      cityTextField
      HStack {
        stateTextField
        Spacer(minLength: 25)
        zipCodeTextField
      }
    }
  }
  
  var mainAddressTextField: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.addressLine1Title)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterAddress,
        value: $mainAddress,
        focus: .address1,
        nextFocus: .address2
      )
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          keyboardFocus = .address1
        }
      }
    }
  }
  
  var subAddressTextField: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.addressLine2Title)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterAddress,
        value: $subAddress,
        focus: .address2,
        nextFocus: .city
      )
    }
  }
  
  var cityTextField: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.city)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterCity,
        value: $city,
        focus: .city,
        nextFocus: .state
      )
    }
  }
  
  var stateTextField: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.state)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterState,
        value: $state,
        limit: 2,
        restriction: .alphabets,
        focus: .state,
        nextFocus: .zip
      )
    }
  }
  
  var zipCodeTextField: some View {
    VStack(alignment: .leading) {
      Text(LFLocalizable.zipcode)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      textField(
        placeholder: LFLocalizable.enterZipcode,
        value: $zipCode,
        limit: 11,
        keyboardType: .numberPad,
        focus: .zip
      )
    }
  }
  
  var button: some View {
    FullSizeButton(
      title: LFLocalizable.ShippingAddress.Confirm.buttonTitle,
      isDisable: isDisableButton
    ) {
      keyboardFocus = nil
      shippingAddress = ShippingAddress(
        line1: mainAddress,
        line2: subAddress.isEmpty ? shippingAddress.line2 : subAddress,
        city: city,
        stateOrRegion: state,
        postalCode: zipCode
      )
      dismiss()
    }
    .padding(.bottom, 16)
    .padding(.horizontal, 30)
  }
  
  @ViewBuilder
  func textField(
    placeholder: String,
    value: Binding<String>,
    limit: Int = 200,
    restriction: TextRestriction = .none,
    keyboardType: UIKeyboardType = .alphabet,
    focus: Focus,
    nextFocus: Focus? = nil
  ) -> some View {
    TextFieldWrapper {
      TextField("", text: value)
        .keyboardType(keyboardType)
        .restrictInput(value: value, restriction: restriction)
        .modifier(PlaceholderStyle(showPlaceHolder: value.wrappedValue.isEmpty, placeholder: placeholder))
        .primaryFieldStyle()
        .autocorrectionDisabled()
        .limitInputLength(value: value, length: limit)
        .submitLabel(nextFocus == nil ? .done : .next)
        .focused($keyboardFocus, equals: focus)
        .onSubmit {
          keyboardFocus = nextFocus
        }
    }
  }
}
