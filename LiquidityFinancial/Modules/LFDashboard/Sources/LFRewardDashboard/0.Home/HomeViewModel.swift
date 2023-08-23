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
  
  init(tabOptions: [TabOption]) {
    self.tabOptions = tabOptions
    apiFetchUser()
    handleSelectRewardChange()
  }
  
  var showGearButton: Bool {
    tabSelected == .rewards || tabSelected == .donation
  }
}

// MARK: - API Reward
private extension HomeViewModel {
  func handleSelectRewardChange() {
    rewardDataManager
      .selectRewardChangedEvent
      .receive(on: DispatchQueue.main)
      .sink { [weak self] reward in
        self?.reloadTabSelected(with: reward)
        self?.buildTabOption(with: reward)
      }
      .store(in: &subscribers)
  }
  
  func buildTabOption(with reward: SelectRewardTypeEntity) {
    let rewardList: [TabOption] = [.cash, .rewards, .account]
    let donationList: [TabOption] = [.cash, .donation, .causes, .account]
    switch reward.rawString {
    case UserRewardType.cashBack.rawValue:
      self.tabOptions = rewardList
    case UserRewardType.donation.rawValue:
      self.tabOptions = donationList
    default:
      self.tabOptions = rewardList
    }
  }
  
  func reloadTabSelected(with reward: SelectRewardTypeEntity) {
    let currentTabSelected = self.tabSelected
    switch reward.rawString {
    case UserRewardType.cashBack.rawValue:
      if currentTabSelected != .rewards {
        tabSelected = currentTabSelected
      } else {
        tabSelected = .rewards
      }
    case UserRewardType.donation.rawValue:
      if currentTabSelected != .donation {
        tabSelected = currentTabSelected
      } else {
        tabSelected = .donation
      }
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
