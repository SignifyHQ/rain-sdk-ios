import Foundation
import Combine
import Factory
import Services
import PortalDomain
import LFLocalizable
import LFUtilities
import AccountService
import BiometricsManager
import GeneralFeature
import AccountData
import AccountDomain
import RainData
import RainDomain
import LFStyleGuide

@MainActor
final class WithdrawalConfirmationViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.rainRewardRepository) var rainRewardRepository
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.portalStorage) var portalStorage

  @Published var showIndicator: Bool = false
  @Published var toastData: ToastData?
  @Published var navigation: Navigation?
  
  var transaction: TransactionModel = .default
  
  let kind: Kind
  let amount: Double
  let blockchainFee: Double?
  let address: String
  let nickname: String
  let assetModel: AssetModel
  
  private lazy var sendEthUseCase: SendEthUseCaseProtocol = {
    SendEthUseCase(repository: portalRepository)
  }()
  
  private lazy var createPendingTransactionUseCase: CreatePendingTransactionUseCaseProtocol = {
    CreatePendingTransactionUseCase(repository: accountRepository)
  }()
  
  private lazy var getCurrentChainIdUseCase: GetCurrentChainIdUseCaseProtocol = {
    GetCurrentChainIdUseCase(repository: portalRepository)
  }()
  
  private lazy var withdrawAsssetUseCase: WithdrawAssetUseCaseProtocol = {
    WithdrawAssetUseCase(repository: portalRepository)
  }()
  
  private lazy var requestRewardWithdrawalUseCase: RainRequestRewardWithdrawalUseCaseProtocol = {
    RainRequestRewardWithdrawalUseCase(repository: rainRewardRepository)
  }()
  
  var fee: Double {
    blockchainFee ?? 0
  }
  
  var amountInput: String {
    amount.formattedAmount(minFractionDigits: 2, maxFractionDigits: 18)
  }
  
  var transactionHash: String?
  
  var isNewAddress: Bool {
    switch kind {
    case let .withdrawalCollateral(_, _, shouldSaveAddress):
      shouldSaveAddress && nickname.isEmpty
    }
  }
  
  var cryptoTransactions: [TransactionInformation] {
    var transactionInfors = [
      TransactionInformation(
        title: L10N.Common.TransactionDetails.Info.orderType,
        value: L10N.Common.TransactionDetails.Info.OrderType.withdrawal
      )
    ]
    
    if !nickname.isEmpty {
      transactionInfors.append(
        TransactionInformation(
          title: L10N.Common.TransactionDetails.Info.nickname,
          value: nickname
        )
      )
    }
    
    transactionInfors.append(
      TransactionInformation(
        title: L10N.Common.TransactionDetails.Info.address,
        value: address
      )
    )
    
    transactionInfors.append(
      TransactionInformation(
        title: L10N.Common.TransactionDetails.Info.fee,
        value: fee.formattedAmount(minFractionDigits: 2, maxFractionDigits: 18)
      )
    )

    if let transactionHash {
      transactionInfors.append(
        TransactionInformation(
          title: L10N.Common.TransactionDetails.Info.hash,
          value: transactionHash
        )
      )
    }
    
    return transactionInfors
  }
  
  private var cancellables: Set<AnyCancellable> = []

  init(
    kind: Kind,
    assetModel: AssetModel,
    amount: Double,
    blockchainFee: Double? = nil,
    address: String,
    nickname: String
  ) {
    self.kind = kind
    self.assetModel = assetModel
    self.amount = amount
    self.address = address
    self.nickname = nickname
    self.blockchainFee = blockchainFee
  }
}

// MARK: - Handling Interactions
extension WithdrawalConfirmationViewModel {
  func onConfirmButtonTap() {
    analyticsService.track(event: AnalyticsEvent(name: .tapsSendCrypto))
    transferMoney()
  }
  
  private func transferMoney() {
    switch kind {
    case let .withdrawalCollateral(addresses, signature, _):
      withdrawCollateral(addresses: addresses, signature: signature)
    }
  }
}

// MARK: - APIs Handler
extension WithdrawalConfirmationViewModel {
  func withdrawCollateral(addresses: PortalService.WithdrawAssetAddresses, signature: PortalService.WithdrawAssetSignature) {
    Task {
      defer { showIndicator = false }
      showIndicator = true
      
      do {
        let transactionHash = try await withdrawAsssetUseCase.execute(
          addresses: addresses,
          amount: amount,
          signature: signature
        )
        self.transactionHash = transactionHash
        navigateToTransactionDetail(type: .cryptoWithdraw, hash: transactionHash)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
}

// MARK: Handle UI/UX
extension WithdrawalConfirmationViewModel {
  func navigateToTransactionDetail(type: TransactionType, hash: String) {
    let transaction = TransactionModel(
      id: Constants.Default.localTransactionID.rawValue,
      accountId: .empty,
      title: L10N.Common.TransactionDetails.Header.Withdrawal.title(assetModel.type?.symbol ?? .empty),
      currency: assetModel.type?.symbol,
      amount: amount,
      fee: fee,
      type: type,
      status: .pending, // All crypto transfer transactions have pending status at the time of execution
      createdAt: Date().ISO8601Format(),
      updateAt: .empty,
      transactionHash: hash
    )
    navigation = .transactionDetail(transaction)
  }
  
  func handlePortalError(error: Error) {
    let portalError = LFPortalError.handlePortalError(error: error)
    var errorMessage: String
    switch portalError {
    case .customError(let message):
      errorMessage = message
    default:
      errorMessage = error.userFriendlyMessage
    }
    toastData = ToastData(type: .error, title: errorMessage)
    log.error(errorMessage)
  }
}

// MARK: - Private Enums
extension WithdrawalConfirmationViewModel {
  enum Navigation {
    case transactionDetail(TransactionModel)
  }
  
  enum Kind {
    case withdrawalCollateral(addresses: PortalService.WithdrawAssetAddresses, signature: PortalService.WithdrawAssetSignature, shouldSaveAddress: Bool)
  }
}
