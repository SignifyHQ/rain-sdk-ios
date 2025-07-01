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
  @State private var vStackFrame: CGRect = .zero
  @State private var addressDropdownFrame: CGRect = .zero
  @State private var countryDropdownFrame: CGRect = .zero
  @State private var stateDropdownFrame: CGRect = .zero
  
  @State private var additionalScrollHeight: CGFloat = .zero
  
  @State private var popupFrame: CGRect = .zero
  @State private var waitlistStateDropdownFrame: CGRect = .zero
  
  init() {
    UITableView.appearance().backgroundColor = UIColor(Colors.background.swiftUIColor)
    UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
  }
  
  var body: some View {
    ZStack {
      VStack {
        ScrollViewReader { proxy in
          ScrollView {
            VStack(alignment: .leading) {
              Text(L10N.Common.addressTitle)
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
                .padding(.vertical, 16)
              
              if viewModel.selectedCountry == .US {
                blockedStateInfoView
              }
              
              textFieldView
              
              if viewModel.isShowingStateSelection {
                Spacer()
                  .frame(height: additionalScrollHeight)
                  .id("id-spacer")
              }
            }
            .readGeometry { geometry in
              vStackFrame = geometry.frame(in: .global)
            }
            .onChange(of: keyboardFocus) {
              proxy.scrollTo($0)
            }
            .onChange(
              of: viewModel.isShowingStateSelection
            ) { isShowingStateSelection in
              if isShowingStateSelection {
                withAnimation(.easeInOut(duration: 0.3)) {
                  proxy.scrollTo("id-spacer")
                }
              }
            }
            .padding(.horizontal, 32)
          }
          .readGeometry { geometry in
            scrollViewFrame = geometry.frame(in: .global)
          }
        }
        
        continueButton
      }
      .simultaneousGesture(
        TapGesture()
          .onEnded {
            viewModel.isShowingAddressSuggestions = false
            viewModel.isShowingCountrySelection = false
            viewModel.isShowingStateSelection = false
            viewModel.shouldPresentGetNotifiedPopup = false
          }
      )
      
      if viewModel.isShowingAddressSuggestions {
        addressDropdownView()
          .frame(
            width: addressDropdownFrame.width,
            height: addressDropdownFrame.height * 3,
            alignment: .top
          )
          .background(Colors.secondaryBackground.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 9))
          .position(
            x: addressDropdownFrame.midX,
            y: addressDropdownFrame.maxY + addressDropdownFrame.height * 3 / 2 - scrollViewFrame.minY + 5
          )
      }
      
      if viewModel.isShowingCountrySelection {
        countryDropdownView()
          .frame(
            width: countryDropdownFrame.width,
            height: countryDropdownFrame.height * 3,
            alignment: .top
          )
          .background(Colors.secondaryBackground.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 9))
          .position(
            x: countryDropdownFrame.midX,
            y: countryDropdownFrame.maxY + countryDropdownFrame.height * 3 / 2 - scrollViewFrame.minY + 5
          )
      }
      
      if viewModel.isShowingStateSelection {
        stateDropdownView()
          .frame(
            width: stateDropdownFrame.width + 10,
            height: stateDropdownFrame.height * 3,
            alignment: .top
          )
          .background(Colors.secondaryBackground.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 9))
          .position(
            x: stateDropdownFrame.midX,
            y: stateDropdownFrame.maxY + stateDropdownFrame.height * 3 / 2 - scrollViewFrame.minY + 5
          )
      }
    }
    .navigationTitle("")
    .background(Colors.background.swiftUIColor)
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
    .popup(
      isPresented: $viewModel.shouldPresentGetNotifiedPopup,
      content: {
        PopupAlert(padding: 16) {
          getNotifiedView()
        }
        .readGeometry { popup in
          popupFrame = popup.frame(in: .global)
        }
      }
    )
    .onAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        let dropdownMaxY = countryDropdownFrame.maxY + countryDropdownFrame.height * 3
        let scrollViewMaxY = scrollViewFrame.maxY - scrollViewFrame.minY
        let overflowHeight = dropdownMaxY - scrollViewMaxY
        
        additionalScrollHeight = overflowHeight + (scrollViewFrame.height - vStackFrame.height)
      }
      
      viewModel.onAppear()
    }
    .navigationLink(
      isActive: $viewModel.shouldProceedToNextStep,
      destination: {
        CompleteYourProfileView()
      }
    )
    .navigationBarBackButtonHidden(viewModel.isLoading)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension AddressView {
//  func listView() -> some View {
//    List(viewModel.addressList, id: \.id) { item in
//      HStack(alignment: .top) {
//        GenImages.CommonImages.map.swiftUIImage
//          .foregroundColor(Colors.label.swiftUIColor)
//        Text("\(item.addressline1) \(item.state) \(item.city) \(item.zipcode)")
//          .foregroundColor(Colors.label.swiftUIColor)
//          .opacity(0.75)
//          .font(
//            Fonts.regular.swiftUIFont(
//              size: Constants.FontSize.small.value
//            )
//          )
//          .padding([.top], -2)
//          .padding([.leading], 5)
//      }
//      .padding([.leading], 2)
//      .padding([.top, .bottom, .trailing], 10)
//      .onTapGesture {
//        viewModel.select(suggestion: item)
//      }
//      .listRowBackground(Colors.secondaryBackground.swiftUIColor)
//      .listRowSeparatorTint(Colors.label.swiftUIColor.opacity(0.16))
//      .listRowInsets(.none)
//    }
//    .cornerRadius(8, style: .continuous)
//    .listStyle(.plain)
//    .frame(maxHeight: 240, alignment: .top)
//    .padding([.leading, .trailing], 20)
//    .padding(.top, 95)
//    .onAppear {
//      UITableView.appearance().contentInset.top = -35
//      UITableView.appearance().separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
//    }
//    .floatingShadow()
//  }
  
  func textFieldInputView(
    title: String,
    placeholder: String,
    value: Binding<String>,
    limit: Int = 200,
    restriction: TextRestriction = .none,
    keyboardType: UIKeyboardType = .alphabet,
    lowercased: Bool = false,
    isLoading: Binding<Bool> = .constant(false),
    focus: Focus,
    nextFocus: Focus? = nil
  ) -> some View {
    VStack(alignment: .leading) {
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .padding(.leading, 4)
      
      TextFieldWrapper(
        isLoading: isLoading
      ) {
        TextField("", text: value)
          .keyboardType(keyboardType)
          .restrictInput(value: value, restriction: restriction)
          .multilineTextAlignment(.leading)
          .modifier(PlaceholderStyle(showPlaceHolder: value.wrappedValue.isEmpty, placeholder: placeholder))
          .primaryFieldStyle()
          .autocorrectionDisabled()
          .limitInputLength(value: value, length: limit)
          .submitLabel(nextFocus == nil ? .done : .next)
          .focused($keyboardFocus, equals: focus)
          .onSubmit {
            viewModel.isShowingAddressSuggestions = false
            keyboardFocus = nextFocus
          }
          .onChange(
            of: value.wrappedValue
          ) { newValue in
            if lowercased {
              value.wrappedValue = newValue.lowercased()
            }
          }
      }
    }
  }
  
  var blockedStateInfoView: some View {
    HStack(
      alignment: .top
    ) {
      GenImages.CommonImages.icInfo.swiftUIImage
      
      Text(L10N.Common.YourAddress.Waitlist.Disclosure.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Colors.buttons.swiftUIColor)
    )
    .padding(.bottom, 16)
  }
  
  var textFieldView: some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack {
        textFieldInputView(
          title: L10N.Common.addressLine1Title,
          placeholder: L10N.Common.enterAddress,
          value: $viewModel.addressLine1,
          isLoading: $viewModel.isAddressComponentsLoading,
          focus: .address1,
          nextFocus: .address2
        )
      }
      .onTapGesture {
        viewModel.isShowingStateSelection = false
        viewModel.isShowingCountrySelection = false
      }
      .readGeometry { geometry in
        addressDropdownFrame = geometry.frame(in: .global)
      }
      
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
          keyboardType: .default,
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
  
  func addressDropdownView(
  ) -> some View {
    List(
      viewModel.addressSuggestionList,
      id: \.id
    ) { item in
      HStack {
        GenImages.CommonImages.map.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.leading, -5)
        
        Text(item.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .layoutPriority(1)
        
        // Adding clear rectangle to make the whole row tappable, not just the text
        Rectangle()
          .foregroundStyle(
            Color.clear
          )
          .contentShape(Rectangle())
      }
      .listRowBackground(Color.clear)
      .listRowSeparatorTint(Color.clear)
      .listRowInsets(.none)
      .onTapGesture {
        viewModel.select(suggestion: item)
      }
    }
    .environment(\.defaultMinListRowHeight, 35)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .floatingShadow()
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
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .layoutPriority(1)
        
        // Adding clear rectangle to make the whole row tappable, not just the text
        Rectangle()
          .foregroundStyle(
            Color.clear
          )
          .contentShape(Rectangle())
      }
      .listRowBackground(Color.clear)
      .listRowSeparatorTint(Color.clear)
      .listRowInsets(.none)
      .onTapGesture {
        viewModel.selectedCountry = item
        viewModel.isShowingCountrySelection = false
      }
    }
    .environment(\.defaultMinListRowHeight, 35)
    .scrollContentBackground(.hidden)
    .listStyle(.plain)
    .floatingShadow()
  }
  
  func stateDropdownView(
  ) -> some View {
    VStack {
      List(
        viewModel.isShowingWaitlistStateSelection ? viewModel.unsupportedStateList : viewModel.stateList,
        id: \.id
      ) { item in
        HStack {
          Text(item.name)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.label.swiftUIColor)
            .padding(.leading, 8)
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
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
        .onTapGesture {
          if viewModel.isShowingStateSelection {
            viewModel.selectedState = item
            viewModel.isShowingStateSelection = false
          }
          
          if viewModel.isShowingWaitlistStateSelection {
            viewModel.selectedWaitlistState = item
            viewModel.isShowingWaitlistStateSelection = false
          }
        }
      }
      .environment(\.defaultMinListRowHeight, 30)
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      
      if viewModel.isShowingStateSelection {
        Rectangle()
          .frame(height: 1)
          .foregroundColor(.black)
          .opacity(0.2)
        
        Text(L10N.Common.YourAddress.Waitlist.GetNotifiedRow.title)
          .foregroundColor(Colors.primary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .multilineTextAlignment(.leading)
          .padding(.bottom, 8)
          .padding(.horizontal, 8)
          .onTapGesture {
            viewModel.isShowingStateSelection = false
            viewModel.shouldPresentGetNotifiedPopup = true
          }
      }
    }
    .floatingShadow()
  }
  
  @ViewBuilder
  func getNotifiedView(
  ) -> some View {
    ZStack {
      VStack {
        VStack(
          spacing: 24
        ) {
          GenImages.Images.icLogo.swiftUIImage
            .resizable()
            .frame(width: 100, height: 100)
          
          Text(L10N.Common.YourAddress.Waitlist.GetNotifiedPopup.title.uppercased())
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
            .foregroundColor(Colors.label.swiftUIColor)
            .multilineTextAlignment(.center)
          
          ZStack {
            textFieldInputView(
              title: L10N.Common.YourAddress.Waitlist.GetNotifiedPopup.YourState.title,
              placeholder: L10N.Common.YourAddress.Waitlist.GetNotifiedPopup.YourState.placeholder,
              value: $viewModel.waitlistState,
              restriction: .alphabets,
              focus: .waitlistState
            )
            .disabled(true)
            
            HStack {
              Rectangle()
                .foregroundStyle(
                  Color.clear
                )
                .contentShape(Rectangle())
                .onTapGesture {
                  viewModel.isShowingWaitlistStateSelection.toggle()
                }
              
              GenImages.CommonImages.icArrowDown.swiftUIImage
                .tint(Colors.label.swiftUIColor)
                .rotationEffect(
                  .degrees(viewModel.isShowingWaitlistStateSelection ? 180 : 0)
                )
            }
          }
          .readGeometry { geometry in
            waitlistStateDropdownFrame = geometry.frame(in: .global)
          }
          
          textFieldInputView(
            title: L10N.Common.email,
            placeholder: L10N.Common.enterEmailAddress,
            value: $viewModel.waitlistEmail,
            lowercased: true,
            focus: .waitlistEmail
          )
        }
        .padding(.top, 8)
        .padding(.bottom, 24)
        
        FullSizeButton(
          title: L10N.Common.YourAddress.Waitlist.GetNotifiedPopup.NotifyButton.title,
          isDisable: !viewModel.isWaitlistButtonActive,
          isLoading: $viewModel.isLoadingWaitlist,
          type: .primary
        ) {
          viewModel.joinWaitlist()
        }
        
        FullSizeButton(
          title: L10N.Common.Button.Cancel.title,
          isDisable: false,
          type: .secondary
        ) {
          viewModel.shouldPresentGetNotifiedPopup = false
        }
      }
      .onTapGesture {
        viewModel.isShowingWaitlistStateSelection = false
      }
      
      if viewModel.isShowingWaitlistStateSelection {
        stateDropdownView()
          .frame(
            width: waitlistStateDropdownFrame.width + 10,
            height: waitlistStateDropdownFrame.height * 3,
            alignment: .top
          )
          .background(Colors.background.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 9))
          .position(
            x: waitlistStateDropdownFrame.midX - popupFrame.minX - 16,
            y: waitlistStateDropdownFrame.maxY + waitlistStateDropdownFrame.height * 3 / 2 - popupFrame.minY - 16
          )
      }
    }
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
    case waitlistState
    case waitlistEmail
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
