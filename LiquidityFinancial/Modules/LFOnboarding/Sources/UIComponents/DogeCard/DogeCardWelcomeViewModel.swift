import Foundation
import SwiftUI
import Factory
import NetSpendData
import LFUtilities
import Combine
import NetspendDomain

class DogeCardWelcomeViewModel: ObservableObject {
  
  @Injected(\.nsPersonRepository) var nsPersonRepository
  @Injected(\.netspendDataManager) var netspendDataManager
  
  @Published var isPushToAgreementView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  lazy var getAggrementUseCase: NSGetAgreementUseCaseProtocol = {
    NSGetAgreementUseCase(repository: nsPersonRepository)
  }()
  
  var cancellables: Set<AnyCancellable> = []
  
  func perfromInitialAccount() async {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let agreement = try await getAggrementUseCase.execute()
        netspendDataManager.update(agreement: agreement)
        isPushToAgreementView = true
      } catch {
        log.error(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
}
