import SwiftUI
import LFLocalizable
import LFUtilities
import LFTransaction
import LFRewards
import Factory
import RewardData
import RewardDomain
import Combine

@MainActor
class DonationsViewModel: ObservableObject {
  private var total: Int = 0
  private var offset = 0
  private var limit = 100
  
  let tabRedirection: TabRedirection
  
  @Published var showRoundUpDonation: Bool = false
  @Published var status = Status.idle
  @Published var isLoading = true
  @Published var navigation: Navigation?
  @Published var selectedOption = Option.userDonations {
    didSet {
      switch selectedOption {
      case .fundraiserDonations:
        Task { @MainActor in
          await apiFetchFundraiserDetail()
        }
      case .userDonations:
        Task { @MainActor in
          await apiFetchContribution()
        }
      }
    }
  }
  
  @Published var selectedFundraiser: FundraiserDetailModel?

  @Published var contributionData: DataStatus<RewardTransactionRowModel> = .idle
  @Published var latestDonationData: DataStatus<RewardTransactionRowModel> = .idle

  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  private var subscribers: Set<AnyCancellable> = []
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  init(tabRedirection: @escaping TabRedirection) {
    self.tabRedirection = tabRedirection
    self.handleSelectedFundraisersSuccess()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

  // MARK: - Actions

extension DonationsViewModel {
  func refresh() {
    switch selectedOption {
    case .fundraiserDonations:
      Task { @MainActor in
        await apiFetchFundraiserDetail()
      }
    case .userDonations:
      Task { @MainActor in
        await apiFetchContribution()
      }
    }
  }
  
  func onAppear() {
    if selectedFundraiser == nil {
      Task { @MainActor in
        defer { isLoading = false }
        isLoading = true
        await fetchAll()
        //TODO: Implement late, now is disable from BE
        //handleShowRoundUpDonationPopup()
      }
    } else {
      isLoading = false
    }
  }
  
  func selectCharityTapped() {
    guard let causesEntity = rewardDataManager.rewardCategories else { return }
    let causes = causesEntity.data.compactMap({ CauseModel(rewardData: $0) })
    self.navigation = .causeCategories(causes)
  }
  
  func transactionItemTapped(donationID: String, fundraisersID: String) {
    navigation = .transactionDetail(donationID, fundraisersID)
  }
  
  func handleSelectedFundraisersSuccess() {
    NotificationCenter.default.publisher(for: .selectedFundraisersSuccess)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let entity = self?.rewardDataManager.fundraisersDetail else { return }
        self?.selectedFundraiser = FundraiserDetailModel(enity: entity)
      }
      .store(in: &subscribers)
  }
  
  func handleShowRoundUpDonationPopup() {
    guard let userRoundUpEnabled = accountDataManager.userInfomationData.userRoundUpEnabled else { return }
    guard !userRoundUpEnabled && UserDefaults.showRoundUpForCause else { return }
    UserDefaults.showRoundUpForCause = false
    showRoundUpDonation.toggle()
  }
}

  // MARK: - API logic

extension DonationsViewModel {
  private func fetchAll() async {
    await apiFetchContribution()
    await apiFetchFundraiserDetail()
  }
  
  private func apiFetchContribution() async {
    self.contributionData = .loading
    do {
      let contribution = try await rewardUseCase.getContributionList(limit: limit, offset: offset)
      let model = contribution.data.compactMap({ ContributionModel(entity: $0) })
      self.contributionData = .success(model.compactMap({ RewardTransactionRowModel(contribution: $0) }))
    } catch {
      self.contributionData = .failure(error.localizedDescription)
      log.error(error.localizedDescription)
    }
  }
  
  private func apiFetchFundraiserDetail() async {
    guard let selectedFundraiserID = rewardDataManager.selectedFundraiserID else { return }
    self.latestDonationData = .loading
    do {
      let enity = try await rewardUseCase.getFundraisersDetail(fundraiserID: selectedFundraiserID)
      self.selectedFundraiser = FundraiserDetailModel(enity: enity)
      self.rewardDataManager.update(fundraisersDetail: enity)
      
      let latestDonations = self.selectedFundraiser?.latestDonations ?? []
      self.latestDonationData = .success(latestDonations.compactMap({ RewardTransactionRowModel(latestDonation: $0) }))
    } catch {
      self.latestDonationData = .failure(error.localizedDescription)
      log.error(error.localizedDescription)
    }
  }
}

extension DonationsViewModel {
  enum Status {
    case idle
    case loading
    case success(Data)
    case failure
  }
  
  enum Navigation {
    case causeCategories([CauseModel])
    case transactionDetail(String, String)
  }
  
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
}
