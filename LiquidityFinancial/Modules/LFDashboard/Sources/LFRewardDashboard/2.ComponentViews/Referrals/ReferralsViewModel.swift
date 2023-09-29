import SwiftUI
import Factory
import AccountData
import AccountDomain
import LFUtilities
import LFServices

@MainActor
final class ReferralsViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.analyticsService) var analyticsService

  @Published var status = Status.loading
  @Published var showShareSheet = false
  @Published var showCopyToast = false
  
  private lazy var enviromentManager = EnvironmentManager()
  
  lazy var accountUseCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  private var referralLink = ""
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
    
//    Task { @MainActor in
//      do {
//        let entity = try await accountRepository.getReferralCampaign()
//      } catch {
//        self.status = .failure
//        log.error(error.localizedDescription)
//      }
//    }
    
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
