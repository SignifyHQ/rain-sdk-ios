import Foundation
import AccountDomain
import LFUtilities
import Factory

@MainActor
final class AssetsViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var assets: [AssetModel] = []
  @Published var navigation: Navigation?
  
  init() {
  }
  
  func onClickedAssetButton(assetType: AssetType) {
    guard let asset = assets.first(where: { $0.type == assetType }) else {
      return
    }
    switch assetType {
    case .usd:
      navigation = .usd(asset)
    default:
      navigation = .crypto(asset)
    }
  }
}

// MARK: - API
extension AssetsViewModel {
  func getAccounts() {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let fiatAccounts = try await self.accountRepository.getAccount(currencyType: Constants.CurrencyType.fiat.rawValue)
        let cryptoAccounts = try await self.accountRepository.getAccount(currencyType: Constants.CurrencyType.crypto.rawValue)
        let accounts = fiatAccounts + cryptoAccounts
        assets = accounts.map {
          AssetModel(
            type: AssetType(rawValue: $0.currency),
            availableBalance: $0.availableBalance,
            availableUsdBalance: $0.availableUsdBalance
          )
        }
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - Types
extension AssetsViewModel {
  enum Navigation {
    case usd(AssetModel)
    case crypto(AssetModel)
  }
}
