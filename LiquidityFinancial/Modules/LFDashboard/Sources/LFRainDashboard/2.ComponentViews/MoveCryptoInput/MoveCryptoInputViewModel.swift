import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Factory
import AccountDomain
import Combine
import AccountService
import GeneralFeature
import PortalData
import PortalDomain
import RainData
import RainDomain
import Services

@MainActor
final class MoveCryptoInputViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.rainRepository) var rainRepository
  @LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  @LazyInjected(\.portalService) var portalService
  
  @Published var assetModel: AssetModel {
    didSet {
      generateGridValues()
    }
  }
  
  @Published var assetModelList: [AssetModel] = []
  
  @Published var navigation: Navigation?
  @Published var blockPopup: BlockPopup?
  
  @Published var isFetchingData = false
  @Published var isLoading = false
  @Published var isPerformingAction = false
  @Published var shouldRetryWithdrawal = false
  
  @Published var amountInput = "0"
  @Published var numberOfShakes = 0
  
  @Published var isShowingTokenSelection: Bool = false
  @Published var inlineError: String?
  @Published var toastMessage: String?
  
  @Published var selectedValue: GridValue? {
    didSet {
      Haptic.selection.generate()
    }
  }
  
  private lazy var sendEthUseCase: SendEthUseCaseProtocol = {
    SendEthUseCase(repository: portalRepository)
  }()
  
  private lazy var estimateGasUseCase: EstimateGasUseCaseProtocol = {
    EstimateGasUseCase(repository: portalRepository)
  }()
  
  private lazy var getWithdrawalSignatureUseCase: GetWithdrawalSignatureUseCaseProtocol = {
    GetWithdrawalSignatureUseCase(repository: rainRepository)
  }()
  
  private var subscribers: Set<AnyCancellable> = []
  
  let type: Kind
  var gridValues: [GridValue] = []
  
  init(
    type: Kind,
    assetModel: AssetModel
  ) {
    self.type = type
    self.assetModel = assetModel
    
    observeAssets()
    generateGridValues()
  }
}

// MARK: - API Handle
private extension MoveCryptoInputViewModel {
  func generateRewardWithdrawalQuote(
    shouldSaveAddress: Bool
  ) {
    let viewModel = ConfirmTransferMoneyViewModel(
      kind: .withdrawalReward(
        shouldSaveAddress: shouldSaveAddress
      ),
      assetModel: assetModel,
      amount: amount,
      address: address,
      nickname: nickname
    )
    
    navigation = .confirmTransfer(viewModel: viewModel)
  }
  
