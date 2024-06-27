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
import AccountData
import AccountDomain
import RainData
import RainDomain

@MainActor
final class ConfirmTransferMoneyViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.rainRewardRepository) var rainRewardRepository
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.portalStorage) var portalStorage

  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  var transaction: TransactionModel = .default
  
  let kind: Kind
  let amount: Double
  let address: String
  let nickname: String
  let assetModel: AssetModel
  let feeLockedResponse: APILockedNetworkFeeResponse?
  
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
    feeLockedResponse?.fee ?? 0
  }
  
  var amountInput: String {
    amount.formattedAmount(minFractionDigits: 2, maxFractionDigits: 18)
  }
  
  var isNewAddress: Bool {
    switch kind {
    case .sendCrypto:
      nickname.isEmpty
    case .depositCollateral:
      false
    case let .withdrawalCollateral(_, _, shouldSaveAddress):
      shouldSaveAddress && nickname.isEmpty
    case .withdrawalReward(let shouldSaveAddress):
      shouldSaveAddress && nickname.isEmpty
    }
  }
  
  private var cancellables: Set<AnyCancellable> = []

  init(
    kind: Kind,
    assetModel: AssetModel,
    amount: Double,
    address: String,
    nickname: String,
    feeLockedResponse: APILockedNetworkFeeResponse? = nil
  ) {
    self.kind = kind
    self.assetModel = assetModel
    self.amount = amount
    self.address = address
    self.nickname = nickname
    self.feeLockedResponse = feeLockedResponse
  }
}

// MARK: - View Helpers
extension ConfirmTransferMoneyViewModel {
  func confirmButtonClicked() {
    analyticsService.track(event: AnalyticsEvent(name: .tapsSendCrypto))
    callBioMetric()
  }
  
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
    transactionInfors.append(
      TransactionInformation(
        title: L10N.Common.TransactionDetail.Fee.title,
        value: fee.formattedCryptoAmount()
      )
    )
    return transactionInfors
  }
}

// MARK: - Private Function
private extension ConfirmTransferMoneyViewModel {
  func transferMoney() {
    switch kind {
    case .sendCrypto:
      sendCrypto()
    case .depositCollateral:
      depositCollateral()
    case let .withdrawalCollateral(addresses, signature, _):
      withdrawCollateral(addresses: addresses, signature: signature)
    case .withdrawalReward:
      requestRewardWithdrawal()
    }
  }
  
