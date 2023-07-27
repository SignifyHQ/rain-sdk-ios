import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

public struct ActivateVirtualCardView: View {
  @Environment(\.dismiss) private var dismiss
  let card: CardModel
  @State private var activeContent: ActiveContent = .setCardPin
  
  public init(card: CardModel) {
    self.card = card
  }
  
  public var body: some View {
    content
  }
}

// MARK: View Components
private extension ActivateVirtualCardView {
  @ViewBuilder
  var content: some View {
    switch activeContent {
    case .activedCard:
      activedCardView
    case .setCardPin:
        SetCardPinView {
          activeContent = .activedCard
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
      Spacer()
        .frame(maxHeight: 60)
      VStack(spacing: 60) {
        GenImages.Images.virtualCard.swiftUIImage
        VStack(spacing: 16) {
          Text(LFLocalizable.CardActivated.CardActived.title)
            .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.large.value))
            .foregroundColor(Colors.label.swiftUIColor)
            .multilineTextAlignment(.center)
          Text(LFLocalizable.CardActivated.CardActived.description(LFUtility.appName))
            .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
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
      .padding(.leading, 16)
    }
  }
}

// MARK: - Types
extension ActivateVirtualCardView {
  enum ActiveContent {
    case setCardPin
    case activedCard
    case addAppleWallet
  }
}