  func generateWithdrawCollateralQuote(
    shouldSaveAddress: Bool
  ) {
    Task {
      defer { isPerformingAction = false }
      isPerformingAction = true
      
      do {
        guard let collateralContract = accountDataManager.collateralContract,
        let controllerAddress = collateralContract.controllerAddress
        else {
          toastMessage = L10N.Common.MoveCryptoInput.NoCollateralContract.errorMessage
          return
        }
        
        guard let signature = try await getWithdrawalSignature(chainId: collateralContract.chainId) else {
          return
        }
        
        guard let withdrawAddresses = generateWithdrawAssetAddresses(
          collateralContract: collateralContract,
          controllerAddress: controllerAddress,
          recipientAddress: address
        ) else {
          return
        }
        
        let txFee = try await estimateGasUseCase.estimateWithdrawalFee(
          addresses: withdrawAddresses,
          amount: amount,
          signature: signature
        )
        
        let viewModel = ConfirmTransferMoneyViewModel(
          kind: .withdrawalCollateral(
            addresses: withdrawAddresses,
            signature:signature,
            shouldSaveAddress: shouldSaveAddress
          ),
          assetModel: assetModel,
          amount: amount,
          blockchainFee: txFee,
          address: address,
          nickname: nickname
        )
        
        navigation = .confirmTransfer(viewModel: viewModel)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func generateWithdrawAssetAddresses(
    collateralContract: RainCollateralContractEntity,
    controllerAddress: String,
    recipientAddress: String
  ) -> PortalService.WithdrawAssetAddresses? {
    // Check if collateral supports token
    let tokenAddress = collateralContract.tokensEntity
      .filter {
        $0.symbol == assetModel.type?.title
      }
    
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
  
  func fetchTransferMoneyQuote(
    kind: ConfirmTransferMoneyViewModel.Kind
  ) {
    Task {
      defer { isPerformingAction = false }
      isPerformingAction = true
      
      do {
        let txFee = try await estimateGasUseCase.estimateTransferFee(
          to: address,
          contractAddress: assetModel.id.nilIfEmpty,
          amount: amount
        )
        
        let viewModel = ConfirmTransferMoneyViewModel(
          kind: kind,
          assetModel: assetModel,
          amount: amount,
          blockchainFee: txFee, 
          address: address,
          nickname: nickname
        )
        
        navigation = .confirmTransfer(viewModel: viewModel)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func getWithdrawalSignature(
    chainId: Int
  ) async throws -> PortalService.WithdrawAssetSignature? {
    let amount = amount * pow(10, Double(assetModel.conversionFactor))
    let parameters = APIRainWithdrawalSignatureParameters(
      chainId: chainId,
      token: assetModel.id,
      amount: String(amount),
      recipientAddress: address
    )
    
    let signature = try await getWithdrawalSignatureUseCase.execute(parameters: parameters)
    
    if let retryAfterSeconds = signature.retryAfterSeconds {
      blockPopup = .retryWithdrawalAfter(retryAfterSeconds)
      return nil
    }
    
    guard let signatureEntity = signature.signatureEntity,
          let expiresAt = signature.expiresAt
    else {
      blockPopup = .retryWithdrawalAfter(5) // Default the retryAfterSeconds is 5 seconds
      
      return nil
    }
    
    return PortalService.WithdrawAssetSignature(
      expiresAt: expiresAt,
      salt: signatureEntity.salt,
      signature: signatureEntity.data
    )
  }
}

// MARK: - Private Functions
private extension MoveCryptoInputViewModel {
  func generateGridValues(
  ) {
    let cryptoCurrency = assetModel.type?.title ?? .empty
    switch type {
    case .sellCrypto, .sendCrypto, .depositCollateral, .withdrawCollateral:
      gridValues = Constant.Sell.buildRecommend(available: assetModel.availableBalance, coin: cryptoCurrency)
    default:
      break
    }
  }
  
  private func observeAssets(
  ) {
    switch type {
    case .depositCollateral:
      observePortalAssets()
    case .withdrawCollateral:
      observeCollateralAssets()
    default:
      break
    }
  }
  
  private func observePortalAssets(
  ) {
    portalStorage
      .cryptoAssets()
      .receive(on: DispatchQueue.main)
      .map { assets in
        assets
          .compactMap {
            let assetModel = AssetModel(portalAsset: $0)
            
            // Filter out tokens of unsupported type and native tokens
            guard assetModel.type != nil && !assetModel.id.isEmpty
            else {
              return nil
            }
            
            return assetModel
          }
          .sorted {
            ($0.type?.rawValue ?? "") < ($1.type?.rawValue ?? "")
          }
      }
      .assign(to: &$assetModelList)
  }
  
  private func observeCollateralAssets(
  ) {
    accountDataManager
      .collateralContractSubject
      .compactMap { rainCollateral in
        rainCollateral?
          .tokensEntity
          .compactMap { rainToken in
            let assetModel = AssetModel(rainCollateralAsset: rainToken)
            
            // Filter out tokens of unsupported type and native tokens
            guard assetModel.type != nil && !assetModel.id.isEmpty
            else {
              return nil
            }
            
            return assetModel
          }
      }
      .assign(to: &$assetModelList)
  }
  
  func handlePortalError(
    error: Error
  ) {
    guard let portalError = error as? LFPortalError else {
      toastMessage = error.userFriendlyMessage
      log.error(error.userFriendlyMessage)
      
      return
    }
    
    switch portalError {
    case .customError(let message):
      toastMessage = message
    default:
      toastMessage = portalError.localizedDescription
    }
    
    log.error(toastMessage ?? portalError.localizedDescription)
  }
}

// MARK: - View Helpers
extension MoveCryptoInputViewModel {
  var isUSDCurrency: Bool {
    switch type {
    case .buyCrypto:
      return true
    case .sellCrypto, .sendCrypto, .depositCollateral, .withdrawCollateral, .withdrawReward:
      return false
    }
  }
  
  var isCryptoCurrency: Bool {
    switch type {
    case .buyCrypto:
      return false
    case .sellCrypto, .sendCrypto, .depositCollateral, .withdrawCollateral, .withdrawReward:
      return true
    }
  }
  
  var maxFractionDigits: Int {
    switch type {
    case .buyCrypto:
      return 2
    case .sellCrypto, .sendCrypto, .depositCollateral, .withdrawCollateral, .withdrawReward:
      return LFUtilities.cryptoFractionDigits
    }
  }
  
  var showCryptoDisclosure: Bool {
    true
  }
  
  var shouldShowTokenSelection: Bool {
    switch type {
    case .depositCollateral, .withdrawCollateral:
      true
    default:
      false
    }
  }
  
  var showEstimatedFeeDescription: Bool {
    switch type {
    case .sendCrypto, .depositCollateral:
      return true
    default:
      return false
    }
  }
  
  var title: String {
    switch type {
    case .buyCrypto:
      return L10N.Common.MoveCryptoInput.Buy.title(assetModel.type?.title ?? .empty)
    case .sellCrypto:
      return L10N.Common.MoveCryptoInput.Sell.title(assetModel.type?.title ?? .empty)
    case .sendCrypto:
      return L10N.Common.MoveCryptoInput.Send.title(assetModel.type?.title ?? .empty)
    case .withdrawCollateral:
      return L10N.Common.MoveCryptoInput.WithdrawCollateral.title
    case .withdrawReward:
      return L10N.Common.MoveCryptoInput.WithdrawReward.title
    case .depositCollateral:
      return L10N.Common.MoveCryptoInput.SendCollateral.title
    }
  }
  
  var subtitle: String? {
    let cryptoCurrency = assetModel.type?.title ?? .empty
    switch type {
    case .sellCrypto:
      let balance = assetModel.availableBalance.roundTo3f()
      
      return L10N.Common.MoveCryptoInput.SellAvailableBalance.subtitle(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3), cryptoCurrency
      )
    case .sendCrypto:
      let balance = assetModel.availableBalance.roundTo3f()
      
      return L10N.Common.MoveCryptoInput.SendAvailableBalance.subtitle(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3), cryptoCurrency
      )
    case .withdrawCollateral:
      let balance = assetModel.availableBalance.roundTo6f()
      
      return L10N.Common.MoveCryptoInput.WithdrawCollateralAvailableBalance.subtitle(
        "\(balance)".formattedAmount(minFractionDigits: 2, maxFractionDigits: 6), cryptoCurrency
      )
    case let .withdrawReward(_, _, balance, _):
      return L10N.Common.MoveCryptoInput.WithdrawReward.subtitle(
        balance.formattedAmount(minFractionDigits: 2, maxFractionDigits: 6)
      )
    case .depositCollateral:
      let balance = assetModel.availableBalance.roundTo6f()
      
      return L10N.Common.MoveCryptoInput.SendCollateralAvailableBalance.subtitle(
        "\(balance)".formattedAmount(minFractionDigits: 2, maxFractionDigits: 6), cryptoCurrency
      )
    default:
      return .empty
    }
  }
  
  var annotationString: String {
    switch type {
    case .sellCrypto:
      let balance = assetModel.availableBalance.roundTo3f()
      
      return L10N.Common.MoveCryptoInput.Sell.annotation(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
      )
    case .sendCrypto:
      let balance = assetModel.availableBalance.roundTo3f()
      
      return L10N.Common.MoveCryptoInput.Send.annotation(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3),
        assetModel.type?.title ?? .empty
      )
    case .withdrawCollateral:
      let balance = assetModel.availableBalance.roundTo3f()
      
      return L10N.Common.MoveCryptoInput.WithdrawCollateral.annotation(
        "\(balance)".formattedAmount(minFractionDigits: 2, maxFractionDigits: 6),
        assetModel.type?.title ?? .empty
      )
    case let .withdrawReward(_, _, balance, _):
      return L10N.Common.MoveCryptoInput.WithdrawReward.annotation(
        balance.formattedAmount(minFractionDigits: 2, maxFractionDigits: 6)
      )
    case .depositCollateral:
      let balance = assetModel.availableBalance.roundTo3f()
      
      return L10N.Common.MoveCryptoInput.SendCollateral.annotation(
        "\(balance)".formattedAmount(minFractionDigits: 2, maxFractionDigits: 6),
        assetModel.type?.title ?? .empty
      )
    default:
      return .empty
    }
  }
  
  var isActionAllowed: Bool {
    !(amount.isZero || inlineError.isNotNil)
  }
  
  var amount: Double {
    amountInput.removeGroupingSeparator().convertToDecimalFormat().asDouble ?? 0.0
  }
  
  var cryptoIconImage: Image? {
    assetModel.type?.filledImage
  }
  
  var address: String {
    switch type {
    case .sendCrypto(let address, _):
      return address
    case .withdrawCollateral(let address, _, _):
      return address
    case .withdrawReward(let address, _, _, _):
      return address
    case .depositCollateral:
      guard let collateralContract = accountDataManager.collateralContract else {
        toastMessage = L10N.Common.MoveCryptoInput.NoCollateralContract.errorMessage
        return .empty
      }
      return collateralContract.address
    default:
      return .empty
    }
  }
  
  var nickname: String {
    switch type {
    case let .sendCrypto(_, nickname):
      return nickname ?? .empty
    case let .withdrawCollateral(_, nickname, _):
      return nickname ?? .empty
    case let .withdrawReward(_, nickname, _, _):
      return nickname ?? .empty
    default:
      return .empty
    }
  }
  
  var transactionInformations: [TransactionInformation] {
    var transactionInfors = [
      TransactionInformation(
        title: L10N.Common.TransactionDetail.OrderType.title,
        value: L10N.Common.ConfirmSendCryptoView.Send.title.uppercased()
      )
    ]
    
    if !nickname.isEmpty {
      transactionInfors.append(
        TransactionInformation(
          title: L10N.Common.TransactionDetail.Nickname.title,
          value: nickname
        )
      )
    }
    
    if !address.isEmpty {
      transactionInfors.append(
        TransactionInformation(
          title: L10N.Common.TransactionDetail.WalletAddress.title,
          value: address
        )
      )
    }
    
    return transactionInfors
  }

  
  func continueButtonTapped() {
    Haptic.impact(.light).generate()
    switch type {
    case .buyCrypto:
      break
    case .sellCrypto:
      break
    case .sendCrypto:
      fetchTransferMoneyQuote(kind: .sendCrypto)
    case let .withdrawCollateral(_, _, shouldSaveAddress):
      generateWithdrawCollateralQuote(shouldSaveAddress: shouldSaveAddress)
    case let .withdrawReward(_, _, _, shouldSaveAddress):
      generateRewardWithdrawalQuote(shouldSaveAddress: shouldSaveAddress)
    case .depositCollateral:
      fetchTransferMoneyQuote(kind: .depositCollateral)
    }
  }
  
  // Reset amountInput and selectedValue when interacting with keyboard
  func resetSelectedValue() {
    selectedValue = nil
    
    guard let amount = amountInput.removeGroupingSeparator().asDouble,
          let selectedAmount = selectedValue?.amount
    else {
      return
    }
    amountInput = amount == selectedAmount ? Constant.initValue : amountInput
  }
  
  func onSelectedGridItem(_ gridValue: GridValue) {
    selectedValue = gridValue
    amountInput = gridValue.formattedInput
  }
  
  func validateAmountInput() {
    numberOfShakes = 0
    
    switch type {
    case .sellCrypto, .sendCrypto, .depositCollateral, .withdrawCollateral:
      inlineError = validateAmount(with: assetModel.availableBalance)
    case .withdrawReward(_, _, let balance, _):
      inlineError = validateAmount(with: balance)
    default:
      break
    }
    
    if inlineError.isNotNil {
      withAnimation(.linear(duration: 0.5)) {
        numberOfShakes = 4
      }
    }
  }
  
  func validateAmount(
    with availableBalance: Double?
  ) -> String? {
    guard let balance = availableBalance
    else {
      return nil
    }
    
    if type != .sellCrypto, amount > 0, amount < 0.0001 {
      return L10N.Common.MoveCryptoInput.MinimumCrypto.description(assetModel.type?.title ?? .empty)
    }
    
    return balance < amount ? L10N.Common.MoveCryptoInput.InsufficientFunds.description : nil
  }
  
  var isMaxAmount: Bool {
    switch type {
    case .sendCrypto, .sellCrypto:
      return amount >= assetModel.availableBalance
    default:
      return false
    }
  }
  
  func hidePopup() {
    blockPopup = nil
  }
  
  func handleAfterWaitingRetryTime() {
    hidePopup()
    shouldRetryWithdrawal = true
  }
}

// MARK: - Types
extension MoveCryptoInputViewModel {
  enum Kind: Equatable, Identifiable {
    case buyCrypto
    case sellCrypto
    case sendCrypto(address: String, nickname: String?)
    case withdrawCollateral(address: String, nickname: String?, shouldSaveAddress: Bool)
    case withdrawReward(address: String, nickname: String?, balance: Double, shouldSaveAddress: Bool)
    case depositCollateral
    
    var id: String {
      switch self {
      case .buyCrypto:
        return "buyCrypto"
      case .sellCrypto:
        return "sellCrypto"
      case .sendCrypto:
        return "sendCrypto"
      case .withdrawCollateral:
        return "withdrawBalance"
      case .withdrawReward:
        return "withdrawReward"
      case .depositCollateral:
        return "sendCollateral"
      }
    }
  }
  
  enum Navigation {
    case confirmTransfer(viewModel: ConfirmTransferMoneyViewModel)
  }
  
  enum BlockPopup {
    case retryWithdrawalAfter(Int)
  }
}

// MARK: - Constant
extension MoveCryptoInputViewModel {
  private enum Constant {
    static let initValue = "0"
    
    enum Buy {
      static func buildRecommend(available: Double) -> [GridValue] {
        if available > 500 {
          return [.fixed(amount: 100, currency: .usd), .fixed(amount: 200, currency: .usd), .fixed(amount: 500, currency: .usd)]
        } else if available > 200 {
          return [.fixed(amount: 50, currency: .usd), .fixed(amount: 100, currency: .usd), .fixed(amount: 200, currency: .usd)]
        } else if available > 100 {
          return [.fixed(amount: 10, currency: .usd), .fixed(amount: 50, currency: .usd), .fixed(amount: 100, currency: .usd)]
        } else {
          return []
        }
      }
    }
    
    enum Sell {
      static func buildRecommend(
        available: Double,
        coin: String
      ) -> [GridValue] {
        if available > 1_000 {
          return [
            .fixed(amount: 100, currency: .crypto(coin: coin)),
            .fixed(amount: 1_000, currency: .crypto(coin: coin)),
            .all(amount: available, currency: .crypto(coin: coin))
          ]
        } else if available > 100 {
          return [
            .fixed(amount: 10, currency: .crypto(coin: coin)),
            .fixed(amount: 100, currency: .crypto(coin: coin)),
            .all(amount: available, currency: .crypto(coin: coin))
          ]
        } else if available > 10 {
          return [
            .fixed(amount: 1, currency: .crypto(coin: coin)),
            .fixed(amount: 10, currency: .crypto(coin: coin)),
            .all(amount: available, currency: .crypto(coin: coin))
          ]
        } else {
          return []
        }
      }
    }
  }
}

struct CryptoBalance: Codable {
  let availableSendBalance: String
  let availableSellBalance: String
}
