import CoreNetwork
import Factory
import LFUtilities
import Combine
import UIKit
import LFStyleGuide
import LFServices
import SwiftUI
import OnboardingData
import AccountData
import NetSpendData
import NetSpendDomain

@MainActor
class VerifyCardViewModel: ObservableObject {
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.customSupportService) var customSupportService
  
  private let cardId: String
  
  init(cardId: String) {
    self.cardId = cardId
  }
  
  @Published var loading: Bool = false
  @Published var actionEnabled: Bool = false
  @Published var dateError: String?
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  @Published var amount: String = "" {
    didSet {
      checkAction()
    }
  }

  func performAction() {
    loading = true
    Task { @MainActor in
      defer {
        self.loading = false
      }
      do {
        guard let session = netspendDataManager.sdkSession else {
          return
        }
        guard let transferAmount = Double(amount) else {
          return
        }
        let parameter = VerifyExternalCardParameters(transferAmount: transferAmount, cardId: cardId)
        _ = try await externalFundingRepository.verifyCard(sessionId: session.sessionId, request: parameter)
        navigation = .moveMoney
      } catch {
        log.error(error.localizedDescription)
        self.toastMessage = error.localizedDescription
      }
    }
  }
  
  func contactSupport() {
    customSupportService.openSupportScreen()
  }

  func dismissPopup() {
  }

  private var validAmount: Bool {
    Double(amount.removeWhitespace()) != nil
  }
  
  private func checkAction() {
    actionEnabled = validAmount
  }
}

extension VerifyCardViewModel {
  enum Navigation {
    case moveMoney
  }
}
