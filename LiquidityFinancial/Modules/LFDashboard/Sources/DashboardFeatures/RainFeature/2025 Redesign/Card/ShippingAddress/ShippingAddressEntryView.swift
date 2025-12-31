import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct ShippingAddressEntryView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject var viewModel: ShippingAddressEntryViewModel
  
  @State private var scrollViewFrame: CGRect = .zero
  @State private var addressSuggestionsDropdownFrame: CGRect = .zero
  @State private var stateDropdownFrame: CGRect = .zero
  @State private var countryDropdownFrame: CGRect = .zero
  @State private var leaveBlancTextFrame: CGRect = .zero
  
  @FocusState private var focusedField: FocusedField?
  @FocusState private var focusedSearchBar: FocusedSearchBar?
  
  private let DROPDOWN_HEADER_HEIGHT: CGFloat = 52
  private let DROPDOWN_ROW_HEIGHT: CGFloat = 36
  private let DROPDOWN_EMPTY_VIEW_HEIGHT: CGFloat = 50
  // Calculate the address dropdown height based on the number of rows
  private var addressDropdownHeight: CGFloat {
    CGFloat
      .dropdownHeight(
        rowCount: viewModel.addressSuggestionList.count,
        rowHeight: DROPDOWN_ROW_HEIGHT * 1.5,
        headerHeight: DROPDOWN_HEADER_HEIGHT,
        emptyViewHeight: DROPDOWN_EMPTY_VIEW_HEIGHT,
        fallbackOveralHeight: addressSuggestionsDropdownFrame.width * 0.7
      )
  }
  // Calculate the country dropdown height based on the number of rows
  private var countryDropdownHeight: CGFloat {
    CGFloat
      .dropdownHeight(
        rowCount: viewModel.countryList.count,
        rowHeight: DROPDOWN_ROW_HEIGHT,
        headerHeight: DROPDOWN_HEADER_HEIGHT,
        emptyViewHeight: DROPDOWN_EMPTY_VIEW_HEIGHT,
        fallbackOveralHeight: countryDropdownFrame.width * 0.7
      )
  }
  // Calculate the state dropdown height based on the number of rows
  private var stateDropdownHeight: CGFloat {
    CGFloat
      .dropdownHeight(
        rowCount: viewModel.stateListFiltered.count,
        rowHeight: DROPDOWN_ROW_HEIGHT,
        headerHeight: DROPDOWN_HEADER_HEIGHT,
        emptyViewHeight: DROPDOWN_EMPTY_VIEW_HEIGHT,
        fallbackOveralHeight: stateDropdownFrame.width * 0.7
      )
  }
  
  public init(
    viewModel: ShippingAddressEntryViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack(
        spacing: 24
      ) {
        contentView
        buttonGroup
      }
      .padding(.top, 4)
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
      // Adding content shape to make sure the whole screen is tappable
      .contentShape(Rectangle())
      .onTapGesture {
        viewModel.hideSelections()
        focusedField = nil
      }
      .readGeometry { proxy in
        scrollViewFrame = proxy.frame(in: .global)
      }
      
      if viewModel.isShowingAddressSuggestions {
        addressSuggestionDropdownView()
          .frame(
            width: addressSuggestionsDropdownFrame.width,
            height: addressDropdownHeight,
            alignment: .top
          )
          .background(Colors.backgroundLight.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .position(
            x: addressSuggestionsDropdownFrame.midX,
            // Calculate the dropdown Y position
            // Adding 4 to account for VStack vertical padding
            // Adding 8 as top padding of the dropdown
            y: addressSuggestionsDropdownFrame.maxY - scrollViewFrame.minY + addressDropdownHeight / 2 + 8
          )
      }
      
      if viewModel.isShowingStateSelection {
        stateDropdownView()
          .frame(
            width: stateDropdownFrame.width,
            height: stateDropdownHeight,
            alignment: .top
          )
          .background(Colors.backgroundLight.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .position(
            x: stateDropdownFrame.midX,
            // Calculate the dropdown Y position
            // Adding 4 to account for VStack vertical padding
            // Adding 8 as top padding of the dropdown
            y: stateDropdownFrame.maxY - scrollViewFrame.minY + stateDropdownHeight / 2 + 8
          )
      }
      
      if viewModel.isShowingCountrySelection {
        countryDropdownView()
          .frame(
            width: countryDropdownFrame.width,
            height: countryDropdownHeight,
            alignment: .top
          )
          .background(Colors.backgroundLight.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .position(
            x: countryDropdownFrame.midX,
            // Calculate the dropdown Y position
            // Adding 4 to account for VStack vertical padding
            // Adding 8 as top padding of the dropdown
            y: countryDropdownFrame.maxY - scrollViewFrame.minY + countryDropdownHeight / 2 + 8
          )
      }
    }
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(navigationTitle: L10N.Common.OrderPhysicalCard.Screen.title)
    .toast(
      data: $viewModel.currentToast
    )
    .onChange(
      of: focusedField,
      perform: { newValue in
        if newValue != nil {
          viewModel.hideSelections()
        }
      }
    )
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        switch navigation {
        case .cardOrderConfirmation:
          if let shippingAddress = self.viewModel.shippingAddress {
            ShippingAddressConfirmationView(viewModel: ShippingAddressConfirmationViewModel(shippingAddress: shippingAddress, onOrderSuccess: viewModel.onOrderSuccess))
          }
        }
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension ShippingAddressEntryView {
  var contentView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(
          alignment: .leading,
          spacing: 24
        ) {
          cardShippingView
          inputTitleView
          addressLine1InputView
          addressLine2InputView
          
          VStack(
            alignment: .leading,
            spacing: 24
          ) {
            cityInputView
            
            HStack(
              spacing: 16
            ) {
              stateInputView
              zipInputView
            }
            .readGeometry { geometry in
              stateDropdownFrame = geometry.frame(in: .global)
            }
            
            countryInputView
            
            // Add a spacer equal to the dropdown height when it’s shown
            // so the ScrollView can expand and scroll fully to display the dropdown.
            if viewModel.isShowingStateSelection || viewModel.isShowingCountrySelection {
              let spacerHeight = (viewModel.isShowingCountrySelection ? countryDropdownHeight : stateDropdownHeight) - 24 + 8
              - ((viewModel.isShowingStateSelection) ? (stateDropdownFrame.height + 24 - 8 - leaveBlancTextFrame.height) : 0)
              
              Spacer()
                .frame(
                  height: max(spacerHeight, 0)
                )
                .id("id-spacer")
            }
            
            Spacer()
          }
          .allowsHitTesting(viewModel.isFreeInputEnabled)
          .opacity(viewModel.isFreeInputEnabled ? 1 : 0.5)
          
          Spacer()
        }
        .onChange(
          of: focusedSearchBar
        ) { focus in
          guard focus != nil
          else {
            return
          }
          
          DispatchQueue.main.asyncAfter(
            deadline: .now() + 0.4
          ) {
            withAnimation(
              .easeInOut(
                duration: 0.3
              )
            ) {
              proxy.scrollTo("id-spacer")
            }
          }
        }
      }
      .frame(
        maxWidth: .infinity
      )
      .scrollIndicators(.hidden)
    }
  }
  
  var cardShippingView: some View {
    VStack(alignment: .center, spacing: 24) {
      GenImages.Images.physicalCardBackdrop.swiftUIImage
        .resizable()
        .frame(width: 88, height: 140)
      
      Text(L10N.Common.ShippingAddressConfirmation.PhysicalCard.subtitle)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.textSecondary.swiftUIColor)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity)
  }
  
  var inputTitleView: some View {
    Text(L10N.Common.ShippingAddressEntry.title(LFUtilities.appName))
      .foregroundColor(Colors.textPrimary.swiftUIColor)
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
      .multilineTextAlignment(.leading)
  }
  
  var addressLine1InputView: some View {
    DefaultTextField(
      title: L10N.Common.ShippingAddressEntry.MainAddress.title,
      placeholder: L10N.Common.ShippingAddressEntry.Address.placeholder,
      value: $viewModel.addressLine1,
      autoCapitalization: .sentences,
      isloading: $viewModel.areAddressComponentsLoading
    )
    .focused($focusedField, equals: .addressLine1)
    .readGeometry { geometry in
      addressSuggestionsDropdownFrame = geometry.frame(in: .global)
    }
  }
  
  
  func addressSuggestionDropdownView(
  ) -> some View {
    VStack(
      spacing: 0
    ) {
      HStack(
        spacing: 10
      ) {
        GenImages.Images.icoGoogle.swiftUIImage
        
        Text("Powered by Google")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundStyle(Colors.titleSecondary.swiftUIColor)
        
        Spacer()
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 12)
      .frame(height: DROPDOWN_HEADER_HEIGHT)
      
      Divider()
        .background(Colors.backgroundSecondary.swiftUIColor)
      
      List(
        viewModel.addressSuggestionList,
        id: \.id
      ) { item in
        VStack(
          spacing: 0
        ) {
          HStack(
            alignment: .center,
            spacing: 10
          ) {
            GenImages.Images.icoAddress.swiftUIImage
            
            Text(item.title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .lineLimit(2)
              .layoutPriority(1)
            
            // Adding clear rectangle to make the whole row tappable, not just the text
            Rectangle()
              .foregroundStyle(
                Color.clear
              )
              .contentShape(Rectangle())
          }
          .padding(.vertical, 16)
          .padding(.horizontal, 10)
          
          Divider()
            .background(Colors.backgroundSecondary.swiftUIColor)
            .padding(.horizontal, 10)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.zero)
        .onTapGesture {
          viewModel.onSuggestionSelected(suggestion: item)
          viewModel.isShowingAddressSuggestions = false
        }
      }
      .environment(\.defaultMinListRowHeight, DROPDOWN_ROW_HEIGHT * 1.5)
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      
      // Show no results message if the filtered list is empty
      if viewModel.addressSuggestionList.isEmpty {
        HStack {
          Spacer()
          
          Text("No results found")
            .foregroundStyle(Colors.textSecondary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(height: DROPDOWN_EMPTY_VIEW_HEIGHT)
      }
    }
    .floatingShadow()
  }
  
  var addressLine2InputView: some View {
    DefaultTextField(
      title: L10N.Common.ShippingAddressEntry.AdditionalAddress.title,
      placeholder: L10N.Common.ShippingAddressEntry.AdditionalAddress.placeholder,
      value: $viewModel.addressLine2,
      autoCapitalization: .sentences
    )
    .focused($focusedField, equals: .addressLine2)
  }
  
  var stateInputView: some View {
    ZStack {
      VStack(spacing: 8) {
        DefaultTextField(
          title: L10N.Common.ShippingAddressEntry.State.title,
          placeholder: viewModel.selectedCountry?.isUnitedStates == true ? "Select state" : "Enter state/region",
          value: $viewModel.selectedStateDisplayValue
        )
        .disabled(viewModel.selectedCountry?.isUnitedStates == true)
        
        if viewModel.isFreeInputEnabled {
          Text("Leave blank if not applicable")
            .foregroundStyle(Colors.textTertiary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .readGeometry { proxy in
              leaveBlancTextFrame = proxy.frame(in: .global)
            }
        }
      }
      
      if viewModel.selectedCountry?.isUnitedStates == true {
        HStack {
          Rectangle()
            .foregroundStyle(
              Color.clear
            )
            .contentShape(Rectangle())
            .highPriorityGesture(
              TapGesture()
                .onEnded {
                  focusedField = nil
                  
                  viewModel.isShowingCountrySelection = false
                  viewModel.isShowingAddressSuggestions = false
                  
                  viewModel.isShowingStateSelection.toggle()
                }
            )
          
          if viewModel.isFreeInputEnabled {
            GenImages.Images.icoExpandDown.swiftUIImage
              .rotationEffect(
                .degrees(viewModel.isShowingStateSelection ? -180 : 0)
              )
              .animation(
                .easeOut(
                  duration: 0.2
                ),
                value: viewModel.isShowingStateSelection
              )
          }
        }
      }
    }
  }
  
  var countryInputView: some View {
    ZStack {
      DefaultTextField(
        title: L10N.Common.ShippingAddressEntry.Country.title,
        placeholder: L10N.Common.ShippingAddressEntry.Country.placeholder,
        value: $viewModel.selectedCountryDisplayValue
      )
      .disabled(true)
      
      HStack {
        Rectangle()
          .foregroundStyle(
            Color.clear
          )
          .contentShape(Rectangle())
          .highPriorityGesture(
            TapGesture()
              .onEnded {
                focusedField = nil
                
                viewModel.isShowingStateSelection = false
                viewModel.isShowingAddressSuggestions = false
                
                viewModel.isShowingCountrySelection.toggle()
              }
          )
        
        if viewModel.isFreeInputEnabled {
          GenImages.Images.icoExpandDown.swiftUIImage
            .rotationEffect(
              .degrees(viewModel.isShowingCountrySelection ? -180 : 0)
            )
            .animation(
              .easeOut(
                duration: 0.2
              ),
              value: viewModel.isShowingCountrySelection
            )
        }
      }
    }
    .readGeometry { geometry in
      countryDropdownFrame = geometry.frame(in: .global)
    }
  }
  
  func stateDropdownView(
  ) -> some View {
    VStack(
      spacing: 0
    ) {
      HStack(
        spacing: 4
      ) {
        Image(
          systemName: "magnifyingglass"
        )
        .foregroundColor(Colors.backgroundLight.swiftUIColor)
        
        TextField(
          "Search state",
          text: $viewModel.stateSearchQuery
        )
        .focused($focusedSearchBar, equals: .state)
        .textFieldStyle(PlainTextFieldStyle())
        .submitLabel(.done)
        .tint(Colors.backgroundLight.swiftUIColor)
      }
      .padding(8)
      .background(Colors.backgroundDark.swiftUIColor)
      .cornerRadius(8)
      .padding(8)
      .frame(height: DROPDOWN_HEADER_HEIGHT)
      
      Divider()
        .background(Colors.backgroundSecondary.swiftUIColor)
      
      List(
        viewModel.stateListFiltered,
        id: \.id
      ) { item in
        HStack {
          Text(item.name)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .lineLimit(1)
            .layoutPriority(1)
          
          // Adding clear rectangle to make the whole row tappable, not just the text
          Rectangle()
            .foregroundStyle(
              Color.clear
            )
            .contentShape(Rectangle())
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.zero)
        .onTapGesture {
          if viewModel.isShowingStateSelection {
            viewModel.selectedState = item
            viewModel.isShowingStateSelection = false
          }
        }
      }
      .environment(\.defaultMinListRowHeight, DROPDOWN_ROW_HEIGHT)
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      
      // Show no results message if the filtered list is empty
      if viewModel.stateListFiltered.isEmpty {
        HStack(
          alignment: .top,
          spacing: 8
        ) {
          Spacer()
          
          Text("No results found")
            .foregroundStyle(Colors.textSecondary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(height: DROPDOWN_EMPTY_VIEW_HEIGHT)
      }
    }
    .floatingShadow()
  }
  
  func countryDropdownView(
  ) -> some View {
    VStack(
      spacing: 0
    ) {
      HStack(
        spacing: 4
      ) {
        Image(
          systemName: "magnifyingglass"
        )
        .foregroundColor(Colors.backgroundLight.swiftUIColor)
        
        TextField(
          "Search country",
          text: $viewModel.countrySearchQuery
        )
        .focused($focusedSearchBar, equals: .country)
        .textFieldStyle(PlainTextFieldStyle())
        .submitLabel(.done)
        .tint(Colors.backgroundLight.swiftUIColor)
      }
      .padding(8)
      .background(Colors.backgroundDark.swiftUIColor)
      .cornerRadius(8)
      .padding(8)
      .frame(height: DROPDOWN_HEADER_HEIGHT)
      
      Divider()
        .background(Colors.backgroundSecondary.swiftUIColor)
      
      List(
        viewModel.countryList,
        id: \.id
      ) { item in
        HStack(
          spacing: 4
        ) {
          Text(item.flagEmoji())
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          Text(item.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .lineLimit(1)
            .layoutPriority(1)
          
          // Adding clear rectangle to make the whole row tappable, not just the text
          Rectangle()
            .foregroundStyle(
              Color.clear
            )
            .contentShape(Rectangle())
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .padding(.horizontal, 10)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.zero)
        .onTapGesture {
          viewModel.selectedCountry = item
          viewModel.isShowingCountrySelection = false
        }
      }
      .environment(\.defaultMinListRowHeight, DROPDOWN_ROW_HEIGHT)
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      
      // Show no results message if the filtered list is empty
      if viewModel.countryList.isEmpty {
        HStack(
          alignment: .top,
          spacing: 8
        ) {
          
          Spacer()
          
          Text("No results found")
            .foregroundStyle(Colors.textSecondary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(height: DROPDOWN_EMPTY_VIEW_HEIGHT)
      }
    }
    .floatingShadow()
  }
  
  var cityInputView: some View {
    DefaultTextField(
      title: L10N.Common.ShippingAddressEntry.City.title,
      placeholder: L10N.Common.ShippingAddressEntry.City.placeholder,
      value: $viewModel.city,
      autoCapitalization: .words
    )
    .focused($focusedField, equals: .city)
  }
  
  var zipInputView: some View {
    VStack(spacing: 8) {
      DefaultTextField(
        title: L10N.Common.ShippingAddressEntry.ZipCode.title,
        placeholder: L10N.Common.ShippingAddressEntry.ZipCode.placeholder,
        value: $viewModel.zipCode,
        autoCapitalization: .sentences
      )
      .focused($focusedField, equals: .zipCode)
      
      if viewModel.isFreeInputEnabled {
        Text("Leave blank if not applicable")
          .foregroundStyle(Colors.textTertiary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
    }
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      confirmButton
      
      if !viewModel.isFreeInputEnabled {
        couldNotFindAddressButton
      }
    }
  }
  
  var confirmButton: some View {
    FullWidthButton(
      title: L10N.Common.ShippingAddress.Confirm.buttonTitle,
      isDisabled: !viewModel.isConfirmButtonEnabled
    ) {
      focusedField = nil
      viewModel.onConfirmButtonTap()
    }
  }
  
  var couldNotFindAddressButton: some View {
    FullWidthButton(
      type: .secondary,
      backgroundColor: Colors.buttonSurfaceSecondary.swiftUIColor,
      borderColor: Colors.greyDefault.swiftUIColor,
      title: L10N.Common.ShippingAddress.CouldntFindAddress.buttonTitle,
      isDisabled: false
    ) {
      focusedField = nil
      viewModel.onCouldNotFindAddressTap()
    }
  }
}

// MARK: - Private Enums
extension ShippingAddressEntryView {
  enum FocusedField: Hashable {
    case addressLine1
    case addressLine2
    case city
    case state
    case zipCode
  }
  
  enum FocusedSearchBar: Hashable {
    case state
    case country
  }
}
