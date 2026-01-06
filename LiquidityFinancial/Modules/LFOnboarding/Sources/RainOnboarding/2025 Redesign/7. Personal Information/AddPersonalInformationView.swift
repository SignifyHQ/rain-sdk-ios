import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct AddPersonalInformationView: View {
  @StateObject var viewModel: AddPersonalInformationViewModel
  
  @State private var progressBarFrame: CGRect = .zero
  @State private var phoneCodeDropdownFrame: CGRect = .zero
  
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
        fallbackOveralHeight: phoneCodeDropdownFrame.width * 0.7
      )
  }
  
  public init(
    viewModel: AddPersonalInformationViewModel
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
        viewModel.isShowingPhoneCodeCountrySelection = false
        focusedField = nil
      }
      
      if viewModel.isShowingPhoneCodeCountrySelection {
        countryDropdownView()
          .frame(
            width: phoneCodeDropdownFrame.width,
            height: countryDropdownHeight,
            alignment: .top
          )
          .background(Colors.backgroundLight.swiftUIColor)
          .clipShape(RoundedRectangle(cornerRadius: 16))
          .position(
            x: phoneCodeDropdownFrame.midX,
            // Calculate the dropdown Y position
            // Adding 8 to account for VStack vertical padding
            // Adding 8 as top padding of the dropdown
            y: phoneCodeDropdownFrame.maxY - progressBarFrame.minY + countryDropdownHeight / 2 + 8 + 8
          )
      }
    }
    .background(Colors.backgroundPrimary.swiftUIColor)
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      }
    )
    .onAppear {
      focusedField = .firstName
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
        case .completeYourProfile:
          CompleteProfileView(
            viewModel: CompleteProfileViewModel()
          )
        }
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension AddPersonalInformationView {
  var contentView: some View {
    ScrollViewReader { proxy in
      ScrollView {
        VStack(
          alignment: .leading,
          spacing: 24
        ) {
          headerView
          
          firstNameInputView
          lastNameInputView
          dobInputView
          
          if viewModel.authMethod == .email {
            phoneNumberInputView
          }
          
          if viewModel.authMethod == .phone {
            emailAddressInputView
          }
          
          // Add a spacer equal to the dropdown height when it’s shown
          // so the ScrollView can expand and scroll fully to display the dropdown.
          if viewModel.isShowingPhoneCodeCountrySelection {
            let spacerHeight = countryDropdownHeight - 24 + 8
            
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
      currentStep: .constant(5)
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text("Add personal information")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
      
      Text("Your name should match your ID exactly")
        .foregroundStyle(Colors.titleTertiary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var firstNameInputView: some View {
    DefaultTextField(
      title: "First name",
      placeholder: "Enter first name",
      value: $viewModel.firstName,
      autoCapitalization: .words
    )
    .focused($focusedField, equals: .firstName)
  }
  
  var lastNameInputView: some View {
    DefaultTextField(
      title: "Last name",
      placeholder: "Enter last name",
      value: $viewModel.lastName,
      autoCapitalization: .words
    )
    .focused($focusedField, equals: .lastName)
  }
  
  var dobInputView: some View {
    VStack(
      alignment: .leading,
      spacing: 8
    ) {
      DefaultDatePickerTextField(
        title: "Date of birth",
        placeholder: "DD / MM / YYYY",
        value: $viewModel.selectedDate,
        errorMessage: $viewModel.dobInputError
      )
      .focused($focusedField, equals: .dob)
      
      if viewModel.dobInputError == nil {
        Text("Required to verify age requirements")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundStyle(Colors.titleTertiary.swiftUIColor)
      }
    }
  }
  
  var phoneNumberInputView: some View {
    VStack(
      alignment: .leading,
      spacing: 8
    ) {
      Text("Phone number")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
      
      HStack(
        alignment: .center,
        spacing: 8
      ) {
        HStack(
          spacing: 3
        ) {
          Text(viewModel.selectedCountryDisplayValue)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          
          GenImages.Images.icoExpandDown.swiftUIImage
            .resizable()
            .frame(16)
            .rotationEffect(
              .degrees(viewModel.isShowingPhoneCodeCountrySelection ? -180 : 0)
            )
            .animation(
              .easeOut(
                duration: 0.2
              ),
              value: viewModel.isShowingPhoneCodeCountrySelection
            )
        }
        .padding(.vertical, 8)
        .padding(.leading, 8)
        .padding(.trailing, 4)
        .background(Colors.backgroundLight.swiftUIColor)
        .cornerRadius(4)
        .highPriorityGesture(
          TapGesture()
            .onEnded {
              viewModel.isShowingPhoneCodeCountrySelection.toggle()
              focusedField = nil
            }
        )
        
        DefaultTextField(
          placeholder: "(000) 000-0000",
          isDividerShown: false,
          value: $viewModel.phoneNumber,
          keyboardType: .numberPad
        )
        .focused($focusedField, equals: .phone)
        .onChange(
          of: viewModel.phoneNumber
        ) { newValue in
          DispatchQueue.main.async {
            viewModel.phoneNumber = newValue.formatInput(of: .phoneNumber)
          }
        }
      }
      
      Divider()
        .background(Colors.dividerPrimary.swiftUIColor)
        .frame(
          height: 1,
          alignment: .center
        )
    }
    .readGeometry { geometry in
      phoneCodeDropdownFrame = geometry.frame(in: .global)
    }
  }
  
  var emailAddressInputView: some View {
    DefaultTextField(
      title: "Email address",
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
        ZStack {
          HStack(
            spacing: 4
          ) {
            Text(item.flagEmoji())
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .layoutPriority(1)
            
            Text(item.title)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .lineLimit(1)
            
            Spacer()
            
            Text(item.phoneCode)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
              .foregroundStyle(Colors.titleSecondary.swiftUIColor)
              .layoutPriority(1)
          }
          
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
          viewModel.isShowingPhoneCodeCountrySelection = false
        }
      }
      .environment(\.defaultMinListRowHeight, DROPDOWN_ROW_HEIGHT)
      .scrollContentBackground(.hidden)
      .listStyle(.plain)
      
      // Show no results message if the filtered list is empty
      if viewModel.countryList.isEmpty {
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
extension AddPersonalInformationView {
  enum FocusedField: Hashable {
    case firstName
    case lastName
    case dob
    case email
    case phone
  }
  
  enum FocusedSearchBar: Hashable {
    case country
  }
}
