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
  
  let disclosureString = LFLocalizable.TransactionDetail.RewardDisclosure.description
  let termsLink = LFLocalizable.TransactionDetail.RewardDisclosure.Links.terms
  
  lazy var accountUseCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  func onAppear() {
    apiFetchUserRewards()
  }
  
  private func apiFetchUserRewards() {
    Task { @MainActor in
      do {
        status = .loading
        let entity = try await self.accountUseCase.getUserRewards().compactMap({ $0 as? APIUserRewards })
        let model = UserRewardsModel(rewards: entity.filter({ ($0.specialPromo ?? false) == false }),
                                     pecialrewards: entity.filter({ ($0.specialPromo ?? false) == true }))
        status = .success([model])
      } catch {
        status = .failure(error.localizedDescription)
        log.error(error.localizedDescription)
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
    case .CauseCard, .PrideCard: return LFLocalizable.Account.Reward.Item.title
    default: return name ?? ""
    }
  }
}
