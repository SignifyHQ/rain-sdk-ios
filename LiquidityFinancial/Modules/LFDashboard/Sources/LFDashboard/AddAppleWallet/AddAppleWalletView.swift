import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct AddAppleWalletView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: AddAppleWalletViewModel
  
  init(card: CardModel, onFinish: @escaping () -> Void) {
    _viewModel = .init(
      wrappedValue: AddAppleWalletViewModel(cardModel: card, onFinish: onFinish)
    )
  }
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.onViewAppear()
      }
      .sheet(isPresented: $viewModel.isShowApplePay) {
        ApplePayController(cardModel: viewModel.cardModel) {
          viewModel.onFinish()
        }
      }
      .overlay(alignment: .topLeading) {
        Button {
          dismiss()
        } label: {
          CircleButton(style: .xmark)
        }
        .padding(.leading, 16)
      }
  }
}

// MARK: - View Components
private extension AddAppleWalletView {
  var content: some View {
    VStack {
      Spacer()
      GenImages.Images.connectedAppleWallet.swiftUIImage
      Spacer()
      information
      Spacer()
      buttons
    }
    .padding(.horizontal, 30)
  }
  
  var information: some View {
    VStack(spacing: 22) {
      Text(LFLocalizable.AddToWallet.ApplePay.title)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.large.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(LFLocalizable.AddToWallet.ApplePay.description(LFUtility.appName, LFUtility.appName))
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.center)
        .lineSpacing(4)
        .padding(.horizontal, 12)
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
