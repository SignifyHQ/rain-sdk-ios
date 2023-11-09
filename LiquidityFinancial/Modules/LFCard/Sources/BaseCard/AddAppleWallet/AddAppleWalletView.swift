import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

public struct AddAppleWalletView<
  ViewModel: AddAppleWalletViewModelProtocol,
  ApplePayViewModel: ApplePayViewModelProtocol
>: View {
  @StateObject private var viewModel: ViewModel
  
  public init(viewModel: ViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .sheet(isPresented: $viewModel.isShowApplePay) {
        ApplePayViewController(viewModel: ApplePayViewModel(cardModel: viewModel.cardModel)) {
          viewModel.onFinish()
        }
      }
      .defaultToolBar(icon: .xMark)
  }
}

// MARK: - View Components
private extension AddAppleWalletView {
  var content: some View {
    ScrollView(showsIndicators: false) {
      VStack {
        GenImages.Images.connectedAppleWallet.swiftUIImage
          .padding(.vertical, 36)
        information
        Spacer()
          .frame(minHeight: 36)
        buttons
      }
      .padding(.horizontal, 30)
    }
  }
  
  var information: some View {
    VStack(spacing: 16) {
      Text(LFLocalizable.AddToWallet.ApplePay.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(LFLocalizable.AddToWallet.ApplePay.description(LFUtilities.appName, LFUtilities.appName))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.center)
        .lineSpacing(4)
        .padding(.horizontal, 12)
        .fixedSize(horizontal: false, vertical: true)
    }
    .multilineTextAlignment(.center)
  }
  
  var buttons: some View {
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
        title: LFLocalizable.Button.Skip.title,
        isDisable: false,
        type: .secondary
      ) {
        viewModel.onFinish()
      }
    }
    .padding(.bottom, 16)
  }
}
