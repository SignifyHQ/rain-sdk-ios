import Factory
import LFLocalizable
import LFStyleGuide
import LFUtilities
import SwiftUI

public struct SsnPassportView: View {
  @Injected(\.onboardingViewFactory) var onboardingViewFactory
  
  @StateObject var viewModel: SsnPassportViewModel
  
  @FocusState private var focusedField: FocusedField?
  
  public init(
    viewModel: SsnPassportViewModel
  ) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(
      spacing: 32
    ) {
      progressView
      
      contentView
      
      Spacer()
      
      buttonGroup
    }
    .padding(.top, 4)
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
    .background(Colors.backgroundPrimary.swiftUIColor)
    .onTapGesture {
      focusedField = nil
    }
    .defaultNavBar(
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      }
    )
    .toast(
      data: $viewModel.currentToast
    )
    .onAppear {
      focusedField = .ssnPassport
    }
    .disabled(viewModel.isLoading)
    .navigationLink(
      item: $viewModel.navigation,
      destination: { navigation in
        onboardingViewFactory.createView(for: navigation)
      }
    )
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension SsnPassportView {
  var contentView: some View {
    VStack(
      alignment: .leading,
      spacing: 24
    ) {
      headerView
      
      ssnPassportInputView
      
      securityNotesView
    }
    .frame(
      maxWidth: .infinity
    )
  }
  
  var progressView: some View {
    SegmentedProgressBar(
      totalSteps: 8,
      currentStep: .constant(7)
    )
  }
  
  var headerView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      Text(viewModel.selectedCountry.isUnitedStates ? "Please enter your SSN" : "Please enter your Passport number")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var ssnPassportInputView: some View {
    VStack(
      alignment: .leading,
      spacing: 8
    ) {
      DefaultTextField(
        title: viewModel.selectedCountry.isUnitedStates ? "Social Security Number" : "Passport number",
        placeholder: viewModel.selectedCountry.isUnitedStates ?  "Enter Social Security Number" : "Enter Passport number",
        value: $viewModel.ssnPassport,
        keyboardType: viewModel.selectedCountry.isUnitedStates ? .numberPad : .asciiCapable,
        autoCapitalization: .characters
      )
      .focused($focusedField, equals: .ssnPassport)
      .onChange(
        of: viewModel.ssnPassport
      ) { newValue in
        DispatchQueue.main.async {
          guard viewModel.selectedCountry.isUnitedStates
          else {
            return
          }
          
          viewModel.ssnPassport = newValue.formatInput(of: .ssn)
        }
      }
      
      Text(viewModel.selectedCountry.isUnitedStates ? "Required to verify identity and prevent fraud. A social security number is required by law. Your information is not stored within the Avalanche App." : "Required to verify identity and prevent fraud. Your information is not stored within the Avalanche App. ")
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundStyle(Colors.titleTertiary.swiftUIColor)
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var securityNotesView: some View {
    VStack(
      alignment: .leading,
      spacing: 4
    ) {
      HStack(
        spacing: 12
      ) {
        GenImages.Images.icoEncryption.swiftUIImage
        
        Text("Encrypted using 256-BIT SSL")
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundStyle(Colors.titleSecondary.swiftUIColor)
        
        Spacer()
      }
      
      if viewModel.selectedCountry.isUnitedStates {
        HStack(
          spacing: 12
        ) {
          GenImages.Images.icoNoCreditChecks.swiftUIImage
          
          Text("No credit checks")
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundStyle(Colors.titleSecondary.swiftUIColor)
          
          Spacer()
        }
      }
    }
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
        focusedField = nil
        viewModel.onContinueButtonTap()
      }
    }
  }
}

// MARK: - Private Enums
extension SsnPassportView {
  enum FocusedField: Hashable {
    case ssnPassport
  }
}
