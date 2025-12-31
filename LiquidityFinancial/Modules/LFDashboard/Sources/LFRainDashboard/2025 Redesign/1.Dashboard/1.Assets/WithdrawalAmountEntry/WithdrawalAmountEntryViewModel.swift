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
final class WithdrawalAmountEntryViewModel: ObservableObject {
  @LazyInjected(\.environmentService) var environmentService
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
      updateDropdownAssetModelList()
    }
  }

  @Published var assetModelList: [AssetModel] = [] {
    didSet {
      updateDropdownAssetModelList()
    }
  }
  @Published var dropdownAssetModelList: [AssetModel] = []
  @Published var creditBalances: CreditBalances?
  @Published var navigation: Navigation?
  @Published var blockPopup: BlockPopup?
  @Published var isFetchingData = false
  @Published var isLoading = false
  @Published var isPerformingAction = false
  @Published var shouldRetryWithdrawal = false
  @Published var amountInput = "0"
  @Published var numberOfShakes = 0
  @Published var isShowingTokenDropdown: Bool = false
  @Published var inlineError: String?
  @Published var toastData: ToastData?
  @Published var selectedValue: AmountPresetItem? {
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
  
  var gridValues: [AmountPresetItem] = []
  
  var availableBalance: Double? {
    guard let spendingPower = creditBalances?.spendingPower,
          let advanceRate = assetModel.advanceRate,
          let exchangeRate = assetModel.exchangeRate
    else {
      return nil
    }
    
    let balance = assetModel.availableBalance
    let withdrawLimitUSD = spendingPower * 100.00 / advanceRate
    let withdrawLimitCrypto = withdrawLimitUSD / exchangeRate

    let finalWithdrawLimitCrypto = min(withdrawLimitCrypto, balance)
    
    return finalWithdrawLimitCrypto
  }
  
  var maxFractionDigits: Int {
    LFUtilities.cryptoFractionDigits
  }
  
  var availableAmount: String? {
    let cryptoCurrency = assetModel.type?.symbol ?? .empty
    let availableBalanceString: String = {
      if let availableBalance {
        return availableBalance.formattedAmount(minFractionDigits: 2, maxFractionDigits: 6)
      } else {
        return "n/a"
      }
    }()
    
    return L10N.Common.MoveCryptoInput.WithdrawCollateralAvailableBalance.subtitle(
      availableBalanceString, cryptoCurrency
    )
  }
  
  var isActionAllowed: Bool {
    !(amount.isZero || inlineError.isNotNil)
  }
  
  var amount: Double {
    amountInput.removeGroupingSeparator().convertToDecimalFormat().asDouble ?? 0.0
  }

  private let address: String
  private let nickname: String
  
  init(
    assetModel: AssetModel,
    address: String,
    nickname: String
  ) {
    self.assetModel = assetModel
    self.address = address
    self.nickname = nickname
    
    observeAssets()
    generateGridValues()
  }
}

// MARK: - Binding Observables
private extension WithdrawalAmountEntryViewModel {
  func observeAssets() {
    observeCollateralAssets()
    subscribeToCreditBalancesChanges()
  }
  
  func observeCollateralAssets() {
    accountDataManager
      .collateralContractSubject
      .compactMap { rainCollateral in
        var assets = rainCollateral?
          .tokensEntity
          .compactMap { rainToken -> AssetModel? in
            let assetModel = AssetModel(rainCollateralAsset: rainToken)
            
            // Filter out tokens of unsupported type
            guard assetModel.type != nil && !assetModel.id.isEmpty
            else {
              return nil
            }
            
            // FRNT exclusive experience, only show FRNT token if user has balance
            guard assetModel.type != .frnt || assetModel.availableBalance > 0
            else {
              return nil
            }
            
            return assetModel
          }
        
        // Hardcode USDT.t to enable withdrawal
        let usdte = AssetModel(
          id: "0xc7198437980c041c805a1edcba50c1ce5db95118",
          type: .usdte,
          availableBalance: 0,
          availableUsdBalance: 0,
          externalAccountId: nil
        )
        
        assets?.append(usdte)
        assets?.sort {
          let oneIsPrio = $0.type == .frnt
          let twoIsPrio = $1.type == .frnt
          
          if oneIsPrio != twoIsPrio {
            return oneIsPrio
          }
          
          return ($0.type?.rawValue ?? "") < ($1.type?.rawValue ?? "")
        }
        
        return assets
      }
      .sink { [weak self] assets in
        self?.assetModelList = assets
      }
      .store(in: &subscribers)
  }
  
