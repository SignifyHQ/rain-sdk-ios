import Foundation
import LFUtilities
import RewardData
import RewardDomain
import Factory
import LFRewards

@MainActor
final class EditRewardsViewModel: ObservableObject {
  private var total: Int = 0
  private var offset = 0
  private var limit = 100
  
  @Published var rowModel: [RewardsViewModel] = []
  @Published var showError = false
  @Published var isLoading = false
  @Published var navigation: Navigation?

  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  var rowModelSelecting: RewardsViewModel?
  
  var isDisableButton: Bool {
    UserRewardType(
      rawValue: rewardDataManager.currentSelectReward?.rawString ?? .empty
    ) == rowModelSelecting?.rewardSelecting
  }
  
  private var selected: UserRewardType? {
    if let rewardTypeRaw = rewardDataManager.currentSelectReward, let rewardType = UserRewardType(rawValue: rewardTypeRaw.rawString) {
      return rewardType
    }
    return nil
  }
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  init() {
    rowModel = [
      RewardsViewModel(rewardSelecting: .cashBack, isSelect: false),
      RewardsViewModel(rewardSelecting: .donation, isSelect: false)
    ]
    updateRewardSelected(rewardTypeEntity: rewardDataManager.currentSelectReward)
  }
}

// MARK: - API Functions
extension EditRewardsViewModel {
  func apiFetchDetailFundraiser(fundraiserID: String) async throws {
    let enity = try await rewardUseCase.getFundraisersDetail(fundraiserID: fundraiserID)
    rewardDataManager.update(fundraisersDetail: enity)
  }
  
  private func apiFetchCategories() async {
    do {
      let categories = try await rewardUseCase.getDonationCategories(limit: limit, offset: offset)
      rewardDataManager.update(rewardCategories: categories)
      let causeCategories = categories.data.compactMap({ CauseModel(rewardData: $0) })
      self.navigation = .selectFundraiser(causeCategories)
    } catch {
      log.error(error.localizedDescription)
      showError = true
    }
  }
  
  func apiSelecteRewardType() {
    let param: [String: Any] = [
      "updateRewardTypeRequest": [
        "rewardType": rowModelSelecting?.rewardSelecting.rawValue
      ]
    ]
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let entity = try await rewardUseCase.selectReward(body: param)
        let rewardType = UserRewardType(rawValue: entity.rewardType?.rawString ?? "NONE") ?? .none

        switch rewardType {
        case .cashBack:
          rewardDataManager.update(currentSelectReward: APIRewardType.cashBack)
        case .donation:
          if let fundraiserID = accountDataManager.userInfomationData.userSelectedFundraiserID {
            try await apiFetchDetailFundraiser(fundraiserID: fundraiserID)
          }
          rewardDataManager.update(currentSelectReward: APIRewardType.donation)
        case .none: // BE will fallback type None when user had select rewardtype but not select fundraiser
          updateRewardSelected(rewardTypeEntity: APIRewardType.none)
          await apiFetchCategories()
        default:
          updateRewardSelected(rewardTypeEntity: APIRewardType.none)
        }
      } catch {
        updateRewardSelected(rewardTypeEntity: rewardDataManager.currentSelectReward)
        log.error("Failed to select reward \(error.localizedDescription)")
        showError = true
      }
    }
  }
}

// MARK: - View Helpers
extension EditRewardsViewModel {
  func selection(_ item: RewardsViewModel) -> UserRewardRowView.Selection {
    switch item.rewardSelecting {
    case .cashBack:
      return item.isSelect ? .selected : .unselected
    case .donation:
      return item.isSelect ? .selected : .unselected
    default:
      return .unselected
    }
  }
  
  private func updateRewardSelected(rewardTypeEntity: SelectRewardTypeEntity?) {
    guard let rewardTypeRaw = rewardTypeEntity, let rewardType = UserRewardType(rawValue: rewardTypeRaw.rawString) else { return }
    switch rewardType {
    case .cashBack:
      let news = [
        RewardsViewModel(rewardSelecting: .cashBack, isSelect: true),
        RewardsViewModel(rewardSelecting: .donation, isSelect: false)
      ]
      rowModel = news
      rowModelSelecting = news.first(where: { $0.isSelect })
    case .donation:
      let news = [
        RewardsViewModel(rewardSelecting: .cashBack, isSelect: false),
        RewardsViewModel(rewardSelecting: .donation, isSelect: true)
      ]
      rowModel = news
      rowModelSelecting = news.first(where: { $0.isSelect })
    default:
      rowModel.forEach({ $0.isSelect = false })
    }
  }
  
  func handlePopToRootView() {
    rewardDataManager.update(currentSelectReward: APIRewardType.none)
    LFUtilities.popToRootView()
    navigation = nil
  }
  
  func handleSelectedFundraisersSuccess() {
    rewardDataManager.update(currentSelectReward: APIRewardType.donation)
    updateRewardSelected(rewardTypeEntity: APIRewardType.donation)
    LFUtilities.popToRootView()
    navigation = nil
  }
  
  func onSelectedReward(_ item: RewardsViewModel) {
    rowModelSelecting = item
    switch item.rewardSelecting {
    case .cashBack:
      updateRewardSelected(rewardTypeEntity: APIRewardType.cashBack)
    case .donation:
      updateRewardSelected(rewardTypeEntity: APIRewardType.donation)
    default: break
    }
  }
  
  func onClickedCurrentRewardsButton() {
    navigation = .currentRewards
  }
}

// MARK: - Types
extension EditRewardsViewModel {
  enum Navigation {
    case currentRewards
    case selectFundraiser([CauseModel])
  }
  
  class RewardsViewModel: Identifiable {
    var id: String = UUID().uuidString
    var rewardSelecting: UserRewardType
    var isSelect: Bool
    
    init(rewardSelecting: UserRewardType, isSelect: Bool) {
      self.rewardSelecting = rewardSelecting
      self.isSelect = isSelect
    }
  }
}
