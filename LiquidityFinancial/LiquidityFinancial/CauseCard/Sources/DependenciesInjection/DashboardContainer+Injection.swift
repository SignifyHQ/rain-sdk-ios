import Foundation
import Factory
import LFDashboard

@MainActor
extension Container {
  // ViewModels
  var homeViewModel: Factory<HomeViewModel> {
    self {
      HomeViewModel()
    }
  }
}
