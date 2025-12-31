import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct WaitlistView: View {
  @Environment(\.dismiss) var dismiss
  
  @StateObject var viewModel: WaitlistViewModel
  
  @State private var contentViewFrame: CGRect = .zero
  @State private var countryDropdownFrame: CGRect = .zero
  @State private var stateDropdownFrame: CGRect = .zero
  
  @FocusState private var focusedField: FocusedField?
  @FocusState private var focusedSearchBar: FocusedSearchBar?
  
  private let DROPDOWN_SEARCHBAR_HEIGHT: CGFloat = 52
  private let DROPDOWN_ROW_HEIGHT: CGFloat = 36
  private let DROPDOWN_EMPTY_VIEW_HEIGHT: CGFloat = 50
  // Calculate the country dropdown height based on the number of rows
  private var countryDropdownHeight: CGFloat {
    CGFloat
      .dropdownHeight(
        rowCount: viewModel.countryList.count,
        rowHeight: DROPDOWN_ROW_HEIGHT,
        headerHeight: DROPDOWN_SEARCHBAR_HEIGHT,
        emptyViewHeight: DROPDOWN_EMPTY_VIEW_HEIGHT,
        fallbackOveralHeight: countryDropdownFrame.width * 0.6
      )
  }
  // Calculate the state dropdown height based on the number of rows
  private var stateDropdownHeight: CGFloat {
    CGFloat
      .dropdownHeight(
        rowCount: viewModel.stateListFiltered.count,
        rowHeight: DROPDOWN_ROW_HEIGHT,
        headerHeight: DROPDOWN_SEARCHBAR_HEIGHT,
        emptyViewHeight: DROPDOWN_EMPTY_VIEW_HEIGHT,
        fallbackOveralHeight: stateDropdownFrame.width * 0.6
      )
  }
  
  public init(
    viewModel: WaitlistViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    ZStack {
      VStack(
        spacing: 32
      ) {
        headerView
        
        inputFieldsView
        
        buttonGroup
      }
      .padding(.top, 24)
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
      .onTapGesture {
        viewModel.isShowingCountrySelection = false
        viewModel.isShowingStateSelection = false
      }
      .readGeometry { geometry in
        contentViewFrame = geometry.frame(in: .global)
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
            y: countryDropdownFrame.maxY - contentViewFrame.minY + countryDropdownHeight / 2 + 8
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
            y: stateDropdownFrame.maxY - contentViewFrame.minY + stateDropdownHeight / 2 + 8
          )
      }
    }
    .background(Colors.backgroundDark.swiftUIColor)
    .toast(
      data: $viewModel.currentToast
    )
    .disabled(viewModel.isLoading)
    .onChange(
      of: viewModel.shouldDismissSelf
    ) { _ in
      dismiss()
    }
  }
}

// MARK: - View Components
private extension WaitlistView {
  var headerView: some View {
    ZStack {
      HStack {
        Button {
          dismiss()
        } label: {
          GenImages.Images.icoArrowNavBack.swiftUIImage
        }
        
        Spacer()
      }
      
      HStack {
        Spacer()
        
        Text(
          viewModel.waitlistType == .country ?
          "Get notified when we're\navailable in your country"
          : "Get notified when we're\navailable in your state"
        )
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        
        Spacer()
      }
    }
  }
  
  var inputFieldsView: some View {
    VStack(
      spacing: 16
    ) {
      if viewModel.waitlistType == .country {
        countryInputView
      }
      
      if viewModel.waitlistType == .state {
        stateInputView
      }
      
      emailAddressInputView
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
  
  var emailAddressInputView: some View {
    DefaultTextField(
      title: "Notify me via email ",
      placeholder: "Enter email address",
      value: $viewModel.emailAddress,
      keyboardType: .emailAddress,
      autoCapitalization: .never
    )
    .focused($focusedField, equals: .email)
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
  
  var buttonGroup: some View {
    VStack(
      spacing: 12
    ) {
      FullWidthButton(
        type: .primary,
        title: "Continue",
        isDisabled: !viewModel.isContinueButtonEnabled,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.onContinueButtonTap()
      }
      
      FullWidthButton(
        type: .secondary,
        title: "Cancel",
        isDisabled: false,
        isLoading: .constant(false)
      ) {
        dismiss()
      }
    }
  }
}

// MARK: - Private Enums
extension WaitlistView {
  enum FocusedField: Hashable {
    case email
  }
  
  enum FocusedSearchBar: Hashable {
    case country
    case state
  }
}

