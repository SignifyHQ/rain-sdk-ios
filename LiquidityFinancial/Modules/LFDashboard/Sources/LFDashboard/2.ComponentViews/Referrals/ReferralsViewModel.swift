import SwiftUI
import Factory

@MainActor
final class ReferralsViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager

  @Published var status = Status.loading
  @Published var showShareSheet = false
  @Published var showCopyToast = false
  
  private var referralLink = ""

  init() {
  }
}

// MARK: - API
extension ReferralsViewModel {
  private func fetchCampaigns() {
    let userData = accountDataManager.userInfomationData
    status = .loading
    referralLink = userData.referralLink ?? ""
    // TODO: Will be implemented later
    // FAKE CALL API
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.status = .success(
        ReferralCampaign(
          name: "MockData",
          inviterBonusAmount: "500",
          inviteeBonusAmount: "15",
          currency: "USD",
          period: 60,
          timeUnit: .day
        )
      )
    }
  }
}

// MARK: - View Helpers
extension ReferralsViewModel {
  var activityItems: [Any] {
    var result: [Any] = []
    if let url = URL(string: referralLink) {
      result.append(url)
    }
    return result
  }
  
  func onAppear() {
    // TODO: - Will be implemented later
    // analyticsService.track(event: Event(name: .viewsInviteFriends))
    fetchCampaigns()
  }
  
  func retry() {
    fetchCampaigns()
  }
  
  func sendTapped() {
    showShareSheet = true
  }
  
  func copyTapped() {
    UIPasteboard.general.string = referralLink
    showCopyToast = true
  }
}

// MARK: - Types
extension ReferralsViewModel {
  enum Status {
    case loading
    case success(ReferralCampaign)
    case failure
  }
}
