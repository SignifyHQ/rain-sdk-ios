import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct CausesPreview: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    CausesView(viewModel: CausesViewModel())
  }
  
}

#Preview(body: {
  CausesPreview()
    .embedInNavigation()
})
