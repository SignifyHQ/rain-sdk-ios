import Foundation
import SwiftUI
import Factory
import NetSpendData
import NetspendDomain
import LFUtilities
import Combine
import NetspendSdk
import FraudForce
import OnboardingData

class WelcomeViewModel: ObservableObject {
  
  @Injected(\.nsPersonRepository) var nsPersonRepository
  @Injected(\.netspendDataManager) var netspendDataManager
  @Injected(\.onboardingRepository) var onboardingRepository
  
  @Published var isPushToAgreementView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  lazy var getAggreementUseCase: NSGetAgreementUseCaseProtocol = {
    NSGetAgreementUseCase(repository: nsPersonRepository)
  }()
  
  var cancellables: Set<AnyCancellable> = []

  func perfromInitialAccount() async {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let agreement = try await getAggreementUseCase.execute()
        netspendDataManager.update(agreement: agreement)
        isPushToAgreementView = true
      } catch {
        log.error(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
}
