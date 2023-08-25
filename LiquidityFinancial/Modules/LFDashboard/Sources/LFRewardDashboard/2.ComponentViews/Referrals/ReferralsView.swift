import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct ReferralsView: View {
  @StateObject private var viewModel = ReferralsViewModel()
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.onAppear()
      }
      .sheet(isPresented: $viewModel.showShareSheet) {
        ShareSheetView(activityItems: viewModel.activityItems)
      }
      .popup(isPresented: $viewModel.showCopyToast, style: .toast) {
        ToastView(toastMessage: LFLocalizable.Referral.Toast.message)
      }
  }
  
  private func example(_ campaign: ReferralCampaign) -> String {
    if LFUtility.cryptoEnabled {
      return LFLocalizable.Referral.Example.crypto(LFUtility.appName, LFUtility.appName)
    } else {
      return LFLocalizable.Referral.Example.donation(
        campaign.inviterBonusDisplay, campaign.periodDisplay, campaign.inviterBonusDisplay
      )
    }
  }
}

// MARK: View Components
private extension ReferralsView {
  func success(campaign: ReferralCampaign) -> some View {
    VStack(spacing: 32) {
      VStack(spacing: 20) {
        GenImages.Images.referralsInbox.swiftUIImage
          .resizable()
          .scaledToFit()
          .frame(max: .infinity)
        Text(LFUtility.appName.uppercased())
          .font(Fonts.Montserrat.black.swiftUIFont(size: Constants.FontSize.navigationBar.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.leading, 12)
        //referralsContext(campaign: campaign)
      }
      Spacer()
      //howItWorkView(campaign: campaign)
      buttonGroupView
    }
    .scrollOnOverflow()
    .multilineTextAlignment(.center)
    .padding(.horizontal, 30)
  }
  
  func referralsContext(campaign: ReferralCampaign) -> some View {
    VStack(spacing: 12) {
      Text(LFLocalizable.Referral.Screen.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.horizontal, 48)
        .frame(minHeight: 60)
      Text(LFLocalizable.Referral.Info.message(campaign.periodDisplay, campaign.inviterBonusDisplay))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .padding(.horizontal, 12)
        .frame(minHeight: 80)
    }
  }
  
  var buttonGroupView: some View {
    VStack(spacing: 10) {
      FullSizeButton(title: LFLocalizable.Referral.Send.buttonTitle, isDisable: false) {
        viewModel.sendTapped()
      }
      FullSizeButton(title: LFLocalizable.Referral.Copy.buttonTitle, isDisable: false, type: .contrast) {
        viewModel.copyTapped()
      }
    }
    .padding(.bottom, 20)
  }
  
  func howItWorkView(campaign: ReferralCampaign) -> some View {
    VStack(spacing: 10) {
      Text(LFLocalizable.Referral.Example.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .lineSpacing(1.17)
      Text(example(campaign))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .lineSpacing(5.0)
    }
    .padding(.vertical, 16)
    .padding(.horizontal, 32)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  var content: some View {
    VStack {
      switch viewModel.status {
      case let .success(campaign):
        success(campaign: campaign)
      case .loading:
        loading
      case .failure:
        failure
      }
    }
  }
  
  var loading: some View {
    VStack {
      Spacer()
      LottieView(loading: .primary)
        .frame(width: 60, height: 40)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }
  
  var failure: some View {
    VStack(spacing: 32) {
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .frame(180)
      Spacer()
      Text(LFLocalizable.Referral.Error.message)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor)
      FullSizeButton(title: LFLocalizable.Button.Retry.title, isDisable: false) {
        viewModel.retry()
      }
    }
    .padding(.top, 32)
    .padding(.horizontal, 30)
  }
}
