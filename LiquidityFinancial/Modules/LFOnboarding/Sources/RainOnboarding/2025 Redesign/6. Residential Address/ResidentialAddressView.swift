import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct ResidentialAddressView: View {
  @StateObject var viewModel: ResidentialAddressViewModel
  
  @State private var progressBarFrame: CGRect = .zero
  @State private var addressSuggestionsDropdownFrame: CGRect = .zero
  @State private var stateDropdownFrame: CGRect = .zero
  @State private var countryDropdownFrame: CGRect = .zero
  
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
    viewModel: ResidentialAddressViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack(
        spacing: 32
      ) {
        progressView
          .readGeometry { geometry in
            progressBarFrame = geometry.frame(in: .global)
          }
        
        contentView
        
        buttonGroup
      }
      .padding(.top, 8)
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
      // Adding content shape to make sure the whole screen is tappable
      .contentShape(Rectangle())
      .onTapGesture {
        viewModel.hideSelections()
        focusedField = nil
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
            // Adding 8 to account for VStack vertical padding
            // Adding 8 as top padding of the dropdown
            y: addressSuggestionsDropdownFrame.maxY - progressBarFrame.minY + addressDropdownHeight / 2 + 8 + 8
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
            // Adding 8 to account for VStack vertical padding
            // Adding 8 as top padding of the dropdown
            y: stateDropdownFrame.maxY - progressBarFrame.minY + stateDropdownHeight / 2 + 8 + 8
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
            // Adding 8 to account for VStack vertical padding
            // Adding 8 as top padding of the dropdown
            y: countryDropdownFrame.maxY - progressBarFrame.minY + countryDropdownHeight / 2 + 8 + 8
          )
      }
    }
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      },
      isBackButtonHidden: true
    )
    .toast(
      data: $viewModel.currentToast
    )
    .onAppear {
      focusedField = .addressLine1
    }
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
        case .addPersonalInformation:
          AddPersonalInformationView(
            viewModel: AddPersonalInformationViewModel()
          )
        }
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension ResidentialAddressView {
  var contentView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(
          alignment: .leading,
          spacing: 24
        ) {
          headerView
          
          addressLine1InputView
          addressLine2InputView
          
          stateInputView
          
          HStack(
            spacing: 16
          ) {
            cityInputView
            
            zipInputView
          }
          
          countryInputView
          
          // Add a spacer equal to the dropdown height when it’s shown
          // so the ScrollView can expand and scroll fully to display the dropdown.
          if viewModel.isShowingStateSelection || viewModel.isShowingCountrySelection {
            let spacerHeight = (viewModel.isShowingCountrySelection ? countryDropdownHeight : stateDropdownHeight) - 24 + 8
            - ((viewModel.isShowingStateSelection) ? 2 * (stateDropdownFrame.height + 24) : 0)
            
            Spacer()
              .frame(
                height: max(spacerHeight, 0)
              )
              .id("id-spacer")
          }
          
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
  
  var progressView: some View {
    SegmentedProgressBar(
      totalSteps: 8,
      currentStep: .constant(4)
    )
  }
  
  var headerView: some View {
    Text("Your residential address")
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .multilineTextAlignment(.leading)
      .fixedSize(horizontal: false, vertical: true)
  }
  
  var addressLine1InputView: some View {
    DefaultTextField(
      title: "Address line 1",
      placeholder: "Enter address",
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
      title: "Apartment, suite, etc. (optional)",
      placeholder: "Apt, suite, floor, etc.",
      value: $viewModel.addressLine2,
      autoCapitalization: .sentences
    )
    .focused($focusedField, equals: .addressLine2)
  }
  
  var stateInputView: some View {
    ZStack {
      DefaultTextField(
        title: viewModel.selectedCountry.isUnitedStates ? "State" : "State/region",
        placeholder: viewModel.selectedCountry.isUnitedStates ? "Select state" : "Enter state/region",
        value: $viewModel.selectedStateDisplayValue
      )
      .disabled(viewModel.selectedCountry.isUnitedStates)
      
      if viewModel.selectedCountry.isUnitedStates {
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
    .readGeometry { geometry in
      stateDropdownFrame = geometry.frame(in: .global)
    }
  }
  
  var countryInputView: some View {
    ZStack {
      DefaultTextField(
        title: "Country",
        placeholder: "Select country",
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
      title: "City",
      placeholder: "Enter city",
      value: $viewModel.city,
      autoCapitalization: .words
    )
    .focused($focusedField, equals: .city)
  }
  
  var zipInputView: some View {
    DefaultTextField(
      title: "Zip code",
      placeholder: "Enter zip code",
      value: $viewModel.zipCode,
      autoCapitalization: .sentences
    )
    .focused($focusedField, equals: .zipCode)
  }
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .primary,
        title: "Continue",
        isDisabled: !viewModel.isContinueButtonEnabled
      ) {
        focusedField = nil
        viewModel.onContinueButtonTap()
      }
    }
  }
}

// MARK: - Private Enums
extension ResidentialAddressView {
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