  func sendCrypto() {
    Task {
      defer { showIndicator = false }
      showIndicator = true
      
      do {
        let chainID = getCurrentChainIdUseCase.execute()
        
        let txHash = try await sendEthUseCase.execute(
          to: address,
          contractAddress: assetModel.id.nilIfEmpty,
          amount: amount
        )
        _ = try await createPendingTransactionUseCase.execute(
          body: APIPendingTransactionParameters(
            transactionHash: txHash,
            chainId: chainID,
            fromAddress: assetModel.externalAccountId ?? "",
            toAddress: address,
            amount: amount,
            currency: assetModel.type?.title ?? "",
            contractAddress: assetModel.id.nilIfEmpty,
            decimal: assetModel.conversionFactor,
            transactionFee: fee
          )
        )
        
        navigateToTransactionDetail(type: .cryptoWithdraw)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func depositCollateral() {
    Task {
      defer { showIndicator = false }
      showIndicator = true
      
      do {
        let chainID = getCurrentChainIdUseCase.execute()
        
        guard let collateralContract = accountDataManager.collateralContract else {
          toastMessage = L10N.Common.MoveCryptoInput.NoCollateralContract.errorMessage
          return
        }
        
        let tokenAddress = collateralContract.tokensEntity.filter { $0.symbol == AssetType.usdc.title }
        let usdcToken = tokenAddress.first {
          portalStorage.checkTokenSupport(with: $0.address.lowercased())
        }
        guard usdcToken != nil else {
          toastMessage = L10N.Common.MoveCryptoInput.UsdcUnsupported.errorMessage
          return
        }
        
        let txHash = try await sendEthUseCase.execute(
          to: collateralContract.address,
          contractAddress: assetModel.id,
          amount: amount
        )
        _ = try await createPendingTransactionUseCase.execute(
          body: APIPendingTransactionParameters(
            transactionHash: txHash,
            chainId: chainID,
            fromAddress: assetModel.externalAccountId ?? "",
            toAddress: collateralContract.address,
            amount: amount,
            currency: assetModel.type?.title ?? "",
            contractAddress: assetModel.id.nilIfEmpty,
            decimal: assetModel.conversionFactor,
            transactionFee: fee
          )
        )
        
        navigateToTransactionDetail(type: .cryptoWithdraw)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func requestRewardWithdrawal() {
    Task {
      do {
        let parameters = APIRainRewardWithdrawalParameters(
          amount: amount,
          currency: assetModel.type?.title ?? "",
          recipientAddress: address
        )
        _ = try await requestRewardWithdrawalUseCase.execute(parameters: parameters)
        navigateToTransactionDetail(type: .cryptoWithdraw)
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
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
          self.transferMoney()
        }
      })
      .store(in: &cancellables)
  }
  
  func withdrawCollateral(addresses: PortalService.WithdrawAssetAddresses, signature: PortalService.WithdrawAssetSignature) {
    Task {
      defer { showIndicator = false }
      showIndicator = true
      
      do {
        _ = try await withdrawAsssetUseCase.execute(
          addresses: addresses,
          amount: amount,
          signature: signature
        )
        navigateToTransactionDetail(type: .cryptoWithdraw)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func navigateToTransactionDetail(type: TransactionType) {
    let transaction = TransactionModel(
      id: Constants.Default.localTransactionID.rawValue,
      accountId: .empty,
      title: L10N.Common.TransactionDetail.CryptoTransfer.title(assetModel.type?.title ?? .empty),
      currency: assetModel.type?.title,
      amount: amount,
      fee: fee,
      type: type,
      status: .pending, // All crypto transfer transactions have pending status at the time of execution
      createdAt: .empty,
      updateAt: .empty
    )
    navigation = .transactionDetail(transaction)
  }
  
  func generateWithdrawAssetAddresses(
    collateralContract: RainCollateralContractEntity,
    controllerAddress: String,
    recipientAddress: String
  ) -> PortalService.WithdrawAssetAddresses? {
    // Check if collateral supports usdc token
    let tokenAddress = collateralContract.tokensEntity.filter { $0.symbol == AssetType.usdc.title }
    let usdcToken = tokenAddress.first {
      portalStorage.checkTokenSupport(with: $0.address.lowercased())
    }
    guard let usdcToken else {
      toastMessage = L10N.Common.MoveCryptoInput.UsdcUnsupported.errorMessage
      return nil
    }
    
    return PortalService.WithdrawAssetAddresses(
      contractAddress: controllerAddress,
      proxyAddress: collateralContract.address,
      recipientAddress: recipientAddress,
      tokenAddress: usdcToken.address
    )
  }
  
  func handlePortalError(error: Error) {
    let portalError = LFPortalError.handlePortalError(error: error)
    switch portalError {
    case .customError(let message):
      toastMessage = message
    default:
      toastMessage = portalError.localizedDescription
    }
    
    log.error(toastMessage ?? portalError.localizedDescription)
  }
}

// MARK: - Types
extension ConfirmTransferMoneyViewModel {
  enum Navigation {
    case transactionDetail(TransactionModel)
  }
  
  enum Kind {
    case sendCrypto
    case depositCollateral
    case withdrawalCollateral(addresses: PortalService.WithdrawAssetAddresses, signature: PortalService.WithdrawAssetSignature, shouldSaveAddress: Bool)
    case withdrawalReward(shouldSaveAddress: Bool)
  }
}
