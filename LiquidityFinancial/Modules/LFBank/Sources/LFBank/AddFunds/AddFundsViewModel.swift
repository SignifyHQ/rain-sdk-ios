import Combine
import SwiftUI
import Factory
import NetSpendData
import NetSpendDomain
import NetspendSdk
import LFUtilities
import LFAccountOnboarding

@MainActor
final class AddFundsViewModel: ObservableObject {
  @Published var isDisableView: Bool = false
  @Published var isOpeningPlaidView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var netspendController: NetspendSdkViewController?
  @Published var popup: Popup?
  @Published var navigation: Navigation?
  @Published var fundingStatus: APIAgreementData?
  
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.intercomService) var intercomService
  
}

// MARK: - ExternalLinkBank Functions
extension AddFundsViewModel {
  func linkExternalBank() {
    Task {
      isOpeningPlaidView = true
      isDisableView = true
      do {
        let sessionID = accountDataManager.sessionID
        let tokenResponse = try await netspendRepository.getAuthorizationCode(sessionId: sessionID)
        let controller = try NetspendSdk.shared.openWithPurpose(
          purpose: .linkBank,
          withPasscode: tokenResponse.authorizationCode
        )
        controller.view.isHidden = true
        self.netspendController = controller
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func onPlaidUIDisappear() {
    netspendController = nil
    isOpeningPlaidView = false
    isDisableView = false
  }
  
  func onLinkExternalBankFailure() {
    onPlaidUIDisappear()
    popup = .plaidLinkingError
  }
  
  func onLinkExternalBankSuccess() {
    onPlaidUIDisappear()
    navigation = .addMoney
  }
  
  func plaidLinkingErrorPrimaryAction() {
    popup = nil
    navigation = .addBankDebit
  }
  
  func plaidLinkingErrorSecondaryAction() {
    popup = nil
    intercomService.openIntercom()
  }
  
  func apiFetchFundingStatus(onNext: @escaping (any ExternalFundingsatusEntity) -> Void) {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let entity = try await self.externalFundingRepository.getFundingStatus(sessionID: accountDataManager.sessionID)
        onNext(entity)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
}

// MARK: - View Helpers
extension AddFundsViewModel {
  func selectedAddOption(navigation: Navigation) {
    switch navigation {
    case .addBankDebit:
      apiFetchFundingStatus { [weak self] fundingStatus in
        guard let self else { return }
        let externalCardStatus = fundingStatus.externalCardStatus
        guard let missingSteps = externalCardStatus.missingSteps, let agreement = externalCardStatus.agreement else { return }
        if missingSteps.contains(WorkflowsMissingStep.acceptFeatureAgreement.rawValue) {
          let agreementData = APIAgreementData(agreement: agreement)
          self.fundingStatus = agreementData
        } else {
          self.navigation = navigation
        }
      }
    default:
      self.navigation = navigation
    }
  }
}

// MARK: Types
extension AddFundsViewModel {
  enum Navigation {
    case bankTransfers
    case addBankDebit
    case addMoney
    case directDeposit
  }
  
  enum Popup {
    case plaidLinkingError
  }
}

extension APIAgreementData: Identifiable {
  public var id: String {
    UUID().uuidString
  }
}
