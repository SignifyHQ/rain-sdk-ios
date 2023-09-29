import Combine
import SwiftUI
import Factory
import NetSpendData
import NetSpendDomain
import NetspendSdk
import LFUtilities

@MainActor
public final class AddFundsViewModel: ObservableObject {
  @Published var isDisableView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var netspendController: NetspendSdkViewController?
  @Published var popup: Popup?
  @Published var navigation: Navigation?
  
  @Published var isLoadingLinkExternalCard: Bool = false
  @Published var isLoadingLinkExternalBank: Bool = false
  
  public private(set) var fundingAgreementData = CurrentValueSubject<APIAgreementData?, Never>(nil)
  
  private var nextNavigation: Navigation?
  
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.intercomService) var intercomService
  
  func loading(option: FundOption) -> Bool {
    switch option {
    case .debitDeposit:
      return isLoadingLinkExternalCard
    case .oneTime:
      return isLoadingLinkExternalBank
    default:
      return false
    }
  }
  
  public init() {}
}

// MARK: - ExternalLinkBank Functions
extension AddFundsViewModel {
  func linkExternalBank() {
    Task {
      isDisableView = true
      do {
        let sessionID = accountDataManager.sessionID
        let tokenResponse = try await nsPersionRepository.getAuthorizationCode(sessionId: sessionID)
        let usingParams = ["redirectUri": LFUtilities.universalLink]
        log.info("NetSpend openWithPurpose usingParams: \(usingParams)")
        let controller = try NetspendSdk.shared.openWithPurpose(
          purpose: .linkBank,
          withPasscode: tokenResponse.authorizationCode,
          usingParams: usingParams
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
    Task { @MainActor in
      do {
        let sessionID = self.accountDataManager.sessionID
        async let linkedAccountResponse = self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        let linkedSources = try await linkedAccountResponse.linkedSources
        self.accountDataManager.storeLinkedSources(linkedSources)
        
        navigation = .addMoney
      } catch {
        log.error(error.localizedDescription)
      }
    }
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
  public func goNextNavigation() {
    if nextNavigation == .linkExternalBank {
      linkExternalBank()
    } else {
      navigation = nextNavigation
    }
    nextNavigation = nil
  }
  
  public func stopAction() {
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
          self.fundingAgreementData.send(agreementData)
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
