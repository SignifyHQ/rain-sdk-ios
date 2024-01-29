import LFRewardDashboard
import SwiftUI
import LFUtilities
import SolidFeature

//swiftlint:disable all
struct BalanceAlertPreview: View {
  
  init() {
    //PreviewHelpers.mockUserLogin()
  }
  
  var body: some View {
    BalanceAlertView(type: .cash, hasContacts: true, cashBalance: 0) {
      
    }
  }
  
}

#Preview(body: {
  BalanceAlertPreview()
    .embedInNavigation()
    .padding(20)
})
