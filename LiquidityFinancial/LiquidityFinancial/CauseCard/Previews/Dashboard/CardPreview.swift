import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct CardPreviews: View {
  @State var isNoLinkedCard: Bool
  
  init(isNoLinkedCard: Bool) {
    self.isNoLinkedCard = isNoLinkedCard
  }
  
  var body: some View {
    return CashCardView(
      isNoLinkedCard: $isNoLinkedCard,
      isPOFlow: true,
      showLoadingIndicator: false,
      cashBalance: 100,
      listCardViewModel: SolidListCardsViewModel()
    )
  }
  
}

#Preview(body: {
  CardPreviews(isNoLinkedCard: false)
    .padding(20)
})