  func subscribeToCreditBalancesChanges() {
    accountDataManager
      .creditBalancesSubject
      .compactMap { creditBalances in
        guard let creditBalances
        else {
          return CreditBalances()
        }
        
        return CreditBalances(rainCreditBalances: creditBalances)
      }
      .assign(to: &$creditBalances)
  }
  
  func updateDropdownAssetModelList() {
    // Selected asset will not display on the dropdown (Figma)
    dropdownAssetModelList = assetModelList.filter({ $0.id != assetModel.id })
  }
}

// MARK: - Handling Interations
extension WithdrawalAmountEntryViewModel {
  func onContinueButtonTap() {
    Haptic.impact(.light).generate()
    generateWithdrawCollateralQuote(shouldSaveAddress: true)
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
  
  func onSelectedGridItem(_ gridValue: AmountPresetItem) {
    selectedValue = gridValue
    amountInput = gridValue.formattedInput
  }
  
  func handleAfterWaitingRetryTime() {
    hidePopup()
    shouldRetryWithdrawal = true
  }
}

// MARK: - Handling UI/UX Logic
extension WithdrawalAmountEntryViewModel {
  private func hidePopup() {
    blockPopup = nil
  }
}

// MARK: - APIs Handler
private extension WithdrawalAmountEntryViewModel {
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
          toastData = ToastData(type: .error, title: L10N.Common.MoveCryptoInput.NoCollateralContract.errorMessage)
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
        
        let viewModel = WithdrawalConfirmationViewModel(
          kind: .withdrawalCollateral(
            addresses: withdrawAddresses,
            signature: signature,
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
    PortalService.WithdrawAssetAddresses(
      contractAddress: controllerAddress,
      proxyAddress: collateralContract.address,
      recipientAddress: recipientAddress,
      tokenAddress: assetModel.id
    )
  }
  
  func getWithdrawalSignature(
    chainId: Int
  ) async throws -> PortalService.WithdrawAssetSignature? {
    var conversionFactor = assetModel.conversionFactor
    
    // FRNT in DEV conversion factor is 18 and not 6
    if assetModel.type == .frnt && environmentService.networkEnvironment == .productionTest {
      conversionFactor = 18
    }
    
    let amount = amount * pow(10, Double(conversionFactor))
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

// MARK: - View Helpers
extension WithdrawalAmountEntryViewModel {
  func generateGridValues() {
    let cryptoCurrency = assetModel.type?.symbol ?? .empty
    gridValues = Constant.buildRecommendedGrid(available: availableBalance ?? 0, coin: cryptoCurrency)
  }
  
  func validateAmountInput() {
    numberOfShakes = 0
    
    inlineError = assetModel.type == .usdte ? nil : validateAmount(with: availableBalance)
    
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
    
    if amount > 0, amount < 0.0001 {
      return L10N.Common.MoveCryptoInput.MinimumCrypto.description(assetModel.type?.symbol ?? .empty)
    }
    
    if balance < amount {
      if let availableAmount {
        return availableAmount + ". " + L10N.Common.WithdrawalAmount.ExceedAvailable.title
      }
      return L10N.Common.WithdrawalAmount.ExceedAvailable.title
    }
    
    return nil
  }
  
  func handlePortalError(
    error: Error
  ) {
    guard let portalError = error as? LFPortalError else {
      toastData = ToastData(type: .error, title: error.userFriendlyMessage)
      log.error(error.userFriendlyMessage)
      
      return
    }
    
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
extension WithdrawalAmountEntryViewModel {
  enum Navigation {
    case confirmTransfer(viewModel: WithdrawalConfirmationViewModel)
  }
  
  enum BlockPopup {
    case retryWithdrawalAfter(Int)
  }
  
  private enum Constant {
    static let initValue = "0"
    
    static func buildRecommendedGrid(
      available: Double,
      coin: String
    ) -> [AmountPresetItem] {
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
      } else {
        return [
          .fixed(amount: 1, currency: .crypto(coin: coin)),
          .fixed(amount: 10, currency: .crypto(coin: coin)),
          .all(amount: available, currency: .crypto(coin: coin))
        ]
      }
    }
  }
}
