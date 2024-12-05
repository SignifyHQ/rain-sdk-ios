import Factory
import Foundation
import GeneralFeature
import LFUtilities
import RainDomain

@MainActor
public final class CreditLimitBreakdownViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainRepository) var rainRepository
  
  @Published var isLoadingData: Bool = true
  
  @Published var collateralAssets: [AssetModel] = []
  @Published var creditBalances: CreditBalances = CreditBalances()
  
  lazy var getCollateralContractUseCase: GetCollateralUseCaseProtocol = {
    GetCollateralUseCase(repository: rainRepository)
  }()
  
  lazy var getCreditBalanceUseCase: GetCreditBalanceUseCaseProtocol = {
    GetCreditBalanceUseCase(repository: rainRepository)
  }()
  
  public init() {
    subscribeToCollateralChanges()
    subscribeToCreditBalancesChanges()
  }
  
  public func refreshData() {
    fetchCollateralContract()
    fetchCreditBalances()
  }
  
  private func subscribeToCollateralChanges() {
    accountDataManager
      .collateralContractSubject
      .compactMap { [weak self] rainCollateral in
        self?.isLoadingData = rainCollateral == nil

        return rainCollateral?
          .tokensEntity
          .compactMap { rainToken in
            AssetModel(rainCollateralAsset: rainToken)
          }
      }
      .assign(to: &$collateralAssets)
  }
  
  private func subscribeToCreditBalancesChanges() {
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
  
  private func fetchCollateralContract() {
    Task {
      do {
        let response = try await getCollateralContractUseCase.execute()
        accountDataManager.storeCollateralContract(response)
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  private func fetchCreditBalances() {
    Task {
      do {
        let response = try await getCreditBalanceUseCase.execute()
        accountDataManager.storeCreditBalances(response)
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
}
