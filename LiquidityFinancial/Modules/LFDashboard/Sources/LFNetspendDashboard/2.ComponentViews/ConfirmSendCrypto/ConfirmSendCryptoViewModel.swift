import Foundation
import Combine
import Factory
import Services
import ZerohashData
import LFLocalizable
import ZerohashDomain
import LFUtilities
import AccountService
import BiometricsManager
import GeneralFeature

class ConfirmSendCryptoViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.cryptoAccountService) var cryptoAccountService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  var transaction: TransactionModel = .default
  let amount: Double
  let address: String
  let nickname: String
  let assetModel: AssetModel
  let feeLockedResponse: APILockedNetworkFeeResponse?
  
  var fee: Double? {
    feeLockedResponse?.fee
  }
  
  private var cancellables: Set<AnyCancellable> = []

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
  
  func callBioMetric() {
    biometricsManager.performDeviceAuthentication()
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        switch completion {
        case .finished:
          log.debug("Device authentication check completed.")
        case .failure(let error):
          self.toastMessage = error.userFriendlyMessage
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        if result {
          self.callTransferAPI()
        }
      })
      .store(in: &cancellables)
  }
  
  private func callTransferAPI() {
    if let quoteId = feeLockedResponse?.quoteId {
      executeQuote(id: quoteId)
    } else {
      sendCrypto()
    }
  }
  
  func confirmButtonClicked() {
    analyticsService.track(event: AnalyticsEvent(name: .tapsSendCrypto))
    callBioMetric()
  }
  
  func executeQuote(id: String) {
    let accountId = assetModel.id
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let transactionEntity = try await self.zerohashRepository.execute(accountId: accountId, quoteId: id)
        let account = try await cryptoAccountService.getAccountDetail(id: accountId)
        self.accountDataManager.addOrUpdateAccount(account)
        transaction = TransactionModel(from: transactionEntity)
        self.navigation = .transactionDetail(transaction.id)
      } catch {
        self.toastMessage = error.userFriendlyMessage
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
        let account = try await cryptoAccountService.getAccountDetail(id: id)
        self.accountDataManager.addOrUpdateAccount(account)
        transaction = TransactionModel(from: transactionEntity)
        self.navigation = .transactionDetail(transaction.id)
      } catch {
        self.toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
extension ConfirmSendCryptoViewModel {
  var cryptoTransactions: [TransactionInformation] {
    var transactionInfors = [
      TransactionInformation(
        title: LFLocalizable.TransactionDetail.OrderType.title,
        value: LFLocalizable.ConfirmSendCryptoView.Send.title.uppercased()
      )
    ]
    if transaction.currentBalance != nil {
      transactionInfors.append(
        TransactionInformation(
          title: LFLocalizable.TransactionDetail.Balance.title,
          value: LFUtilities.cryptoCurrency.uppercased(),
          markValue: transaction.currentBalance?.formattedAmount(
            minFractionDigits: Constants.FractionDigitsLimit.crypto.minFractionDigits
          )
        )
      )
    }
    if !nickname.isEmpty {
      transactionInfors.append(
        TransactionInformation(
          title: LFLocalizable.TransactionDetail.Nickname.title,
          value: nickname
        )
      )
    }
    transactionInfors.append(
      TransactionInformation(
        title: LFLocalizable.TransactionDetail.WalletAddress.title,
        value: address
      )
    )
    return transactionInfors
  }
}

// MARK: - Types
extension ConfirmSendCryptoViewModel {
  enum Navigation {
    case transactionDetail(String)
  }
}
