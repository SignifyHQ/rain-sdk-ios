import Factory
import Foundation
import GeneralFeature
import LFUtilities
import RainDomain

@MainActor
public final class CreditLimitBreakdownViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainRepository) var rainRepository
  
  @Published var creditLimitFormatted: String = "-/-"
  @Published var collateralAssets: [AssetModel] = []
  
  lazy var getCollateralContractUseCase: GetCollateralUseCaseProtocol = {
    GetCollateralUseCase(repository: rainRepository)
  }()
  
  public init() {
    fetchCollateralContract()
    subscribeToCollateralChanges()
  }
  
  public func refreshData() {
    fetchCollateralContract()
  }
  
  private func subscribeToCollateralChanges() {
    accountDataManager
      .collateralContractSubject
      .compactMap { [weak self] rainCollateral in
        self?.creditLimitFormatted = rainCollateral?.creditLimit.formattedUSDAmount() ?? "-/-"
        
        return rainCollateral?
          .tokensEntity
          .compactMap { rainToken in
            AssetModel(rainCollateralAsset: rainToken)
          }
      }
      .assign(to: &$collateralAssets)
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
}
