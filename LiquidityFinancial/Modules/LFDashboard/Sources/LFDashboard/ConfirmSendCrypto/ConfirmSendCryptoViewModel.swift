import Foundation
import Factory
import LFServices
import ZerohashData
import LFTransaction

class ConfirmSendCryptoViewModel: ObservableObject {
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  let accountId: String
  let amount: Double
  let address: String
  let nickname: String = ""

  init(accountId: String, amount: Double, address: String) {
    self.accountId = accountId
    self.amount = amount
    self.address = address
  }
  
  var amountInput: String {
    amount.roundTo3fStr()
  }
  
  func confirmButtonClicked() {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let transactionEntity = try await zerohashRepository.sendCrypto(accountId: self.accountId, destinationAddress: self.address, amount: self.amount)
        let transaction = TransactionModel(from: transactionEntity)
        self.navigation = .detail(transaction: transaction)
      } catch {
        self.toastMessage = error.localizedDescription
      }
    }
  }
}

extension ConfirmSendCryptoViewModel {
  enum Navigation {
    case detail(transaction: TransactionModel)
  }
}
