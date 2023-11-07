import Foundation
import RewardData
import RewardDomain
import Factory
import LFUtilities

@MainActor
public class SelectCauseCategoriesViewModel: ObservableObject {
  private var total: Int = 0
  private var offset = 0
  private var limit = 100
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.rewardFlowCoordinator) var rewardFlowCoordinator
  
  @Published var selected: [CauseModel] = []
  @Published var isLoading = false
  @Published var navigation: Navigation?
  @Published var showError = false
  
  lazy var selectRewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  let causes: [CauseModel]
  
  var isContinueEnabled: Bool {
    !selected.isEmpty
  }
  
  public init(causes: [CauseModel]) {
    self.causes = causes
  }
  
  func isSelected(cause: CauseModel) -> Bool {
    selected.contains(cause)
  }
  
  func onTap(cause: CauseModel) {
    selected.removeAll()
    selected.append(cause)
    //TODO: Currently we don't support multiple select cause and wait BE update for it
    //    if let index = selected.firstIndex(of: cause) {
    //      selected.remove(at: index)
    //    } else {
    //      selected.append(cause)
    //    }
  }
  
  func continueTapped() {
    apiFetchCategoriesFundraisers {
      
    }
  }
  
  func skipAndDumpToYourAccount() {
    rewardFlowCoordinator.set(route: .yourAccount)
  }
  
  // swiftlint:disable force_unwrapping
  private func apiFetchCategoriesFundraisers(onCompletion: @escaping () -> Void) {
    Task {
      defer { isLoading = false }
      isLoading = true
      let categoryId = selected.first?.id ?? ""
      do {
        let fundraisers = try await selectRewardUseCase.getCategoriesFundraisers(categoryID: categoryId, limit: limit, offset: offset)
        let fundraiserModels = fundraisers.data.compactMap({ FundraiserModel(fundraiserData: $0) })
        rewardDataManager.update(fundraisers: fundraisers)
        self.navigation = .selectFundraiser(selected.first!, fundraiserModels)
      } catch {
        log.error(error.localizedDescription)
        showError = true
      }
    }
  }
  
}

extension SelectCauseCategoriesViewModel {
  enum Navigation {
    case selectFundraiser(CauseModel, [FundraiserModel])
  }
}
