import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Factory
import AccountDomain
import Combine
import ZerohashDomain
import AccountService
import ZerohashData
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
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  @LazyInjected(\.cryptoAccountService) var cryptoAccountService
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  @LazyInjected(\.portalService) var portalService
  
  @Published var assetModel: AssetModel
  @Published var fiatAccount: AccountModel?
  
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var blockPopup: BlockPopup?
  @Published var isFetchingData = false
  @Published var isLoading = false
  @Published var isPerformingAction = false
  @Published var shouldRetryWithdrawal = false
  @Published var amountInput = "0"
  @Published var numberOfShakes = 0
  @Published var inlineError: String?
  @Published var toastMessage: String?
  @Published var selectedValue: GridValue? {
    didSet {
      Haptic.selection.generate()
    }
  }
  
  private lazy var getSellCryptoQouteUseCase: GetSellQuoteUseCaseProtocol = {
    GetSellQuoteUseCase(repository: zerohashRepository)
  }()
  
  private lazy var getBuyCryptoQouteUseCase: GetBuyQuoteUseCaseProtocol = {
    GetBuyQuoteUseCase(repository: zerohashRepository)
  }()
  
  private lazy var sendEthUseCase: SendEthUseCaseProtocol = {
    SendEthUseCase(repository: portalRepository)
  }()
  
  private lazy var getWithdrawalSignatureUseCase: GetWithdrawalSignatureUseCaseProtocol = {
    GetWithdrawalSignatureUseCase(repository: rainRepository)
  }()
  
  private var subscribers: Set<AnyCancellable> = []
  
  let type: Kind
  var gridValues: [GridValue] = []
  
  init(type: Kind, assetModel: AssetModel) {
    self.type = type
    self.assetModel = assetModel
    getAccount()
    observeAccounts()
    generateGridValues()
  }
}

// MARK: - API Handle
private extension MoveCryptoInputViewModel {
  func getAccount() {
    let cryptoId = self.assetModel.id
    Task {
      if type == .buyCrypto {
        let fiatAccounts = try await getFiatAccounts()
        self.accountDataManager.addOrUpdateAccounts(fiatAccounts)
        
        if let fiatAccount = fiatAccounts.first {
          self.accountDataManager.fiatAccountID = fiatAccount.id
        }
      }
      let cryptoAccount = try await self.cryptoAccountService.getAccountDetail(id: cryptoId)
      self.accountDataManager.addOrUpdateAccount(cryptoAccount)
      self.accountDataManager.cryptoAccountID = cryptoId
      
      generateGridValues()
    }
  }
  
