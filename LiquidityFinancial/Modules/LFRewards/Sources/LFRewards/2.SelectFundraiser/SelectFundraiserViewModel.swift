import Foundation
import Factory

@MainActor
public class SelectFundraiserViewModel: ObservableObject {
  let showSkipButton: Bool
  var fundraisers: [FundraiserModel] = []
  
  @Published var pagingState: PagingState = .loaded
  @Published var selectingFundraiser: FundraiserModel?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var showErrorAlert = false
  
  @LazyInjected(\.rewardFlowCoordinator) var rewardFlowCoordinator
  
  var categoryName: String {
    causeModel.name
  }
  
  let causeModel: CauseModel
  
  public init(causeModel: CauseModel, fundraisers: [FundraiserModel], showSkipButton: Bool) {
    self.causeModel = causeModel
    self.fundraisers = fundraisers
    self.showSkipButton = showSkipButton
  }
  
  func skipAndDumpToInformation() {
    rewardFlowCoordinator.set(route: .information)
  }
}

  // MARK: - Types

extension SelectFundraiserViewModel {
  enum Navigation {
    case agreement
  }
  
  enum Popup {
    case success(FundraiserModel)
  }
}
