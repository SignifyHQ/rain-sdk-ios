import Foundation
import BaseDashboard
import Factory
import LFServices
import ZerohashData
import LFTransaction
import LFLocalizable
import ZerohashDomain

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
  let feeLockedResponse: APILockedNetworkFeeResponse?
  
  var fee: Double? {
    feeLockedResponse?.fee
  }

  init(assetModel: AssetModel, amount: Double, address: String, nickname: String, feeLockedResponse: APILockedNetworkFeeResponse?) {
    self.assetModel = assetModel
    self.amount = amount
    self.address = address
    self.nickname = nickname
    self.feeLockedResponse = feeLockedResponse
  }
  
  var amountInput: String {
    amount.roundTo3fStr()
  }
  
  func confirmButtonClicked() {
    if let quoteId = feeLockedResponse?.quoteId {
      executeQuote(id: quoteId)
    } else {
      sendCrypto()
    }
  }
  
  func executeQuote(id: String) {
    let accountId = assetModel.id
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let transactionEntity = try await self.zerohashRepository.execute(accountId: accountId, quoteId: id)
        let account = try await accountRepository.getAccountDetail(id: accountId)
        self.accountDataManager.addOrUpdateAccount(account)
        let transaction = TransactionModel(from: transactionEntity)
        self.navigation = .transactionDetail(transaction.id)
      } catch {
        self.toastMessage = error.localizedDescription
      }
    }
  }
  
  func sendCrypto() {
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
