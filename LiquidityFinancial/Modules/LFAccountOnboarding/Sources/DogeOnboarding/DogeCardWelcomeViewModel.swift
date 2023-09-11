import Foundation
import SwiftUI
import Factory
import NetSpendData
import LFUtilities
import Combine

class DogeCardWelcomeViewModel: ObservableObject {
  
  @Injected(\.nsPersionRepository) var nsPersionRepository
  @Injected(\.netspendDataManager) var netspendDataManager
  
  @Published var isPushToAgreementView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  var cancellables: Set<AnyCancellable> = []
  
  func perfromInitialAccount() async {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let agreement = try await netspendRepository.getAgreement()
        netspendDataManager.update(agreement: agreement)
        isPushToAgreementView = true
      } catch {
        log.error(error)
        toastMessage = error.localizedDescription
      }
    }
  }
  
}
