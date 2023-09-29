import SwiftUI
import Factory
import LFUtilities
import LFServices

@MainActor
final class ReferralsViewModel: ObservableObject {
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  private lazy var enviromentManager = EnvironmentManager()
  @Published var status = Status.loading
  @Published var showShareSheet = false
  @Published var showCopyToast = false
  
  var referralLink = ""
  private var referralLinkEnvironment: String {
    enviromentManager.networkEnvironment == .productionTest ? LFUtilities.referrallinkDev : LFUtilities.referrallinkProd
  }
}

// MARK: - API
extension ReferralsViewModel {
  private func fetchCampaigns() {
    let userData = accountDataManager.userInfomationData
    status = .loading
    referralLink = referralLinkEnvironment + (userData.referralLink ?? "")
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
    analyticsService.track(event: AnalyticsEvent(name: .viewsInviteFriends))
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
