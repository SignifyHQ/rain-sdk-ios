import Foundation
import LFUtilities
import LFLocalizable
import Factory
import AccountData
import AccountDomain

final class CurrentRewardViewModel: ObservableObject {

  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .disclosure(let url):
        return url.absoluteString
      }
    }
    
    case disclosure(URL)
  }
  
  struct UserRewardsModel: Identifiable, Equatable {
    var id: String {
      UUID().uuidString
    }
    var rewards: [APIUserRewards]
    var pecialrewards: [APIUserRewards]
  }
  
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isLoading: Bool = false
  @Published var status: DataStatus<UserRewardsModel> = .idle
  
  let disclosureString = L10N.Custom.TransactionDetail.RewardDisclosure.description
  let termsLink = L10N.Common.TransactionDetail.RewardDisclosure.Links.terms
  
  lazy var accountUseCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  let notIncludeFiat: Bool
  init(notIncludeFiat: Bool) {
    self.notIncludeFiat = notIncludeFiat
  }
  
  func onAppear() {
    apiFetchUserRewards()
  }
  
  private func apiFetchUserRewards() {
    Task { @MainActor in
      do {
        status = .loading
        let entity = try await self.accountUseCase.getUserRewards().compactMap({ $0 as? APIUserRewards })
        var model: UserRewardsModel
        if notIncludeFiat {
          let rewards = entity.filter({ ($0.name ?? "").contains("USD") == false })
          model = UserRewardsModel(rewards: rewards.filter({ ($0.specialPromo ?? false) == false }),
                                   pecialrewards: rewards.filter({ ($0.specialPromo ?? false) == true }))
        } else {
          model = UserRewardsModel(rewards: entity.filter({ ($0.specialPromo ?? false) == false }),
                                   pecialrewards: entity.filter({ ($0.specialPromo ?? false) == true }))
        }
        status = .success([model])
      } catch {
        status = .failure(error.userFriendlyMessage)
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func retryTapped() {
    apiFetchUserRewards()
  }
  
  func getUrl(for link: String) -> URL? {
    switch link {
    case termsLink:
      return URL(string: LFUtilities.termsURL)
    default:
      return nil
    }
  }
}

extension APIUserRewards {
  var title: String {
    switch LFUtilities.target {
    case .CauseCard, .PrideCard: return L10N.Common.Account.Reward.Item.title
    default: return name ?? ""
    }
  }
}
