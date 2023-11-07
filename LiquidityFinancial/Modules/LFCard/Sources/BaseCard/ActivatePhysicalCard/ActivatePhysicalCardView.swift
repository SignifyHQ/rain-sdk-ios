import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

public struct ActivatePhysicalCardView<
  EnterCVVCodeViewModel: EnterCVVCodeViewModelProtocol,
  SetCardPinViewModel: SetCardPinViewModelProtocol,
  AddAppleWalletViewModel: AddAppleWalletViewModelProtocol,
  ApplePayViewModel: ApplePayViewModelProtocol
> : View {
  @Environment(\.dismiss) private var dismiss
  @State private var activeContent: ActiveContent = .cvvCode
  let card: CardModel
  let onSuccess: ((String) -> Void)?
  
  public init(card: CardModel, onSuccess: ((String) -> Void)? = nil) {
    self.card = card
    self.onSuccess = onSuccess
  }
  
  public var body: some View {
    content
  }
}

// MARK: - View Components
private extension ActivatePhysicalCardView {
  @MainActor @ViewBuilder var content: some View {
    switch activeContent {
    case .cvvCode:
      EnterCVVCodeView(
        viewModel: EnterCVVCodeViewModel(cardID: card.id),
        screenTitle: LFLocalizable.EnterCVVCode.ActiveCard.title
      ) { verifyID in
        activeContent = .setCardPin(verifyID)
      }
    case let .setCardPin(verifyID):
      SetCardPinView(
        viewModel: SetCardPinViewModel(verifyID: verifyID, cardID: card.id) { cardID in
          activeContent = .activedCard
          onSuccess?(cardID)
        }
      )
    case .activedCard:
      activedCardView
    case .addAppleWallet:
        AddAppleWalletView<AddAppleWalletViewModel, ApplePayViewModel>(
        viewModel: AddAppleWalletViewModel(cardModel: card) {
          dismiss()
        }
      )
    }
  }
  
  var activedCardView: some View {
    VStack(spacing: 16) {
      Spacer()
        .frame(maxHeight: 60)
      VStack(spacing: 54) {
        VStack(spacing: 28) {
          GenImages.Images.connectedAppleWallet.swiftUIImage
          GenImages.Images.connectedAppleWalletShadow.swiftUIImage
        }
        VStack(spacing: 16) {
          Text(LFLocalizable.CardActivated.CardActived.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
            .foregroundColor(Colors.label.swiftUIColor)
            .multilineTextAlignment(.center)
          Text(LFLocalizable.CardActivated.CardActived.description)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      Spacer()
      VStack(spacing: 10) {
        // applePay TODO: - Temporarily hide this button
        FullSizeButton(
          title: LFLocalizable.Button.Skip.title,
          isDisable: false,
          type: .secondary
        ) {
          dismiss()
        }
      }
      .padding(.bottom, 16)
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .overlay(alignment: .topLeading) {
      Button {
        dismiss()
      } label: {
        CircleButton(style: .xmark)
      }
      .padding(.top, 16)
      .padding(.leading, 16)
    }
  }
  
  var applePay: some View {
    Button {
      activeContent = .addAppleWallet
    } label: {
      ApplePayButton()
        .frame(height: 40)
        .cornerRadius(10)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(Colors.label.swiftUIColor, lineWidth: 1)
        )
    }
  }
}

// MARK: - Types
extension ActivatePhysicalCardView {
  enum ActiveContent {
    case cvvCode
    case setCardPin(String)
    case activedCard
    case addAppleWallet
  }
}
