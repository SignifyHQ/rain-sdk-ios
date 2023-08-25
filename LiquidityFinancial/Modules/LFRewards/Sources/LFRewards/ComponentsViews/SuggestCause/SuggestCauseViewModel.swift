import Foundation
import Factory
import RewardData
import RewardDomain
import LFUtilities

@MainActor
public class SuggestCauseViewModel: ObservableObject {
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  @Published var isLoading: Bool = false
  @Published var showSuccess: Bool = false

  func submitCause(name: String) {
    Task { @MainActor in
      do {
        defer { isLoading = false }
        isLoading = true
        _ = try await rewardUseCase.postDonationsSuggest(name: name)
        showSuccess = true
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
}
