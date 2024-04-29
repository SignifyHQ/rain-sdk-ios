import Foundation
import Combine
import Factory
import Services
import PortalDomain
import ZerohashDomain
import LFLocalizable
import LFUtilities
import AccountService
import BiometricsManager
import GeneralFeature

class ConfirmSendCryptoViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  var transaction: TransactionModel = .default
  let amount: Double
  let address: String
  let nickname: String
  let assetModel: AssetModel
  let feeLockedResponse: APILockedNetworkFeeResponse
  
  lazy var sendEthUseCase: SendEthUseCaseProtocol = {
    SendEthUseCase(repository: portalRepository)
  }()
  
  var fee: Double {
    feeLockedResponse.fee
  }
  
  private var cancellables: Set<AnyCancellable> = []

  init(
    assetModel: AssetModel,
    amount: Double,
    address: String,
    nickname: String,
    feeLockedResponse: APILockedNetworkFeeResponse
  ) {
    self.assetModel = assetModel
    self.amount = amount
    self.address = address
    self.nickname = nickname
    self.feeLockedResponse = feeLockedResponse
  }
  
  var amountInput: String {
    amount.formattedAmount(minFractionDigits: 2, maxFractionDigits: 18)
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
          self.executeSend()
        }
      })
      .store(in: &cancellables)
  }
  
  func confirmButtonClicked() {
    analyticsService.track(event: AnalyticsEvent(name: .tapsSendCrypto))
    callBioMetric()
  }
  
  func executeSend() {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        try await sendEthUseCase.executeSend(to: address, amount: amount)
        // TODO(Volo): Refactor transaction detail for Portal Send
        self.navigation = .transactionDetail("id")
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
        title: L10N.Common.TransactionDetail.OrderType.title,
        value: L10N.Common.ConfirmSendCryptoView.Send.title.uppercased()
      )
    ]
    if transaction.currentBalance != nil {
      transactionInfors.append(
        TransactionInformation(
          title: L10N.Common.TransactionDetail.Balance.title,
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
          title: L10N.Common.TransactionDetail.Nickname.title,
          value: nickname
        )
      )
    }
    transactionInfors.append(
      TransactionInformation(
        title: L10N.Common.TransactionDetail.WalletAddress.title,
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
