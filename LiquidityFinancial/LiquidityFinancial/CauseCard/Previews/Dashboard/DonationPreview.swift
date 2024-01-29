import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature
import Factory

//swiftlint:disable all
struct DonationPreview: View {
  
  @Injected(\.rewardDataManager) var rewardDataManager
  
  init() {
    //PreviewHelpers.mockUserLogin()
    rewardDataManager.update(selectedFundraiserID: "00076df3-0647-433c-b044-22027fab87a6")
  }
  
  var body: some View {
    DonationsView(viewModel: DonationsViewModel())
  }
  
}

#Preview(body: {
  DonationPreview()
    .embedInNavigation()
})
