import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct ProfilePreviews: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    ProfileView()
  }
  
}

#Preview(body: {
  ProfilePreviews()
    .embedInNavigation()
})
