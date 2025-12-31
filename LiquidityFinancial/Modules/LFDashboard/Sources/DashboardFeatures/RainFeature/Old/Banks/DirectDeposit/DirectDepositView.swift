import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services

public struct DirectDepositView: View {
  @StateObject var viewModel = DirectDepositViewModel()
  @Binding var achInformation: ACHModel
  
  private let companyLogos = [
    GenImages.Images.companyLogo1.swiftUIImage,
    GenImages.Images.companyLogo2.swiftUIImage,
    GenImages.Images.companyLogo3.swiftUIImage,
    GenImages.Images.companyLogo4.swiftUIImage,
    GenImages.Images.companyLogo5.swiftUIImage,
    GenImages.Images.companyLogo6.swiftUIImage
  ]

  init(achInformation: Binding<ACHModel>) {
    _achInformation = achInformation
  }
  
  public var body: some View {
    ScrollView {
      HStack(alignment: .top) {
        VStack(spacing: 24) {
          VStack(spacing: 16) {
            automaticSetup
            manualSetup
          }
          Spacer()
        }
      }
      .padding(.horizontal, 32)
    }
    .padding(.top, 28)
    .blur(radius: viewModel.isShowAllBenefits ? 24 : 0)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Text(L10N.Common.DirectDeposit.Screen.title)
          .foregroundColor(Colors.label.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      }
    }
    .navigationLink(isActive: $viewModel.isNavigateToDirectDepositForm) {
      DirectDepositFormView(achInformation: $achInformation)
    }
    .fullScreenCover(item: $viewModel.pinWheelData) { data in
      PinWheelViewController(data: data)
    }
    .popup(isPresented: $viewModel.isShowAllBenefits, style: .sheet) {
      benefitBottomSheet
    }
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationBarTitleDisplayMode(.inline)
    .background(Colors.background.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension DirectDepositView {
  var automaticSetup: some View {
    VStack(spacing: 8) {
      sectionTitle(
        setupType: L10N.Common.DirectDeposit.AutomationSetup.title,
        title: L10N.Common.DirectDeposit.FindYourEmployer.title,
        description: L10N.Common.DirectDeposit.AutomationSetup.description
      )
      companyIcons
        .padding(.horizontal, 60)
        .padding(.top, 16)
        .padding(.bottom, 24)
      
      FullSizeButton(
        title: L10N.Common.DirectDeposit.GetStarted.buttonTitle,
        isDisable: false,
        isLoading: $viewModel.directDepositLoading
      ) {
        viewModel.automationSetup()
      }
    }
    .padding(16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(9)
  }
  
  func sectionTitle(setupType: String, title: String, description: String) -> some View {
    VStack(spacing: 8) {
      Text(setupType)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundStyle(
          LinearGradient(
            colors: primaryTextColor,
            startPoint: .leading,
            endPoint: .trailing
          )
        )
      Text(title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.center)
        .lineSpacing(1.4)
        .padding(.horizontal, 68)
    }
  }
  
  var manualSetup: some View {
    VStack(spacing: 8) {
      sectionTitle(
        setupType: L10N.Common.DirectDeposit.ManualSetup.title,
        title: L10N.Common.DirectDeposit.UseAccountDetails.title,
        description: L10N.Common.DirectDeposit.ManualSetup.description
      )
      VStack(alignment: .leading) {
        numberCell(
          icon: GenImages.CommonImages.icRoutingNumber.swiftUIImage,
          iconDescription: L10N.Common.DirectDeposit.RoutingNumber.title,
          title: L10N.Common.DirectDeposit.RoutingNumber.title,
          value: achInformation.routingNumber
        )
        .onTapGesture {
          viewModel.copy(text: achInformation.routingNumber)
        }
        numberCell(
          icon: GenImages.CommonImages.icAccountNumber.swiftUIImage,
          iconDescription: L10N.Common.DirectDeposit.AccountNumber.title,
          title: L10N.Common.DirectDeposit.AccountNumber.title,
          value: achInformation.accountNumber
        )
        .onTapGesture {
          viewModel.copy(text: achInformation.accountNumber)
        }
      }
      .padding(.bottom, 24)
    }
    .padding(16)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(9)
  }
  
  var companyIcons: some View {
    HStack(alignment: .center, spacing: -15) {
      ForEach(Array(companyLogos.reversed().enumerated()), id: \.offset) {offset, imageAsset in
        imageAsset
          .overlay(
            Circle().stroke(Colors.secondaryBackground.swiftUIColor, lineWidth: 3)
          )
          .zIndex(Double(-offset))
      }
    }
  }
  
  func numberCell(icon: Image, iconDescription: String, title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(spacing: 6) {
        icon
          .foregroundColor(Colors.label.swiftUIColor)
        Text(iconDescription)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      }
      HStack {
        Text(value)
          .font(Fonts.bold.swiftUIFont(size: 13))
          .tracking(3)
        Spacer()
        GenImages.CommonImages.icCopy.swiftUIImage
          .resizable()
          .frame(20)
          .scaledToFit()
      }
      .foregroundStyle(
        LinearGradient(
          colors: primaryTextColor,
          startPoint: .leading,
          endPoint: .trailing
        )
      )
    }
    .foregroundColor(Colors.label.swiftUIColor)
    .padding(.horizontal, -4)
  }
  
  var benefitBottomSheet: some View {
    VStack(spacing: 0) {
      Colors.secondaryBackground.swiftUIColor
        .frame(height: 30)
        .cornerRadius(20, corners: [.topLeft, .topRight])
      VStack(spacing: 0) {
        Rectangle()
          .fill(Colors.label.swiftUIColor.opacity(0.25))
          .frame(width: 33, height: 4)
          .cornerRadius(4)
          .padding(.top, -22)
        Text(L10N.Common.DirectDeposit.Benefits.bottomSheetTitle)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .multilineTextAlignment(.center)
        VStack(alignment: .leading, spacing: 28) {
          benefitCell(icon: GenImages.CommonImages.icFlash.swiftUIImage, label: L10N.Common.DirectDeposit.FirstBenefit.title)
          benefitCell(icon: GenImages.CommonImages.icWallet.swiftUIImage, label: L10N.Common.DirectDeposit.SecondBenefit.title)
        }
        .padding(.top, 24)
        .padding(.bottom, 40)
        FullSizeButton(title: L10N.Common.Button.Done.title, isDisable: false, type: .secondary) {
          viewModel.isShowAllBenefits = false
        }
        Spacer()
          .frame(height: 20)
      }
      .padding(.horizontal, 30)
      .background(Colors.secondaryBackground.swiftUIColor)
    }
  }
  
  func benefitCell(icon: Image, label: String) -> some View {
    HStack(spacing: 12) {
      icon
        .resizable()
        .aspectRatio(contentMode: .fit)
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(24)
      
      Text(label)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(1.17)
      Spacer()
    }
    .fixedSize(horizontal: false, vertical: true)
  }
}

// MARK: - View Helpers
private extension DirectDepositView {
  var primaryTextColor: [Color] {
    switch LFStyleGuide.target {
    case .CauseCard:
      return [
        Colors.gradientButton0.swiftUIColor,
        Colors.gradientButton1.swiftUIColor
      ]
    case .Cardano:
      return [Colors.whiteText.swiftUIColor]
    default:
      return [Colors.primary.swiftUIColor]
    }
  }
}
