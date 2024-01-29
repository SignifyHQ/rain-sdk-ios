import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct ReferralsPreview: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    ReferralsView()
  }
  
}

#Preview(body: {
  ReferralsPreview()
    .embedInNavigation()
})
