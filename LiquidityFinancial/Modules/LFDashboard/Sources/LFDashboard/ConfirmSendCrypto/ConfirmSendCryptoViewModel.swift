import Foundation
import BaseDashboard
import Factory
import LFServices
import ZerohashData
import LFTransaction
import LFLocalizable

class ConfirmSendCryptoViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  let amount: Double
  let address: String
  let nickname: String
  let assetModel: AssetModel

  init(assetModel: AssetModel, amount: Double, address: String, nickname: String) {
    self.assetModel = assetModel
    self.amount = amount
    self.address = address
    self.nickname = nickname
  }
  
  var amountInput: String {
    amount.roundTo3fStr()
  }
  
  func confirmButtonClicked() {
    let id = assetModel.id
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let transactionEntity = try await self.zerohashRepository.sendCrypto(
          accountId: id,
          destinationAddress: self.address,
          amount: self.amount
        )
        let account = try await accountRepository.getAccountDetail(id: id)
        self.accountDataManager.addOrUpdateAccount(account)
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
        title: LFLocalizable.TransactionDetail.OrderType.title,
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
