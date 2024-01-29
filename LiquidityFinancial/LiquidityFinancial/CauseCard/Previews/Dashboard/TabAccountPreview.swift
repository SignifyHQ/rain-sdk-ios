import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct AccountPreviews: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    AccountsView(viewModel: AccountViewModel())
  }
  
}

#Preview(body: {
  AccountPreviews()
    .embedInNavigation()
})
