import Foundation

@MainActor
class SelectRewardsViewModel: ObservableObject {
  @Published var selected: Option?
  @Published var isLoading = false
  @Published var navigation: Navigation?
  @Published var showError = false

  var isContinueEnabled: Bool {
    selected != nil
  }

  func selection(_ option: Option) -> UserRewardRowView.Selection {
    selected == option ? .selected : .unselected
  }

  func optionSelected(_ option: Option) {
    selected = option
  }

  func continueTapped() {
//    guard let selected = selected else { return }
//    isLoading = true
//    Task {
//      do {
//        let _: EmptyResponse = try await networkService.handle(request: Endpoints.updateUser(param: ["userRewardType": selected.userRewardType.rawValue]))
//        switch selected {
//        case .cashback:
//          //analyticsService.track(event: Event(name: .selectedCashbackReward))
//          navigation = .personalInformation
//        case .donation:
//          //analyticsService.track(event: Event(name: .selectedDonationReward))
//          donationNavigation()
//        }
//      } catch {
//        log.error(error, "Failed to select reward")
//        showError = true
//      }
//      isLoading = false
//    }
  }

  func donationNavigation() {
    
  }

  private func fetchCauses() {

  }
}

  // MARK: - Types

extension SelectRewardsViewModel {
  enum Option: String {
    case cashback
    case donation

    var userRewardType: UserRewardType {
      switch self {
      case .cashback: return .cashback
      case .donation: return .donation
      }
    }
  }

  enum Navigation {
    case personalInformation
    case causeFilter
  }
}

