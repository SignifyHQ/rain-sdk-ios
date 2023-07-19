import Foundation

@MainActor
final class KYCStatusViewModel: ObservableObject {
  @Published var state: KYCState = .idle
  @Published var presentation: Presentation?
  let username: String = "Ryan" // HARDCODE for username
  private var fetchCount = 0
  private var autoRefreshTimer: Timer?

  init() {}
}

// MARK: - View Helpers
extension KYCStatusViewModel {
  func openIntercom() {
    // intercomService.openIntercom()
  }
  
  func magicTapToLogout() {
    // userManager.logout()
  }
  
  func primaryAction() {
    //    switch state {
    //      case .declined:
    //        cancellables.removeAll()
    //        userManager.logout()
    //      case .inReview:
    //        state = .idle
    //        updateUser()
    //      case let .pendingIDV(_, url):
    //        presentation = .idv(url)
    //      default:
    //        log.error(LiquidityError.logic, "Invalid state primary action requested", userInfo: ["state": state])
    //    }
  }
  
  func idvComplete() {
    presentation = nil
    addRefreshTimer()
  }
  
  func secondaryAction() {
    switch state {
      case .inReview:
        openIntercom()
      default:
        break
    }
  }
}

// MARK: - Private Functions
private extension KYCStatusViewModel {
  func addRefreshTimer() {
    // guard !isPolling else { return }
    //    fetchCount = 0
    //    state = .loading
    //    updateUser()
    //    autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
    //      guard let self = self else { return }
    //      DispatchQueue.main.async {
    //        self.updateUser()
    //      }
    //    }
  }
  
  func clearRefreshTimer() {
    autoRefreshTimer?.invalidate()
  }
  
  func incrementTimer() {
    fetchCount += 1
    if fetchCount > 5 {
      clearRefreshTimer()
    }
  }
}

// MARK: - Types
extension KYCStatusViewModel {
  enum Presentation: Identifiable {
    case idv(URL)
    
    var id: String {
      switch self {
        case .idv: return "idv"
      }
    }
  }
}
