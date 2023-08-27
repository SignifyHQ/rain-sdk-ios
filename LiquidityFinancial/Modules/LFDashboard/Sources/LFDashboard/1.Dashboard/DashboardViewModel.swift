import Foundation
import LFServices
import Factory
import LFUtilities

@MainActor
final class DashboardViewModel: ObservableObject {
  @Published var toastMessage: String?

  let option: TabOption
  let tabRedirection: (TabOption) -> Void
  
  init(option: TabOption, tabRedirection: @escaping ((TabOption) -> Void)) {
    self.option = option
    self.tabRedirection = tabRedirection
  }
}

extension DashboardViewModel {
  func handleGuestUser() {
  }
}
