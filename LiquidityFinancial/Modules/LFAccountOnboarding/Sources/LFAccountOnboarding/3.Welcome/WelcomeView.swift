import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable

struct WelcomeView: View {
  
  @StateObject var viewModel = WelcomeViewModel()
  
  public var body: some View {
    VStack(spacing: 12) {
      staticTop
        .padding(.top, 20)
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.vertical, 12)
      
      ScrollView(showsIndicators: true) {
        VStack(spacing: 24) {
          HStack {
            Text(LFLocalizable.Welcome.howItWorks)
              .font(Fonts.regular.swiftUIFont(size: 18))
              .foregroundColor(Colors.label.swiftUIColor)
            Spacer()
          }
          items
          Spacer()
        }
        .padding(.horizontal, 30)
      }
      
      buttons
        .padding(.horizontal, 30)
    }
    .background(Colors.background.swiftUIColor)
    .onAppear {
        // TODO: Add analytics later
        // analyticsService.track(event: Event(name: .viewsWelcome))
    }
    .navigationLink(isActive: $viewModel.isPushToAgreementView) {
      AgreementView()
    }
    .navigationBarBackButtonHidden(true)
  }
  
  private var staticTop: some View {
    VStack(spacing: 12) {
      GenImages.Images.icLogo.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(110)
        .padding(.bottom, 10)
      
      Text(LFLocalizable.Welcome.Header.title)
        .font(Fonts.regular.swiftUIFont(fixedSize: 24))
        .foregroundColor(Colors.label.swiftUIColor)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
      
      Text(LFLocalizable.Welcome.Header.desc)
        .font(Fonts.regular.swiftUIFont(fixedSize: 16))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
      
    }
  }
  
  func item(image: Image, text: String) -> some View {
    HStack(alignment: .center, spacing: 12) {
      image
        .foregroundColor(Colors.label.swiftUIColor)
        .frame(width: 24, height: 24)
        .padding(.top, 4)
      Text(text)
        .font(Fonts.regular.swiftUIFont(fixedSize: 17))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .fixedSize(horizontal: false, vertical: true)
      Spacer()
    }
    .padding(.trailing, 12)
    .frame(maxWidth: .infinity)
  }
  
  private var buttons: some View {
    VStack(spacing: 10) {
      FullSizeButton(
        title: LFLocalizable.Welcome.Button.orderCard,
        isDisable: viewModel.isLoading,
        isLoading: $viewModel.isLoading
      ) {
        Task {
          await viewModel.perfromInitialAccount()
        }
      }
    }
  }
  
  private var items: some View {
    VStack(spacing: 25) {
      item(image: GenImages.CommonImages.icWellcome1.swiftUIImage, text: LFLocalizable.Welcome.HowItWorks.item1)
      
      item(image: GenImages.CommonImages.icWellcome2.swiftUIImage, text: LFLocalizable.Welcome.HowItWorks.item2)
      
      item(image: GenImages.CommonImages.icWellcome3.swiftUIImage, text: LFLocalizable.Welcome.HowItWorks.item3)
    }
  }
}

#if DEBUG
struct WelcomeView_Previews: PreviewProvider {
  static var previews: some View {
    WelcomeView()
      .previewLayout(PreviewLayout.sizeThatFits)
      .previewDisplayName("Default preview")
  }
}
#endif
