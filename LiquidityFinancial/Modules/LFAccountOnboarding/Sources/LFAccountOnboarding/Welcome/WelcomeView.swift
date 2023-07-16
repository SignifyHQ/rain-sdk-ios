import SwiftUI
import LFStyleGuide
import LFLocalizable

public struct WelcomeView: View {
  @StateObject private var viewModel: WelcomeViewModel

  public init(viewModel: WelcomeViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }

  public var body: some View {
    VStack(spacing: 12) {
      staticTop

      Images.Common.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.vertical, 12)

      ScrollView(showsIndicators: true) {
        VStack(spacing: 24) {
          HStack {
            Text(LFLocalizable.Welcome.howItWorks)
              .font(Fonts.Inter.regular.swiftUIFont(size: 16))
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
    .popup(isPresented: $viewModel.showError, style: .toast) {
      ToastView(toastMessage: LFLocalizable.genericErrorMessage)
    }
  }

  private var staticTop: some View {
    VStack(spacing: 12) {
      Images.logo.swiftUIImage
      
      Text(LFLocalizable.Welcome.title)
        .font(Fonts.Inter.regular.swiftUIFont(fixedSize: 24))
        .foregroundColor(Colors.label.swiftUIColor)
        .fixedSize(horizontal: false, vertical: true)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 30)
      
      Text(LFLocalizable.Welcome.subtitle)
        .font(Fonts.Inter.regular.swiftUIFont(fixedSize: 16))
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
        .font(Fonts.Inter.regular.swiftUIFont(fixedSize: 16))
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
        title: LFLocalizable.Welcome.orderCard,
        isDisable: false,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.orderCardTapped()
      }
    }
  }

  private var items: some View {
    VStack(spacing: 20) {
      item(image: Images.Welcome.welcome1.swiftUIImage, text: LFLocalizable.Welcome.item1)
      
      item(image: Images.Welcome.welcome2.swiftUIImage, text: LFLocalizable.Welcome.item2)
      
      item(image: Images.Welcome.welcome3.swiftUIImage, text: LFLocalizable.Welcome.item3)
    }
  }
}
