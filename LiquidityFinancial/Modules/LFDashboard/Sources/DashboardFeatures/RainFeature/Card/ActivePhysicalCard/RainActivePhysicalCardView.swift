import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct RainActivePhysicalCardView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var activeContent: ActiveContent = .enterPanLastFour
  let card: CardModel
  let onSuccess: ((String) -> Void)?
  
  init(card: CardModel, onSuccess: ((String) -> Void)? = nil) {
    self.card = card
    self.onSuccess = onSuccess
  }
  
  var body: some View {
    content
  }
}

// MARK: - View Components
private extension RainActivePhysicalCardView {
  @MainActor @ViewBuilder var content: some View {
    switch activeContent {
    case .enterPanLastFour:
      RainEnterLastFourNumbersView(
        viewModel: RainEnterLastFourNumbersViewModel(cardID: card.id),
        screenTitle: L10N.Common.EnterLastFourNumbers.ActiveCard.title
      ) { cardID in
        onSuccess?(cardID)
        activeContent = .activedCard
      }
    case .activedCard:
      activedCardView
    case .addAppleWallet:
      RainAddAppleWalletView(
        viewModel: RainAddAppleWalletViewModel(cardModel: card) {
          dismiss()
        }
      )
    }
  }
  
  var activedCardView: some View {
    VStack(
      spacing: 16
    ) {
      VStack(spacing: 40) {
        GenImages.Images.physicalCard.swiftUIImage
        
        activedCardTextView
      }
      
      Spacer()
      
      buttonGroupView
    }
    .padding(.top, 64)
    .padding(.horizontal, 30)
    .background(Colors.background.swiftUIColor)
    .overlay(
      alignment: .topLeading
    ) {
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
  
  var activedCardTextView: some View {
    VStack(spacing: 16) {
      Text(L10N.Common.CardActivated.CardActived.title)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
      
      Text(L10N.Common.CardActivated.CardActived.description(LFUtilities.cardName))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .multilineTextAlignment(.center)
        .lineLimit(3)
        .fixedSize(horizontal: false, vertical: true)
    }
  }
  
  var buttonGroupView: some View {
    VStack(spacing: 10) {
      // applePay TODO: - Temporarily hide this button
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: false
      ) {
        dismiss()
      }
    }
    .padding(.bottom, 16)
  }
}

// MARK: - Types
extension RainActivePhysicalCardView {
  enum ActiveContent {
    case enterPanLastFour
    case activedCard
    case addAppleWallet
  }
}
