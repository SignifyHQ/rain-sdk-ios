import SwiftUI

@MainActor
public class FundCardViewModel: ObservableObject {
  @Published var navigation: Navigation?
  @Published var isDisableView: Bool = false
  let kind: MoveMoneyAccountViewModel.Kind
  var achInformation: ACHModel = .default

  init(kind: MoveMoneyAccountViewModel.Kind) {
    self.kind = kind
  }
}

// MARK: UI Helpers
extension FundCardViewModel {
  func navigateAddBankDebit() {
    navigation = .addBankDebit
  }
  
  func navigateAddExternalBank() {
    navigation = .addExternalBank
  }
}

// MARK: - Types
public extension FundCardViewModel {
  enum Navigation {
    case addBankDebit
    case addExternalBank
  }
}
