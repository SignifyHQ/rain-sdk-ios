import Foundation

@MainActor
final class TransferDebitSuggestionViewModel: ObservableObject {
  @Published var showDebitView = false
  private let data: Data
  
  init(data: Data) {
    self.data = data
  }
  
  var shouldShow: Bool {
    // TODO: Will be implemented later
    false
  }
  
  func connectTapped() {
    showDebitView = true
  }
}

// MARK: - Data
extension TransferDebitSuggestionViewModel {
  struct Data {
    let isPending: Bool
    let isAchDeposit: Bool
    
    //    static func build(from transfer: Transfer) -> Self {
    //      let isPending = transfer.status?.isPending ?? true
    //      let isAch = transfer.transferType == .ach
    //      let isDeposit = transfer.txnType == .credit
    //      return .init(isPending: isPending, isAchDeposit: isAch && isDeposit)
    //    }
    
    //    static func build(from transaction: TransactionModel) -> Self {
    //      let isPending = transaction.status?.isPending ?? true
    //      let isAch = transaction.transferType == .ach
    //      let isDeposit = transaction.txnType == .credit
    //      return .init(isPending: isPending, isAchDeposit: isAch && isDeposit)
    //    }
  }
}
