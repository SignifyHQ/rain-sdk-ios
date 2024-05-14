import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct RainShippingAddressView: View {
  @Environment(\.dismiss)
  private var dismiss
  @StateObject
  private var viewModel: RainShippingAddressViewModel
  @FocusState
  var keyboardFocus: Focus?
  
  enum Focus: Int, Hashable {
    case address1
    case address2
    case city
    case state
    case zip
  }
  
  init(viewModel: RainShippingAddressViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
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
            if viewModel.displaySuggestions {
              if #available(iOS 16.0, *) {
                listView().scrollContentBackground(.hidden)
              } else {
                listView()
              }
            }
          }
        }
      }
      button
    }
    .background(Colors.background.swiftUIColor)
  }
}

// MARK: - View Components
private extension RainShippingAddressView {
  var content: some View {
    VStack(alignment: .leading, spacing: 32) {
      Text(
        L10N.Common.ShippingAddress.Screen.title(LFUtilities.appName.uppercased())
      )
      .foregroundColor(Colors.label.swiftUIColor)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)
      enterAddressView
    }
    .padding(.horizontal, 30)
  }
  
  func listView() -> some View {
    List(viewModel.addressList, id: \.id) { item in
      HStack(alignment: .top) {
        GenImages.CommonImages.map.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        Text("\(item.line1) \(item.state) \(item.city) \(item.postalCode)")
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
          .font(
            Fonts.regular.swiftUIFont(
              size: Constants.FontSize.small.value
            )
          )
          .padding([.top], -2)
          .padding([.leading], 5)
      }
      .padding([.leading], 2)
      .padding([.top, .bottom, .trailing], 10)
      .onTapGesture {
        viewModel.select(suggestion: item)
      }
      .listRowBackground(Colors.secondaryBackground.swiftUIColor)
      .listRowSeparatorTint(Colors.label.swiftUIColor.opacity(0.16))
      .listRowInsets(.none)
    }
    .cornerRadius(8, style: .continuous)
    .listStyle(.plain)
    .frame(maxHeight: 240, alignment: .top)
    .padding([.leading, .trailing], 20)
    .padding(.top, 95)
    .onAppear {
      UITableView.appearance().contentInset.top = -35
      UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
    }
    .floatingShadow()
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
  
  var button: some View {
    FullSizeButton(
      title: L10N.Common.ShippingAddress.Confirm.buttonTitle,
      isDisable: !viewModel.shouldEnableContinueButton
    ) {
      keyboardFocus = nil
      viewModel.saveAddress()
      dismiss()
    }
    .padding(.bottom, 16)
    .padding(.horizontal, 30)
  }
}

// MARK: - TextField
private extension RainShippingAddressView {
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
  
  var cityTextField: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.city)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterCity,
        value: $viewModel.city,
        focus: .city,
        nextFocus: .state
      )
    }
  }
  
  var stateTextField: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.state)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterState,
        value: $viewModel.state,
        limit: 2,
        restriction: .alphabets,
        focus: .state,
        nextFocus: .zip
      )
    }
  }
  
  var zipCodeTextField: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.zipcode)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .multilineTextAlignment(.leading)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterZipcode,
        value: $viewModel.zipCode,
        limit: 11,
        keyboardType: .numberPad,
        focus: .zip
      )
    }
  }
  
  var mainAddressTextField: some View {
    VStack(alignment: .leading) {
      Text(L10N.Common.addressLine1Title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterAddress,
        value: $viewModel.mainAddress,
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
      Text(L10N.Common.addressLine2Title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.top, 16)
        .padding(.leading, 4)
      
      textField(
        placeholder: L10N.Common.enterAddress,
        value: $viewModel.subAddress,
        focus: .address2,
        nextFocus: .city
      )
    }
  }
}
