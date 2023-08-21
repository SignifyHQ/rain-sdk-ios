import UIKit
import Foundation
import Factory
import OnboardingData
import AccountData
import LFUtilities

@MainActor
public final class HomeViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var isShowGearButton: Bool = false
  @Published var tabSelected: TabOption = .cash
  @Published var navigation: Navigation?
  
  public init() {
    getUser()
  }
}

// MARK: - API
extension HomeViewModel {
  private func getUser() {
    if let userID = accountDataManager.userInfomationData.userID, userID.isEmpty == false {
      return
    }
    Task {
      do {
        let user = try await accountRepository.getUser()
        accountDataManager.storeUser(user: user)
        if let firstName = user.firstName, let lastName = user.lastName {
          accountDataManager.update(fullName: firstName + " " + lastName)
        }
      } catch {
        log.error(error.localizedDescription)
      }
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
