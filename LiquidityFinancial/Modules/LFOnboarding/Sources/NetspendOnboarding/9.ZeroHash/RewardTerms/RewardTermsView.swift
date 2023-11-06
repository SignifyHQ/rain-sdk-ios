import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Services
import Factory

struct RewardTermsView: View {
  
  @Injected(\.analyticsService)
  var analyticsService
  
  @StateObject
  var viewModel = RewardTermsViewModel()
  
  var body: some View {
    ZStack {
      Colors.background.swiftUIColor.edgesIgnoringSafeArea(.all)
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          Spacer(minLength: 8)
          Text(LFLocalizable.RewardTerms.enrollTitle)
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
          rewardDetails
          FullSizeButton(
            title: LFLocalizable.RewardTerms.enrollCta,
            isDisable: false
          ) {
            analyticsService.track(event: AnalyticsEvent(name: .rewardTermsAccepted))
            viewModel.onClickedContinueButton()
          }
          Text(viewModel.disclaimerText)
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          Spacer()
        }
        .padding(.horizontal, 32)
      }.onAppear {
        analyticsService.track(event: AnalyticsEvent(name: .rewardTermsViewed))
      }
      .padding([.top], 1)
    }
    .navigationBarBackButtonHidden(true)
    .navigationBarTitleDisplayMode(.inline)
    .defaultToolBar(icon: .both, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .track(name: String(describing: type(of: self)))
  }

  private func buildRow(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .foregroundColor(Colors.label.swiftUIColor)
        .opacity(0.75)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.regular.value))
      Text(subtitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.regular.value))
    }
  }
}

extension RewardTermsView {
  
  private var rewardDetails: some View {
    HStack(spacing: 16) {
      VStack {
        GenImages.Images.icLogo.swiftUIImage
          .resizable()
          .scaledToFit()
          .frame(width: 80, height: 80, alignment: .center)
        Spacer()
      }
      VStack(alignment: .leading) {
        buildRow(
          title: LFLocalizable.RewardTerms.amountTitle,
          subtitle: LFLocalizable.RewardTerms.amountDescription
        )
        Divider()
          .overlay(Colors.label.swiftUIColor.opacity(0.2))
        buildRow(
          title: LFLocalizable.RewardTerms.feesTitle,
          subtitle: LFLocalizable.RewardTerms.feesDescription
        )
        Divider()
          .overlay(Colors.label.swiftUIColor.opacity(0.2))
        buildRow(
          title: LFLocalizable.RewardTerms.exchangeRateTitle,
          subtitle: LFLocalizable.RewardTerms.exchangeRateDescription
        )
      }
    }
  }
}

// MARK: - RewardTermsView_Previews
#if DEBUG
struct RewardTermsView_Previews: PreviewProvider {
  static var previews: some View {
    RewardTermsView()
  }
}
#endif
