import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct CashPreviews: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    CashView(listCardViewModel: SolidListCardsViewModel())
      .embedInNavigation()
  }
  
}

#Preview(body: {
  CashPreviews()
})
