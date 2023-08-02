import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

public struct ActivatePhysicalCardView: View {
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

// MARK: View Components
private extension ActivatePhysicalCardView {
  @ViewBuilder
  var content: some View {
    switch activeContent {
    case .cvvCode:
      EnterCVVCodeView(cardID: card.id, screenTitle: LFLocalizable.EnterCVVCode.ActiveCard.title) { verifyID in
          activeContent = .setCardPin(verifyID)
      }
    case let .setCardPin(verifyID):
      SetCardPinView(verifyID: verifyID, cardID: card.id) { cardID in
        activeContent = .activedCard
        onSuccess?(cardID)
      }
    case .activedCard:
      activedCardView
    case .addAppleWallet:
      AddAppleWalletView(
        card: card
      ) {
        dismiss()
      }
    }
  }
  
  var activedCardView: some View {
    VStack(spacing: 16) {
      Spacer()
        .frame(maxHeight: 60)
      VStack(spacing: 60) {
        GenImages.Images.physicalCard.swiftUIImage
        VStack(spacing: 16) {
          Text(LFLocalizable.CardActivated.CardActived.title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.large.value))
            .foregroundColor(Colors.label.swiftUIColor)
            .multilineTextAlignment(.center)
          Text(LFLocalizable.CardActivated.CardActived.description(LFUtility.appName))
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
        }
      }
      Spacer()
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: false
      ) {
        activeContent = .addAppleWallet
      }
      .padding(.bottom, 12)
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .overlay(alignment: .topLeading) {
      Button {
        dismiss()
      } label: {
        CircleButton(style: .xmark)
      }
      .padding(.top, 10)
      .padding(.leading, 16)
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
