import Foundation
import SwiftUI
import AccountDomain
import AccountData
import MeshData
import MeshDomain
import PortalDomain
import LFUtilities
import Factory
import Combine
import GeneralFeature
import Services

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
  
  lazy var refreshPortalAssetsUseCase: RefreshPortalAssetsUseCaseProtocol = {
    RefreshPortalAssetsUseCase(repository: portalRepository, storage: portalStorage)
  }()
  
  init(
    dashboardRepository: DashboardRepository
  ) {
    self.dashboardRepository = dashboardRepository
    
    Task {
      await refresh()
    }
    
    portalStorage
      .cryptoAssets()
      .receive(on: DispatchQueue.main)
      .map { assets in
        assets.map {
          AssetModel(portalAsset: $0)
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
      try await refreshPortalAssetsUseCase.execute()
    } catch {
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
}

// MARK: - Types
extension AssetsViewModel {
  enum Navigation {
    case usd(AssetModel)
    case crypto(AssetModel)
  }
}
