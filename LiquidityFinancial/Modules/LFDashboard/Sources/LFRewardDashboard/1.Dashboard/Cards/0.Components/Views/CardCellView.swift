import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct CardCellView: View {
  let cardModel: CardModel
  
  var body: some View {
    HStack(alignment: .top) {
      leadingView
      Spacer()
      trailingView
    }
    .padding(.top, 16)
    .padding(.horizontal, 16)
    .frame(height: 100)
    .background(cardModel.backgroundColor)
    .cornerRadius(8, corners: [.topLeft, .topRight])
  }
}

// MARK: View Components
private extension CardCellView {
  @ViewBuilder
  var leadingView: some View {
    if cardModel.isDisplayLogo {
      // TODO: - We will handle merchantLocked logo later
      GenImages.Images.icContrastLogo.swiftUIImage
        .resizable()
        .frame(40)
        .scaledToFit()
        .foregroundColor(cardModel.textColor)
    } else {
      Text(cardModel.cardName)
        .foregroundColor(cardModel.textColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .lineLimit(2)
        .multilineTextAlignment(.leading)
    }
  }
  
  var trailingView: some View {
    VStack(alignment: .trailing, spacing: 8) {
      if cardModel.cardStatus == .disabled || cardModel.cardStatus == .unactivated {
        CirclePauseIconView(size: .small, backgroundColor: cardModel.textColor)
      }
      Text(cardModel.cardType.title)
      Text("****\(cardModel.last4)")
      Spacer()
    }
    .foregroundColor(cardModel.textColor)
    .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
  }
}
