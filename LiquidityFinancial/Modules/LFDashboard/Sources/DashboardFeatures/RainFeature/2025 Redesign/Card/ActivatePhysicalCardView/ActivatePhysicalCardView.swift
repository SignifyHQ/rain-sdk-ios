import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

struct ActivatePhysicalCardView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var activeContent: ActiveContent = .enterPanLastFour
  
  let card: CardModel
  let onSuccess: ((String) -> Void)?
  let onDismiss: (() -> Void)?
  
  init(
    card: CardModel,
    onSuccess: ((String) -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
  ) {
    self.card = card
    self.onSuccess = onSuccess
    self.onDismiss = onDismiss
  }
  
  var body: some View {
    content
      .appNavBar(
        navigationTitle: L10N.Common.ActivatePhysicalCard.Screen.title,
        isBackButtonHidden: activeContent == .activedCard
      )
      .padding(.top, 8)
      .padding(.bottom, 16)
      .padding(.horizontal, 24)
      .background(Colors.baseAppBackground2.swiftUIColor)
  }
}

// MARK: - View Components
extension ActivatePhysicalCardView {
  @ViewBuilder
  var content: some View {
    switch activeContent {
    case .enterPanLastFour:
      ActivatePhysicalCardInputView(
        viewModel: ActivatePhysicalCardInputViewModel(cardID: card.id)
      ) { cardID in
        withAnimation {
          activeContent = .activedCard
        }
      }
    case .activedCard:
      activedCardView
    }
  }
  
  var activedCardView: some View {
    VStack(
      spacing: 16
    ) {
      activedCardTextView
      
      Spacer()
      
      GenImages.Images.physicalCardBackdrop.swiftUIImage
        .resizable()
        .frame(width: 175, height: 280, alignment: .center)
        .shadow(
          color: Colors.backgroundAlternative.swiftUIColor,
          radius: 20,
          x: 2,
          y: 2
        )
      
      Spacer()
      
      FullWidthButton(
        title: L10N.Common.Common.Close.Button.title
      ) {
        if activeContent == .activedCard {
          onSuccess?(card.id)
        }
        
        onDismiss?() ?? dismiss()
      }
    }
  }
  
  var activedCardTextView: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        
        Text(L10N.Common.ActivatePhysicalCard.ActivatedCard.title)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .multilineTextAlignment(.leading)
        
        Text(L10N.Common.ActivatePhysicalCard.ActivatedCard.description(LFUtilities.cardName))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textSecondary.swiftUIColor)
          .multilineTextAlignment(.leading)
      }
      .frame(maxWidth: .infinity)
      
      Spacer()
    }
  }
}

// MARK: - Types
extension ActivatePhysicalCardView {
  enum ActiveContent {
    case enterPanLastFour
    case activedCard
  }
}
