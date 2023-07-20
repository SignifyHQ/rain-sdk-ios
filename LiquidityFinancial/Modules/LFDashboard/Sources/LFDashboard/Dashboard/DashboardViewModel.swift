import Foundation

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
    //    if userManager.user?.metadata?.waitlistJoined == "true" {
    //      popup = .waitlistJoined
    //    } else if userManager.inReview {
    //      popup = .inReview
    //    } else {
    //      popup = .createAccount
    //    }
  }
  
  func appearOperations() {
    //    deeplinkService.delegate = self
    //
    //    if userManager.inReview || userManager.isApproved {
    //      remoteNotificationService.canPresentSoftPrompt { [weak self] canPresent in
    //        if canPresent {
    //          log.info("presenting permissions soft prompt")
    //          self?.popup = .notifications
    //        }
    //      }
    //    }
    // analyticsService.track(event: Event(name: .viewedHome))
  }
}
