import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct CountryOfResidenceView: View {
  @StateObject var viewModel: CountryOfResidenceViewModel
  
  @State private var scrollViewFrame: CGRect = .zero
  @State private var countryDropdownFrame: CGRect = .zero
  @State private var stateDropdownFrame: CGRect = .zero
  
  @FocusState private var focusedSearchBar: FocusedSearchBar?
  
  private let DROPDOWN_SEARCHBAR_HEIGHT: CGFloat = 52
  private let DROPDOWN_ROW_HEIGHT: CGFloat = 36
  private let DROPDOWN_FOOTER_HEIGHT: CGFloat = 50
  private let DROPDOWN_EMPTY_VIEW_HEIGHT: CGFloat = 50
  // Calculate the country dropdown height based on the number of rows
  private var countryDropdownHeight: CGFloat {
    CGFloat
      .dropdownHeight(
        rowCount: viewModel.countryList.count,
        rowHeight: DROPDOWN_ROW_HEIGHT,
        headerHeight: DROPDOWN_SEARCHBAR_HEIGHT,
        footerHeight: DROPDOWN_FOOTER_HEIGHT,
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
        headerHeight: DROPDOWN_SEARCHBAR_HEIGHT,
        footerHeight: DROPDOWN_FOOTER_HEIGHT,
        emptyViewHeight: DROPDOWN_EMPTY_VIEW_HEIGHT,
        fallbackOveralHeight: stateDropdownFrame.width * 0.7
      )
  }
  
  public init(
    viewModel: CountryOfResidenceViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack() {
        contentView
        
        buttonGroup
      }
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
      // Adding content shape to make sure the whole screen is tappable
      .contentShape(Rectangle())
      .onTapGesture {
        viewModel.isShowingCountrySelection = false
        viewModel.isShowingStateSelection = false
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
            // Adding 8 as top padding of the dropdown
            y: countryDropdownFrame.maxY - scrollViewFrame.minY + countryDropdownHeight / 2 + 8
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
            // Adding 8 as top padding of the dropdown
            y: stateDropdownFrame.maxY - scrollViewFrame.minY + stateDropdownHeight / 2 + 8
          )
      }
    }
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      }
    )
    .toast(
      data: $viewModel.currentToast
    )
    .sheetWithContentHeight(
      item: $viewModel.waitlistNavigation,
      content: { type in
        WaitlistView(
          viewModel: WaitlistViewModel(
            waitlistType: type == .country ? .country : .state
          )
        )
      }
    )
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        switch navigation {
        case .authentication(let type):
          PhoneEmailAuthView(
            viewModel: PhoneEmailAuthViewModel(
              authType: .signup(type == .email ? .email : .phone)
            )
          )
        }
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension CountryOfResidenceView {
  var contentView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(
          alignment: .leading,
          spacing: 24
        ) {
          headerView
          
          availabilityToastView
          
          countryInputView
          
          if viewModel.selectedCountry == .US {
            stateInputView
          }
          
          // Add a spacer equal to the dropdown height when it’s shown
          // so the ScrollView can expand and scroll fully to display the dropdown.
          if viewModel.isShowingCountrySelection || viewModel.isShowingStateSelection {
            let spacerHeight = (viewModel.isShowingCountrySelection ? countryDropdownHeight : stateDropdownHeight) - 24 + 8
            - ((viewModel.selectedCountry == .US && viewModel.isShowingCountrySelection) ? (countryDropdownFrame.height + 24) : 0)
            
            Spacer()
              .frame(
                height: max(spacerHeight, 0)
              )
              .id("id-spacer")
          }
          
          Spacer()
        }
        .padding(.top, 8)
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
      .readGeometry { geometry in
        scrollViewFrame = geometry.frame(in: .global)
      }
    }
  }
  
  var headerView: some View {
    Text("Before we get started, select your country of residence")
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      .multilineTextAlignment(.leading)
  }
  
  var availabilityToastView: some View {
    HStack(
      alignment: .top,
      spacing: 8
    ) {
      GenImages.Images.icoInfoFilled.swiftUIImage
      
      Text(viewModel.selectedCountry == .US ? "We're currently available in select states. If your state isn't listed, you can sign up to be notified when we expand to your area." : "We're currently available in select countries. If your country isn't listed, you can sign up to be notified when we expand to your area.")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
        .transition(.opacity)
        .id(viewModel.selectedCountry)
      
      Spacer()
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(Colors.backgroundSecondary.swiftUIColor)
    )
    .animation(
      .easeInOut(duration: 0.3),
      value: viewModel.selectedCountry
    )
  }
  
  // TODO: Think of how to best turn these into reusable views
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
                viewModel.isShowingStateSelection = false
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
  
  var stateInputView: some View {
    ZStack {
      DefaultTextField(
        title: "State",
        placeholder: "Select state",
        value: $viewModel.selectedStateDisplayValue
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
                viewModel.isShowingCountrySelection = false
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
    .readGeometry { geometry in
      stateDropdownFrame = geometry.frame(in: .global)
    }
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
      .frame(height: DROPDOWN_SEARCHBAR_HEIGHT)
      
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
          spacing: 8
        ) {
          
          Spacer()
          
          Text("No results found")
            .foregroundStyle(Colors.textSecondary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          Spacer()
        }
        .padding(.vertical, 8)
        .frame(height: DROPDOWN_EMPTY_VIEW_HEIGHT)
      }
      
      Button {
        viewModel.isShowingCountrySelection = false
        viewModel.onWaitlistButtonTap(shouldNavigateTo: .country)
      } label: {
        HStack(
          alignment: .top,
          spacing: 8
        ) {
          GenImages.Images.icoNotificationBell.swiftUIImage
          
          Text("Don't see your country? Notify me when available")
            .foregroundStyle(Colors.textPrimary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .multilineTextAlignment(.leading)
          
          Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(height: DROPDOWN_FOOTER_HEIGHT)
        .background(Colors.accentContrast.swiftUIColor)
      }
    }
    .floatingShadow()
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
      .frame(height: DROPDOWN_SEARCHBAR_HEIGHT)
      
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
          spacing: 8
        ) {
          Spacer()
          
          Text("No results found")
            .foregroundStyle(Colors.textSecondary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          Spacer()
        }
        .padding(.vertical, 8)
        .frame(height: DROPDOWN_EMPTY_VIEW_HEIGHT)
      }
       
      Button {
        viewModel.isShowingStateSelection = false
        viewModel.onWaitlistButtonTap(shouldNavigateTo: .state)
      } label: {
        HStack(
          alignment: .top,
          spacing: 8
        ) {
          GenImages.Images.icoNotificationBell.swiftUIImage
          
          Text("Don't see your state? Notify me when available")
            .foregroundStyle(Colors.textPrimary.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
            .multilineTextAlignment(.leading)
          
          Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .frame(height: DROPDOWN_FOOTER_HEIGHT)
        .background(Colors.accentContrast.swiftUIColor)
      }
    }
    .floatingShadow()
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
        viewModel.onContinueButtonTap()
      }
    }
  }
}

// MARK: - Private Enums
extension CountryOfResidenceView {
  enum FocusedSearchBar: Hashable {
    case country
    case state
  }
}
