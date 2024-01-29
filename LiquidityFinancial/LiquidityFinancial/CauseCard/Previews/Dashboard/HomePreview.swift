import SwiftUI
import LFRewardDashboard
import LFUtilities

//swiftlint:disable all
struct HomePreviews: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    HomeView(viewModel: HomeViewModel(tabOptions: TabOption.allCases))
  }
  
}

#Preview(body: {
  HomePreviews()
    .embedInNavigation()
})
