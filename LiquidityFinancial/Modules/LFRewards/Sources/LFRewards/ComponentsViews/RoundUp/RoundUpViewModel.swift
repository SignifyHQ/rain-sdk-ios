import Foundation
import RewardData
import RewardDomain
import Factory
import LFUtilities

@MainActor
public class RoundUpViewModel: ObservableObject {

  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  let onFinish: () -> Void
  @Published var isLoading = false
  @Published var showError: String?
  
  public init(onFinish: @escaping () -> Void) {
    self.onFinish = onFinish
  }
  
  func continueTapped() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let body: [String: Any] = [
          "updateRoundUpDonationRequest": [
            "roundUpDonation": true
          ]
        ]
        let entity = try await rewardUseCase.setRoundUpDonation(body: body)
        rewardDataManager.update(roundUpDonation: entity.userRoundUpEnabled ?? false)
        onFinish()
      } catch {
        log.error(error.localizedDescription)
        showError = error.localizedDescription
      }
    }
  }
  
  func skipTapped() {
    onFinish()
  }
}
