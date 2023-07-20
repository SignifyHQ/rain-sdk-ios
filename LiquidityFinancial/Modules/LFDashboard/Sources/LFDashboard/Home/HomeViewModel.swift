import Foundation

@MainActor
public final class HomeViewModel: ObservableObject {
  @Published var tabSelected: TabOption = .cash
  @Published var isShowGearButton: Bool = false
  
  public init() {
  }
}

// MARK: - View Helpers
extension HomeViewModel {
  func onSelectedTab(tab: TabOption) {
    tabSelected = tab
  }
  
  func onClickedProfileButton() {
  }
  
  func onClickedGearButton() {
  }
}
