import Foundation
import Factory
import LFServices
import ZerohashData
import LFTransaction
import LFLocalizable

class ConfirmSendCryptoViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  let amount: Double
  let address: String
  let nickname: String

  init(amount: Double, address: String, nickname: String) {
    self.amount = amount
    self.address = address
    self.nickname = nickname
  }
  
  var amountInput: String {
    amount.roundTo3fStr()
  }
  
  func confirmButtonClicked() {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        guard let accountID = self.accountDataManager.cryptoAccountID else {
          return
        }
        let transactionEntity = try await self.zerohashRepository.sendCrypto(
          accountId: accountID,
          destinationAddress: self.address,
          amount: self.amount
        )
        let transaction = TransactionModel(from: transactionEntity)
        self.navigation = .transactionDetail(transaction.id)
      } catch {
        self.toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - View Helpers
extension ConfirmSendCryptoViewModel {
  var cryptoTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: LFLocalizable.TransactionDetail.TransactionType.title,
        value: LFLocalizable.ConfirmSendCryptoView.Send.title
      )
    ]
  }
}

// MARK: - Types
extension ConfirmSendCryptoViewModel {
  enum Navigation {
    case transactionDetail(String)
  }
}
