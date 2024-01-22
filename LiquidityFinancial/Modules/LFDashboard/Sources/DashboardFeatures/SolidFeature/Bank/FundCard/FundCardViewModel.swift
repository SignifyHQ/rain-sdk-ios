import SwiftUI
import Combine

@MainActor
public class FundCardViewModel: ObservableObject {
  @Published var isDisableView: Bool = false
  let kind: MoveMoneyAccountViewModel.Kind
  var achInformation: ACHModel = .default
  
  private(set) var addFundsViewModel = AddFundsViewModel()
  private var cancellable: Set<AnyCancellable> = []

  init(kind: MoveMoneyAccountViewModel.Kind) {
    self.kind = kind
  }
}
