import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct CardsTabPreview: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    CardsTabView()
  }
  
}

#Preview(body: {
  CardsTabPreview()
    .embedInNavigation()
})