  func fetchSendCryptoQuote(amount: Double, address: String) {
    Task {
      defer { isPerformingAction = false }
      isPerformingAction = true
      do {
        let txFee = try await sendEthUseCase.estimateFee(to: address, contractAddress: assetModel.id.nilIfEmpty, amount: amount)
        // TODO(Volo): Refactor fee response for Portal
        let feeResponse = APILockedNetworkFeeResponse(quoteId: "", amount: amount, maxAmount: false, fee: txFee)
        navigation = .confirmSend(lockedFeeResponse: feeResponse)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func fetchBuyCryptoQuote(amount: String) {
    Task { @MainActor in
      defer { isPerformingAction = false }
      isPerformingAction = true
      do {
        let accountID = assetModel.id
        let entity = try await getBuyCryptoQouteUseCase.execute(accountId: accountID, amount: nil, quantity: amount)
        navigation = .confirmBuy(entity, accountId: accountID)
      } catch {
        log.error(error)
        self.toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func fetchSellCryptoQuote(amount: String) {
    Task { @MainActor in
      defer { isPerformingAction = false }
      isPerformingAction = true
      do {
        let accountID = assetModel.id
        let entity = try await getSellCryptoQouteUseCase.execute(accountId: accountID, amount: nil, quantity: amount)
        navigation = .confirmSell(entity, accountId: accountID)
      } catch {
        log.error(error)
        self.toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func getFiatAccounts() async throws -> [AccountModel] {
    let accounts = try await fiatAccountService.getAccounts()
    self.accountDataManager.addOrUpdateAccounts(accounts)
    return accounts
  }
  
  func sendCollateral() async throws {
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
    
    try await sendEthUseCase.executeSend(
      to: collateralContract.address,
      contractAddress: assetModel.id,
      amount: amount
    )
  }
  
  func withdrawCollateral(recipientAddress: String) {
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
        
        guard let signature = try await getWithdrawalSignature(
          chainId: collateralContract.chainId,
          recipientAddress: recipientAddress
        ) else {
          return
        }
        
        guard let withdrawAddresses = generateWithdrawAssetAddresses(
          collateralContract: collateralContract,
          controllerAddress: controllerAddress,
          recipientAddress: recipientAddress
        ) else {
          return
        }
        try await portalRepository.withdrawAsset(addresses: withdrawAddresses, amount: amount, signature: signature)
        // TODO: MinhNguyen - Refactor transaction detail for Portal Send
        self.navigation = .transactionDetail(id: "")
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func getWithdrawalSignature(chainId: Int, recipientAddress: String) async throws -> PortalService.WithdrawAssetSignature? {
    let amount = amount * 1e2 // Convert USD to cent
    let parameters = APIRainWithdrawalSignatureParameters(
      chainId: chainId,
      token: assetModel.id,
      amount: String(amount),
      recipientAddress: recipientAddress
    )
    let signature = try await getWithdrawalSignatureUseCase.execute(parameters: parameters)
    
    if let retryAfterSeconds = signature.retryAfterSeconds {
      blockPopup = .retryWithdrawalAfter(retryAfterSeconds)
      return nil
    }
    
    guard let signatureEntity = signature.signatureEntity, let expiresAt = signature.expiresAt else {
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
  func generateGridValues() {
    let cryptoCurrency = assetModel.type?.title ?? .empty
    switch type {
    case .buyCrypto, .withdrawCollateral:
      gridValues = Constant.Buy.buildRecommend(available: fiatAccount?.availableBalance ?? 0)
    case .sellCrypto, .sendCrypto, .sendCollateral:
      gridValues = Constant.Sell.buildRecommend(available: assetModel.availableBalance, coin: cryptoCurrency)
    }
  }
  
  func observeAccounts() {
    accountDataManager
      .accountsSubject
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] accounts in
        guard let self = self else {
          return
        }
        if let cryptoAccount = accounts.first(where: {
          $0.id == self.assetModel.id
        }) {
          self.assetModel = AssetModel(account: cryptoAccount)
        }
        self.fiatAccount = accounts.first(where: { account in
          account.currency.isFiat
        })
      })
      .store(in: &subscribers)
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
    case .buyCrypto, .withdrawCollateral:
      return true
    case .sellCrypto, .sendCrypto, .sendCollateral:
      return false
    }
  }
  
  var isCryptoCurrency: Bool {
    switch type {
    case .buyCrypto, .withdrawCollateral:
      return false
    case .sellCrypto, .sendCrypto, .sendCollateral:
      return true
    }
  }
  
  var maxFractionDigits: Int {
    switch type {
    case .buyCrypto, .withdrawCollateral:
      return 2
    case .sellCrypto, .sendCrypto, .sendCollateral:
      return LFUtilities.cryptoFractionDigits
    }
  }
  
  var showCryptoDisclosure: Bool {
    true
  }
  
  var showEstimatedFeeDescription: Bool {
    switch type {
    case .sendCrypto, .sendCollateral:
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
    case .sendCollateral:
      return L10N.Common.MoveCryptoInput.SendCollateral.title.uppercased()
    }
  }
  
  var subtitle: String? {
    let cryptoCurrency = assetModel.type?.title ?? .empty
    switch type {
    case .buyCrypto:
      return L10N.Common.MoveCryptoInput.BuyAvailableBalance.subtitle(
        fiatAccount?.availableBalance.formattedUSDAmount() ?? "$0.00"
      )
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
      return L10N.Common.MoveCryptoInput.WithdrawCollateralAvailableBalance.subtitle(
        fiatAccount?.availableBalance.formattedUSDAmount() ?? "$0.00"
      )
    case .sendCollateral:
      let balance = assetModel.availableBalance.roundTo3f()
      return L10N.Common.MoveCryptoInput.SendCollateralAvailableBalance.subtitle(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3), cryptoCurrency
      )
    }
  }
  
  var annotationString: String {
    switch type {
    case .buyCrypto:
      return L10N.Common.MoveCryptoInput.Buy.annotation(
        fiatAccount?.availableBalance.formattedUSDAmount() ?? "$0.00"
      )
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
      return L10N.Common.MoveCryptoInput.WithdrawCollateral.annotation(
        fiatAccount?.availableBalance.formattedUSDAmount() ?? "$0.00"
      )
    case .sendCollateral:
      let balance = assetModel.availableBalance.roundTo3f()
      return L10N.Common.MoveCryptoInput.SendCollateral.annotation(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3),
        assetModel.type?.title ?? .empty
      )
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
    case .withdrawCollateral(let address, _):
      return address
    default:
      return .empty
    }
  }
  
  var nickname: String {
    switch type {
    case .sendCrypto(_, let nickname):
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
      fetchBuyCryptoQuote(amount: "\(amount)")
    case .sellCrypto:
      fetchSellCryptoQuote(amount: "\(amount)")
    case .sendCrypto:
      fetchSendCryptoQuote(amount: amount, address: address)
    case let .withdrawCollateral(address, _):
      withdrawCollateral(recipientAddress: address)
    case .sendCollateral:
      popup = .confirmSendCollateral
    }
  }
  
  /// Reset amountInput and selectedValue when interacting with keyboard
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
    case .sellCrypto, .sendCrypto, .sendCollateral:
      inlineError = validateAmount(with: assetModel.availableBalance)
    case .buyCrypto, .withdrawCollateral:
      inlineError = validateAmount(with: fiatAccount?.availableBalance)
    }
    if inlineError.isNotNil {
      withAnimation(.linear(duration: 0.5)) {
        numberOfShakes = 4
      }
    }
  }
  
  func validateAmount(with availableBalance: Double?) -> String? {
    guard let balance = availableBalance else { return nil }
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
    popup = nil
    blockPopup = nil
  }
  
  func handleAfterWaitingRetryTime() {
    hidePopup()
    shouldRetryWithdrawal = true
  }
  
  func confirmSendCollateralButtonTapped(completion: @escaping () -> Void) {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        try await sendCollateral()
        hidePopup()
        completion()
      } catch {
        handlePortalError(error: error)
      }
    }
  }
}

// MARK: - Types
extension MoveCryptoInputViewModel {
  enum Kind: Equatable, Identifiable {
    case buyCrypto
    case sellCrypto
    case sendCrypto(address: String, nickname: String?)
    case withdrawCollateral(address: String, nickname: String?)
    case sendCollateral
    
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
      case .sendCollateral:
        return "sendCollateral"
      }
    }
  }
  
  enum Navigation {
    case confirmSell(GetSellQuoteEntity, accountId: String)
    case confirmBuy(GetBuyQuoteEntity, accountId: String)
    case confirmSend(lockedFeeResponse: APILockedNetworkFeeResponse)
    case transactionDetail(id: String)
  }
  
  enum Popup {
    case confirmSendCollateral
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
      static func buildRecommend(available: Double, coin: String) -> [GridValue] {
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
