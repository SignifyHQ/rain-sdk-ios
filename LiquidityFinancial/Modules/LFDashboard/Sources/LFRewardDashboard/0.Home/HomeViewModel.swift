import UIKit
import Foundation
import Factory
import OnboardingData
import AccountData
import AccountDomain
import LFUtilities
import RewardData
import RewardDomain
import LFRewards
import Combine

@MainActor
public final class HomeViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  @Published var tabSelected: TabOption = .cash
  @Published var navigation: Navigation?
  @Published var tabOptions: [TabOption] = [.cash, .rewards, .account]
  
  private var subscribers: Set<AnyCancellable> = []
  
  private var isFristLoad: Bool = true
  init(tabOptions: [TabOption]) {
    self.tabOptions = tabOptions
    apiFetchUser()
    handleSelectRewardChange()
    handleSelectedFundraisersSuccess()
  }
  
  var showGearButton: Bool {
    tabSelected == .rewards || tabSelected == .donation
  }
}

// MARK: - API Reward
private extension HomeViewModel {
  func handleSelectedFundraisersSuccess() {
    NotificationCenter.default.publisher(for: .selectedFundraisersSuccess)
      .delay(for: 0.55, scheduler: RunLoop.main)
      .sink { [weak self] _ in
        guard self?.rewardDataManager.fundraisersDetail != nil else { return }
        self?.tabSelected = .donation
      }
      .store(in: &subscribers)
  }
  
  func handleSelectRewardChange() {
    rewardDataManager
      .selectRewardChangedEvent
      .receive(on: DispatchQueue.main)
      .sink { [weak self] reward in
        self?.buildTabOption(with: reward)
        self?.updateTabSelected(with: reward)
        self?.isFristLoad = false
      }
      .store(in: &subscribers)
  }
  
  func buildTabOption(with reward: SelectRewardTypeEntity) {
    let rewardList: [TabOption] = [.cash, .rewards, .account]
    let donationList: [TabOption] = [.cash, .donation, .causes, .account]
    switch reward.rawString {
    case UserRewardType.cashBack.rawValue:
      tabOptions = rewardList
    case UserRewardType.donation.rawValue:
      tabOptions = donationList
    default:
      tabOptions = rewardList
    }
  }
  
  func updateTabSelected(with reward: SelectRewardTypeEntity) {
    guard isFristLoad == false else { return }
    switch reward.rawString {
    case UserRewardType.cashBack.rawValue:
      tabSelected = .rewards
    case UserRewardType.donation.rawValue:
      tabSelected = .donation
    default:
      tabSelected = .cash
    }
  }
}

// MARK: - API User
private extension HomeViewModel {
  func apiFetchUser() {
    if let userID = accountDataManager.userInfomationData.userID, userID.isEmpty == false {
      return
    }
    Task {
      do {
        let user = try await accountRepository.getUser()
        handleDataUser(user: user)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    if let rewardType = APIRewardType(rawValue: user.userRewardType ?? "") {
      rewardDataManager.update(currentSelectReward: rewardType)
    }
    if let userSelectedFundraiserID = user.userSelectedFundraiserId {
      rewardDataManager.update(selectedFundraiserID: userSelectedFundraiserID)
    }
    if let firstName = user.firstName, let lastName = user.lastName {
      accountDataManager.update(fullName: firstName + " " + lastName)
    }
  }
}

// MARK: - View Helpers
extension HomeViewModel {
  func onSelectedTab(tab: TabOption) {
    tabSelected = tab
  }
  
  func onClickedProfileButton() {
    navigation = .profile
  }
  
  func onClickedGearButton() {
    navigation = .editRewards
  }
}

// MARK: - Types
extension HomeViewModel {
  enum Navigation {
    case searchCauses
    case editRewards
    case profile
  }
}
