import Foundation
import SwiftUI
import Factory
import NetSpendData
import LFUtilities
import Combine
import NetspendSdk
import FraudForce
import OnboardingData

class WelcomeViewModel: ObservableObject {
  
  @Injected(\.netspendRepository) var netspendRepository
  @Injected(\.netspendDataManager) var netspendDataManager
  @Injected(\.userDataManager) var userDataManager
  @Injected(\.onboardingRepository) var onboardingRepository
  
  @Published var isPushToAgreementView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  
  var cancellables: Set<AnyCancellable> = []

  func perfromInitialAccount() async {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let token = try await netspendRepository.clientSessionInit()
        netspendDataManager.update(jwkToken: token)
        
        let sessionConnectWithJWT = await netspendRepository.establishingSessionWithJWKSet(jwtToken: token)

        guard let deviceData = sessionConnectWithJWT?.deviceData else { return }

        let establishPersonSession = try await netspendRepository.establishPersonSession(deviceData: EstablishSessionParameters(encryptedData: deviceData))
        netspendDataManager.update(session: establishPersonSession)
        userDataManager.stored(sessionID: establishPersonSession.id)
        
        let userSessionAnonymous = try netspendRepository.createUserSession(establishingSession: sessionConnectWithJWT, encryptedData: establishPersonSession.encryptedData)
        netspendDataManager.update(userSession: userSessionAnonymous)

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
