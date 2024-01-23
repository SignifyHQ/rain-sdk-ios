import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct SolidAddAppleWalletView: View {
  @StateObject private var viewModel: SolidAddAppleWalletViewModel
  
  init(viewModel: SolidAddAppleWalletViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .sheet(isPresented: $viewModel.isShowApplePay) {
        SolidApplePayViewController(viewModel: SolidApplePayViewModel(cardModel: viewModel.cardModel)) {
          viewModel.onFinish()
        }
      }
      .defaultToolBar(icon: .xMark)
  }
}

// MARK: - View Components
private extension SolidAddAppleWalletView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack {
        GenImages.Images.connectedAppleWallet.swiftUIImage
          .padding(.vertical, 36)
        information
        Spacer()
          .frame(minHeight: 36)
        buttonGroupView
      }
      .padding(.horizontal, 30)
    }
  }
  
  var information: some View {
    VStack(spacing: 16) {
      Text(L10N.Common.AddToWallet.ApplePay.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(L10N.Common.AddToWallet.ApplePay.description(LFUtilities.appName, LFUtilities.appName))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.center)
        .lineSpacing(4)
        .padding(.horizontal, 12)
        .fixedSize(horizontal: false, vertical: true)
    }
    .multilineTextAlignment(.center)
  }
  
  var buttonGroupView: some View {
    VStack(spacing: 10) {
      Button {
        viewModel.onClickedAddToApplePay()
      } label: {
        ApplePayButton()
          .frame(height: 40)
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Colors.label.swiftUIColor, lineWidth: 1)
          )
      }
      FullSizeButton(
        title: L10N.Common.Button.Skip.title,
        isDisable: false,
        type: .secondary
      ) {
        viewModel.onFinish()
      }
    }
    .padding(.bottom, 16)
  }
}
