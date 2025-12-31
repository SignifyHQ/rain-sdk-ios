import Factory
import Foundation
import GeneralFeature
import LFStyleGuide
import LFUtilities
import RainDomain

@MainActor
public final class AssetsBreakdownViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainRepository) var rainRepository
  
  @Published var navigation: Navigation?
  
  @Published var collateralAssets: [AssetModel] = []
  @Published var creditBalances: CreditBalances = CreditBalances()
  
  @Published var isBreakdownExpanded: Bool = false
  @Published var shouldShowTooltipWithId: String?
  @Published var shouldShowTotalAvailabelTooltip: Bool = false
  
  @Published var isLoadingData: Bool = true
  @Published var currentToast: ToastData? = nil
  
  private var isRefreshingData: Bool = false
  
  lazy var getCollateralContractUseCase: GetCollateralUseCaseProtocol = {
    GetCollateralUseCase(repository: rainRepository)
  }()
  
  lazy var getCreditBalanceUseCase: GetCreditBalanceUseCaseProtocol = {
    GetCreditBalanceUseCase(repository: rainRepository)
  }()
  
  init(
  ) {
    subscribeToCollateralChanges()
    subscribeToCreditBalancesChanges()
  }
  
  func onAppear() {
    Task {
      await onRefreshPull()
    }
  }
}

// MARK: - Binding Observables
extension AssetsBreakdownViewModel {
  // Subscribing to the collateral subject in account data manager
  private func subscribeToCollateralChanges(
  ) {
    accountDataManager
      .collateralContractSubject
      .compactMap { [weak self] rainCollateral in
        self?.isLoadingData = rainCollateral == nil
        
        return rainCollateral?
          .tokensEntity
          .compactMap { rainToken in
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
          .sorted {
            let oneIsPrio = $0.type == .frnt
            let twoIsPrio = $1.type == .frnt
            
            if oneIsPrio != twoIsPrio {
              return oneIsPrio
            }
            
            return ($0.type?.rawValue ?? "") < ($1.type?.rawValue ?? "")
          }
      }
      .assign(
        to: &$collateralAssets
      )
  }
  // Subscribing to the credit balances subject in account data manager
  private func subscribeToCreditBalancesChanges(
  ) {
    accountDataManager
      .creditBalancesSubject
      .compactMap { creditBalances in
        guard let creditBalances
        else {
          return CreditBalances()
        }
        
        return CreditBalances(rainCreditBalances: creditBalances)
      }
      .assign(
        to: &$creditBalances
      )
  }
}

// MARK: - Handling Interations
extension AssetsBreakdownViewModel {
  public func onRefreshPull(
  ) async {
    guard !isRefreshingData
    else {
      return
    }
    
    defer {
      isRefreshingData = false
    }
    
    isRefreshingData = true
    
    do {
      try await fetchCollateralContractAndCreditBalances()
    } catch {
      currentToast = ToastData(
        type: .error,
        body: error.userFriendlyMessage
      )
    }
  }
  // Navigate to add to card view
  public func onAddFundsButtonTap(
  ) {
    navigation = .addToCard
  }
  // Update the collateral the credit balances information and
  // broadcast it to all abservers via account data manager subject
  private func fetchCollateralContractAndCreditBalances(
  ) async throws {
    let collateralResponse = try await getCollateralContractUseCase.execute()
    let creditBalancesResponse = try await getCreditBalanceUseCase.execute()
    
    accountDataManager.storeCollateralContract(collateralResponse)
    accountDataManager.storeCreditBalances(creditBalancesResponse)
  }
}

// MARK: - Helper Methods
extension AssetsBreakdownViewModel {
  public var totalAssetValueFormatted: String {
    let totalUsdValue: Double = collateralAssets.reduce(0) { partialResult, asset in
      let cryptoUsdValue: Double = asset.availableBalance * (asset.exchangeRate ?? 1)
      
      return partialResult + cryptoUsdValue
    }
    
    return totalUsdValue.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: Constants.FractionDigitsLimit.fiat.minFractionDigits,
      maxFractionDigits: Constants.FractionDigitsLimit.fiat.maxFractionDigits
    )
  }
}

// MARK: - Private Enums
extension AssetsBreakdownViewModel {
  enum Navigation {
    case addToCard
  }
}
