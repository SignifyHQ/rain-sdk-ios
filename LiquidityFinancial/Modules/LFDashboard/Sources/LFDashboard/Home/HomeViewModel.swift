import Foundation
import Factory
import OnboardingData
import AccountData
import LFUtilities
import AuthorizationManager

@MainActor
public final class HomeViewModel: ObservableObject {
  @Published var tabSelected: TabOption = .cash
  @Published var isShowGearButton: Bool = false
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
#if DEBUG
  var countMangicLogout: Int = 0
#endif
  
  public init() { }
}

// MARK: - View Helpers
extension HomeViewModel {
  func onSelectedTab(tab: TabOption) {
    tabSelected = tab
  }
  
  func onClickedProfileButton() {
    logout()
  }
  
  func onClickedGearButton() {
    
  }
}

private extension HomeViewModel {
  func logout() {
#if DEBUG
    countMangicLogout += 1
    if countMangicLogout >= 5 {
      countMangicLogout = 0
      authorizationManager.clearToken()
      accountDataManager.clearUserSession()
    }
#endif
  }
}
