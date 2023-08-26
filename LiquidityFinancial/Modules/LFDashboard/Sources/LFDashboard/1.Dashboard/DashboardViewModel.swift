import Foundation
import LFServices
import Factory
import LFUtilities

@MainActor
final class DashboardViewModel: ObservableObject {
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  
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
  
  func appearOperations() {
    // TODO: Will implement this later. Will need add the pop up ask user about it first
    // checkShouldShowNotification()
  }
  
  func checkShouldShowNotification() {
    Task { @MainActor in
      do {
        let success = try await pushNotificationService.requestPermission()
        log.info("Request permision \(success)")
      } catch {
        log.error(error)
      }
    }
  }
}
