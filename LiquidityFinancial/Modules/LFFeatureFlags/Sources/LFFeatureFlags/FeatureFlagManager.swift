import Foundation
import FeatureFlagDomain
import FeatureFlagData
import Factory
import SwiftyBeaver
import LFUtilities
import Combine

class FeatureFlagManager: FeatureFlagManagerProtocol {
  @LazyInjected(\.featureFlagRepository) var featureFlagRepository
  
  var featureFlagsSubject = CurrentValueSubject<[FeatureFlagModel], Never>([])
  
  private var subscriptions = Set<AnyCancellable>()
  
  lazy var listFeatureFlagUseCase: ListFeatureFlagUseCaseProtocol = {
    ListFeatureFlagUseCase(repository: featureFlagRepository)
  }()
  
  init() {
    NotificationCenter.default
      .publisher(for: .environmentChanage)
      .compactMap({ ($0.userInfo?[Notification.Name.environmentChanage.rawValue] as? NetworkEnvironment) })
      .sink { [weak self] value in
        log.debug("Featch feature flags with environment: \(value)")
        self?.fetchEnabledFeatureFlags()
      }
      .store(in: &subscriptions)
  }
  
  func fetchEnabledFeatureFlags() {
    Task {
      do {
        let response = try await listFeatureFlagUseCase.execute()
        self.featureFlagsSubject.send(response.data)
      } catch {
        log.error(error)
      }
    }
  }
  
  func signOut() {
    featureFlagsSubject.send([])
    // Fetch again to get all feature-flag enabled for all user
    fetchEnabledFeatureFlags()
  }
  
  func isFeatureFlagEnabled(_ key: FeatureFlagKey) -> Bool {
    featureFlagsSubject.value.first(where: { $0.key.uppercased().starts(with: key.rawValue.uppercased()) })?.enabled ?? false
  }
  
}
