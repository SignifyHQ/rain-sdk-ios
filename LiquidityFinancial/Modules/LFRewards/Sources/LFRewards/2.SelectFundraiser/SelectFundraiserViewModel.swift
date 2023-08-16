import Foundation

@MainActor
class SelectFundraiserViewModel: ObservableObject {
  let showSkipButton: Bool
  var fundraisers: [FundraiserModel] = []
  
  @Published var pagingState: PagingState = .loaded
  @Published var selectingFundraiser: FundraiserModel?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var showErrorAlert = false
  
  init(fundraisers: [FundraiserModel], showSkipButton: Bool) {
    self.fundraisers = fundraisers
    self.showSkipButton = showSkipButton
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
