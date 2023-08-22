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
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var netspendController: NetspendSdkViewController?
  @Published var popup: Popup?
  @Published var navigation: Navigation?
  @Published var fundingStatus: APIAgreementData?
  @Published var isLoadingLinkExternalCard: Bool = false
  @Published var isLoadingLinkExternalBank: Bool = false
  
  private var nextNavigation: Navigation?
  
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.intercomService) var intercomService
  
}

// MARK: - ExternalLinkBank Functions
extension AddFundsViewModel {
  func linkExternalBank() {
    Task {
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
    isLoadingLinkExternalBank = false
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
  
  func apiFetchFundingStatus(for navigation: Navigation, onNext: @escaping (any ExternalFundingsatusEntity) -> Void) {
    Task {
      defer {
        if navigation == .addBankDebit {
          isLoadingLinkExternalCard = false
        }
      }
      if navigation == .linkExternalBank {
        isLoadingLinkExternalBank = true
      } else if navigation == .addBankDebit {
        isLoadingLinkExternalCard = true
      }
      do {
        let entity = try await self.externalFundingRepository.getFundingStatus(sessionID: accountDataManager.sessionID)
        onNext(entity)
      } catch {
        log.error(error.localizedDescription)
        isLoadingLinkExternalBank = false
      }
    }
  }
}

// MARK: - View Helpers
extension AddFundsViewModel {
  func goNextNavigation() {
    if nextNavigation == .linkExternalBank {
      linkExternalBank()
    } else {
      navigation = nextNavigation
    }
    nextNavigation = nil
  }
  
  func stopAction() {
    isLoadingLinkExternalBank = false
    nextNavigation = nil
  }
  
  func selectedAddOption(navigation: Navigation) {
    switch navigation {
    case .addBankDebit, .linkExternalBank:
      apiFetchFundingStatus(for: navigation) { [weak self] fundingStatus in
        guard let self else { return }
        let externalCardStatus = fundingStatus.externalCardStatus
        guard let missingSteps = externalCardStatus.missingSteps, let agreement = externalCardStatus.agreement else { return }
        if missingSteps.contains(WorkflowsMissingStep.acceptFeatureAgreement.rawValue) {
          let agreementData = APIAgreementData(agreement: agreement)
          self.nextNavigation = navigation
          self.fundingStatus = agreementData
        } else {
          if navigation == .linkExternalBank {
            linkExternalBank()
          } else {
            self.navigation = navigation
          }
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
    case linkExternalBank
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
