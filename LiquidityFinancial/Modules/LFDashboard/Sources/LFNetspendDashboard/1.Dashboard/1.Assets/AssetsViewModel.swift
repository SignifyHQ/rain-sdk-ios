import Foundation
import SwiftUI
import AccountDomain
import PortalDomain
import LFUtilities
import Factory
import Combine
import GeneralFeature

@MainActor
final class AssetsViewModel: ObservableObject {
  @LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.accountRepository) var accountRepository
  
  let dashboardRepository: DashboardRepository
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var assets: [AssetModel] = []
  @Published var navigation: Navigation?
  
  lazy var refreshPortalBalancesUseCase: RefreshPortalBalancesUseCaseProtocol = {
    RefreshPortalBalancesUseCase(repository: portalRepository)
  }()
  
  init(
    dashboardRepository: DashboardRepository
  ) {
    self.dashboardRepository = dashboardRepository
    
    Task {
      await refresh()
    }
    
    portalStorage
      .cryptoBalances()
      .receive(on: DispatchQueue.main)
      .map { balances in
        balances.map {
          AssetModel(portalBalance: $0)
        }
        .sorted {
          ($0.type?.rawValue ?? "") < ($1.type?.rawValue ?? "")
        }
      }
      .assign(to: &$assets)
  }
  
  func onClickedAsset(asset: AssetModel) {
    if asset.type == .usd {
      navigation = .usd(asset)
    } else {
      navigation = .crypto(asset)
    }
  }
  
  func refresh() async {
    do {
      try await refreshPortalBalancesUseCase.execute()
    } catch {
      toastMessage = error.userFriendlyMessage
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
