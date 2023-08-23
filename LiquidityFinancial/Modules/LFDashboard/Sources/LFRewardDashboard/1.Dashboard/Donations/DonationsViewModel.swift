import SwiftUI
import LFLocalizable
import LFUtilities
import LFTransaction
import LFRewards
import Factory
import RewardData
import RewardDomain

@MainActor
class DonationsViewModel: ObservableObject {
  private var total: Int = 0
  private var offset = 0
  private var limit = 100
  
  let tabRedirection: TabRedirection
  @Published var selectedFundraiser: FundraiserDetailModel?
  @Published var latestDonationModel: [FundraiserDetailModel.LatestDonation] = []
  @Published var contributionModel: [ContributionModel] = []
  @Published var isLoading = true
  @Published var isPushToSelectCauseView = false
  @Published var userDonations: DataStatus<TransactionModel> = .idle
  @Published var fundraiserDonations: DataStatus<TransactionModel> = .idle
  @Published var selectedOption = Option.userDonations
  @Published var sheet: Sheet?
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  init(tabRedirection: @escaping TabRedirection) {
    self.tabRedirection = tabRedirection
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

  // MARK: - Actions

extension DonationsViewModel {
  func refresh() {
    Task {
      do {
        defer { isLoading = false }
        isLoading = true
        try await fetchAll()
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func selectCharityTapped() {
    isPushToSelectCauseView = true
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    sheet = .transactionDetail(transaction)
  }
}

  // MARK: - API logic

extension DonationsViewModel {
  private func fetchAll() async throws {
    guard let fundraisersDetail = rewardDataManager.fundraisersDetail else { return }
    try await loadContribution()
    self.selectedFundraiser = FundraiserDetailModel(enity: fundraisersDetail)
    self.latestDonationModel = selectedFundraiser?.latestDonations ?? []
  }
  
  private func loadContribution() async throws {
    let contribution = try await rewardUseCase.getContributionList(limit: limit, offset: offset)
    self.contributionModel = contribution.data.compactMap({ ContributionModel(entity: $0) })
  }
}

extension DonationsViewModel {
  enum Option: String, Identifiable, CaseIterable {
    case userDonations
    case fundraiserDonations
    
    var id: String {
      rawValue
    }
    
    var title: String {
      switch self {
      case .userDonations:
        return LFLocalizable.Donations.userDonations
      case .fundraiserDonations:
        return LFLocalizable.Donations.fundraiserDonations
      }
    }
  }
  
  enum Sheet: Identifiable {
    case transactionDetail(TransactionModel)
    
    var id: String {
      switch self {
      case let .transactionDetail(item):
        return "transactionDetail-\(item.id)"
      }
    }
  }
}
