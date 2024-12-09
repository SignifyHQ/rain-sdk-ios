import Combine
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services
import Factory

struct AddressView: View {
  @Environment(\.dismiss) var dismiss
  @FocusState var keyboardFocus: Focus?
  @StateObject private var viewModel = AddressViewModel()
  
  @State private var scrollViewFrame: CGRect = .zero
  @State private var countryDropdownFrame: CGRect = .zero
  @State private var stateDropdownFrame: CGRect = .zero
  
  init() {
    UITableView.appearance().backgroundColor = UIColor(Colors.background.swiftUIColor)
    UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
  }
  
  var body: some View {
    VStack {
      ScrollViewReader { proxy in
        ZStack {
          ScrollView {
            VStack(alignment: .leading) {
              Text(L10N.Common.addressTitle)
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
                .padding(.vertical, 16)
              
              textFieldView
            }
            .onChange(of: keyboardFocus) {
              proxy.scrollTo($0)
            }
            .padding(.horizontal, 32)
          }
          .readGeometry { geometry in
            scrollViewFrame = geometry.frame(in: .global)
          }
          .scrollDisabled(viewModel.isShowingCountrySelection || viewModel.isShowingStateSelection)
          
          if viewModel.isShowingCountrySelection {
            countryDropdownView()
              .frame(
                width: countryDropdownFrame.width,
                height: countryDropdownFrame.height * 3,
                alignment: .top
              )
              .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
              .position(
                x: countryDropdownFrame.midX,
                y: countryDropdownFrame.maxY + countryDropdownFrame.height * 3 / 2 - scrollViewFrame.minY
              )
          }
          
          if viewModel.isShowingStateSelection {
            stateDropdownView()
              .frame(
                width: stateDropdownFrame.width,
                height: stateDropdownFrame.height * 2,
                alignment: .top
              )
              .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
              .position(
                x: stateDropdownFrame.midX,
                y: stateDropdownFrame.maxY + stateDropdownFrame.height * 2 / 2 - scrollViewFrame.minY
              )
          }
        }
      }
      
      continueButton
    }
    .navigationTitle("")
    .background(Colors.background.swiftUIColor)
    .onTapGesture {
      viewModel.stopSuggestions()
      viewModel.isShowingCountrySelection = false
      viewModel.isShowingStateSelection = false
    }
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      }
    )
    .popup(
      item: $viewModel.toastMessage,
      style: .toast
    ) {
      ToastView(toastMessage: $0)
    }
    .popup(item: $viewModel.popup) { item in
      switch item {
      case let .waitlist(message):
        waitlistPopup(message: message)
      case .waitlistJoined:
        waitlistJoinedPopup
      }
    }
    .onAppear {
      viewModel.onAppear()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        keyboardFocus = .address1
      }
    }
    .navigationBarBackButtonHidden(viewModel.isLoading)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension AddressView {
  func listView() -> some View {
    List(viewModel.addressList, id: \.id) { item in
      HStack(alignment: .top) {
        GenImages.CommonImages.map.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        Text("\(item.addressline1) \(item.state) \(item.city) \(item.zipcode)")
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
  
  func textFieldInputView(
    title: String,
    placeholder: String,
    value: Binding<String>,
    limit: Int = 200,
    restriction: TextRestriction = .none,
    keyboardType: UIKeyboardType = .alphabet,
    focus: Focus,
    nextFocus: Focus? = nil
  ) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.leading, 4)
      
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
  
  var textFieldView: some View {
    VStack(alignment: .leading, spacing: 20) {
      textFieldInputView(
        title: L10N.Common.addressLine1Title,
        placeholder: L10N.Common.enterAddress,
        value: $viewModel.addressLine1,
        focus: .address1,
        nextFocus: .address2
      )
      
      textFieldInputView(
        title: L10N.Common.addressLine2Title,
        placeholder: L10N.Common.enterAddress,
        value: $viewModel.addressLine2,
        focus: .address2,
        nextFocus: .city
      )
      
      textFieldInputView(
        title: L10N.Common.city,
        placeholder: L10N.Common.enterCity,
        value: $viewModel.city,
        focus: .city,
        nextFocus: .country
      )
      
      ZStack {
        textFieldInputView(
          title: L10N.Common.country,
          placeholder: L10N.Common.enterCountry,
          value: $viewModel.selectedCountryTitle,
          focus: .country,
          nextFocus: .state
        )
        .disabled(true)
        
        HStack {
          Rectangle()
            .foregroundStyle(
              Color.clear
            )
            .contentShape(Rectangle())
            .onTapGesture {
              keyboardFocus = nil
              viewModel.isShowingStateSelection = false
              viewModel.isShowingCountrySelection.toggle()
            }
          
          GenImages.CommonImages.icArrowDown.swiftUIImage
            .tint(Colors.label.swiftUIColor)
            .rotationEffect(
              .degrees(viewModel.isShowingCountrySelection ? 180 : 0)
            )
        }
      }
      .readGeometry { geometry in
        countryDropdownFrame = geometry.frame(in: .global)
      }
      
      HStack {
        ZStack {
          textFieldInputView(
            title: L10N.Common.state,
            placeholder: L10N.Common.enterState,
            value: $viewModel.state,
            restriction: .alphabets,
            focus: .state,
            nextFocus: .zip
          )
          .disabled(viewModel.shouldUseStateDropdown)
          
          if viewModel.shouldUseStateDropdown {
            HStack {
              Rectangle()
                .foregroundStyle(
                  Color.clear
                )
                .contentShape(Rectangle())
                .onTapGesture {
                  keyboardFocus = nil
                  viewModel.isShowingCountrySelection = false
                  viewModel.isShowingStateSelection.toggle()
                }
              
              GenImages.CommonImages.icArrowDown.swiftUIImage
                .tint(Colors.label.swiftUIColor)
                .rotationEffect(
                  .degrees(viewModel.isShowingStateSelection ? 180 : 0)
                )
            }
          }
        }
        .readGeometry { geometry in
          stateDropdownFrame = geometry.frame(in: .global)
        }
        
        Spacer(minLength: 25)
        
        textFieldInputView(
          title: L10N.Common.zipcode,
          placeholder: L10N.Common.enterZipcode,
          value: $viewModel.zipCode,
          limit: 11,
          keyboardType: .numberPad,
          focus: .zip
        )
      }
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: !viewModel.shouldEnableContinueButton,
      isLoading: $viewModel.isLoading,
      type: .primary
    ) {
      viewModel.isShowingCountrySelection = false
      viewModel.isShowingStateSelection = false
      keyboardFocus = nil
      
      viewModel.onContinueButtonTapped()
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 12)
  }
  
  func waitlistPopup(message: String) -> some View {
    LiquidityAlert(
      title: L10N.Common.accountUpdate,
      message: message,
      primary: .init(text: L10N.Common.joinWaitlist) {
        viewModel.joinWaitlist()
      },
      secondary: .init(text: L10N.Common.cancelAccount) {
        viewModel.logout()
      }
    )
  }
  
  var waitlistJoinedPopup: some View {
    LiquidityAlert(
      title: L10N.Common.waitlistJoinedTitle,
      message: L10N.Common.waitlistJoinedMessage,
      primary: .init(text: L10N.Common.Button.Ok.title.uppercased()) {
        viewModel.logout()
      }
    )
  }
  
  func countryDropdownView(
  ) -> some View {
    List(
      viewModel.countryCodeList,
      id: \.id
    ) { item in
      HStack {
        Text(item.flagEmoji())
          .padding(.leading, -5)
        
        Text(item.title)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.leading, 12)
          .layoutPriority(1)
        
        // Adding clear rectangle to make the whole row tappable, not just the text
        Rectangle()
          .foregroundStyle(
            Color.clear
          )
          .contentShape(Rectangle())
      }
      .listRowBackground(Color.clear)
      .listRowSeparatorTint(Colors.label.swiftUIColor.opacity(0.16))
      .listRowInsets(.none)
      .onTapGesture {
        viewModel.selectedCountry = item
        viewModel.isShowingCountrySelection = false
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .floatingShadow()
  }
  
  func stateDropdownView(
  ) -> some View {
    List(
      viewModel.stateList,
      id: \.id
    ) { item in
      HStack {
        Text(item.name)
          .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .lineLimit(1)
          .layoutPriority(1)
        
        // Adding clear rectangle to make the whole row tappable, not just the text
        Rectangle()
          .foregroundStyle(
            Color.clear
          )
          .contentShape(Rectangle())
      }
      .listRowBackground(Color.clear)
      .listRowSeparatorTint(Colors.label.swiftUIColor.opacity(0.16))
      .listRowInsets(.none)
      .onTapGesture {
        viewModel.selectedState = item
        viewModel.isShowingStateSelection = false
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .floatingShadow()
  }
}

// MARK: - Focus Keyboard
extension AddressView {
  enum Focus: Int, Hashable {
    case address1
    case address2
    case city
    case country
    case state
    case zip
  }
}

#if DEBUG
struct AddressView_Previews: PreviewProvider {
  static var previews: some View {
    AddressView()
      .previewLayout(PreviewLayout.sizeThatFits)
      .previewDisplayName("Default preview")
  }
}
#endif
