import SwiftUI
import LFBaseBank
import NetSpendData
import Combine

@MainActor
public class FundCardViewModel: ObservableObject {
  @Published var navigation: Navigation?
  @Published var isDisableView: Bool = false
  let kind: MoveMoneyAccountViewModel.Kind
  var achInformation: ACHModel = .default
  
  private(set) var addFundsViewModel = AddFundsViewModel()
  private var cancellable: Set<AnyCancellable> = []

  init(kind: MoveMoneyAccountViewModel.Kind) {
    self.kind = kind
  }
}

// MARK: Handle agreement
extension FundCardViewModel {
  
  func openFundingAgreement(data: APIAgreementData?) {
    if data == nil {
      navigation = nil
    } else {
      navigation = .agreement(data)
    }
  }
  
  func handleFundingAcceptAgreement(isAccept: Bool) {
    if isAccept {
      addFundsViewModel.goNextNavigation()
    } else {
      addFundsViewModel.stopAction()
    }
  }
}

// MARK: - Types
public extension FundCardViewModel {
  enum Navigation {
    case agreement(APIAgreementData?)
  }
}
