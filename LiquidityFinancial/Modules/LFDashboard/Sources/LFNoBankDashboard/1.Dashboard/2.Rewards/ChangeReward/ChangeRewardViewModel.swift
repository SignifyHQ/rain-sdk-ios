import Foundation
import AccountDomain
import LFUtilities
import Factory
import LFTransaction
import DashboardComponents

@MainActor
class ChangeRewardViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager

  @Published var isChangingCurrency: Bool = false
  @Published var toastMessage: String?
  @Published var availableCurrencies: [AssetType]
  @Published var selectedRewardCurrency: AssetType?
  @Published var navigation: Navigation?
  
  private var previousRewardCurrency: AssetType?
  
  var isDisableButton: Bool {
    previousRewardCurrency == selectedRewardCurrency
  }
  
  init(availableCurrencies: [AssetType], selectedRewardCurrency: AssetType?) {
    self.availableCurrencies = availableCurrencies
    self.selectedRewardCurrency = selectedRewardCurrency
    self.previousRewardCurrency = selectedRewardCurrency
  }
}

// MARK: - API Functions
extension ChangeRewardViewModel {
  func onSelectedRewardCurrency(assetType: AssetType) {
    selectedRewardCurrency = assetType
  }
  
  func onSaveRewardCurrency() {
    guard let rewardCurrency = selectedRewardCurrency?.rawValue else { return }
    Task {
      defer { isChangingCurrency = false }
      isChangingCurrency = true
      do {
        let response = try await accountRepository.updateSelectedRewardCurrency(rewardCurrency: rewardCurrency)
        previousRewardCurrency = AssetType(rawValue: response.rewardCurrency)
        accountDataManager.selectedRewardCurrencySubject.send(response)
      } catch {
        selectedRewardCurrency = previousRewardCurrency
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - View Helpers
extension ChangeRewardViewModel {
  func onClickedCurrentRewardsButton() {
    navigation = .currentRewards
  }
}

// MARK: - Types
extension ChangeRewardViewModel {
  enum Navigation {
    case currentRewards
  }
}
