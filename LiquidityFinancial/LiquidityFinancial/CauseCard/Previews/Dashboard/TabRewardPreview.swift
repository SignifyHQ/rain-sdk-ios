import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct RewardPreviews: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    RewardsView(viewModel: RewardViewModel())
  }
  
}

#Preview(body: {
  RewardPreviews()
    .embedInNavigation()
})
