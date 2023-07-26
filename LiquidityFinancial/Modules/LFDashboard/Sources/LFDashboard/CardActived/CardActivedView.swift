import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct CardActivatedView: View {
  @Environment(\.dismiss) private var dismiss
  let card: CardModel
  @State private var activeContent: ActiveContent = .activeCard
  
  var body: some View {
    content
  }
}

// MARK: View Components
private extension CardActivatedView {
  @ViewBuilder
  var content: some View {
    switch activeContent {
    case .activeCard:
      activedCardView
          .defaultToolBar(icon: .xMark)
    case .setCardPin:
        SetCardPinView {
          activeContent = .addAppleWallet
        }
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
      GenImages.Images.activedCard.swiftUIImage
      Group {
        Text(LFLocalizable.CardActivated.CardActived.title)
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.large.value))
          .foregroundColor(Colors.label.swiftUIColor)
        
        Text(LFLocalizable.CardActivated.CardActived.description(LFUtility.appName))
          .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
      }
      .multilineTextAlignment(.center)
      Spacer()
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: false
      ) {
        activeContent = .setCardPin
      }
      .padding(.bottom, 12)
    }
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
  }
}

// MARK: - Types
extension CardActivatedView {
  enum ActiveContent {
    case activeCard
    case setCardPin
    case addAppleWallet
  }
}
