import Combine
import SwiftUI
import Factory
import NetSpendData
import NetSpendDomain
import LFUtilities

@MainActor
public final class AddFundsViewModel: ObservableObject {
  @Published var isDisableView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var popup: Popup?
  @Published var navigation: Navigation?
  @Published var plaidConfig: PlaidConfig?
  
  @Published var isLoadingLinkExternalCard: Bool = false
  @Published var isLoadingLinkExternalBank: Bool = false
  
  public private(set) var fundingAgreementData = CurrentValueSubject<APIAgreementData?, Never>(nil)
  private lazy var plaidHelper = PlaidHelper()
  
  private var nextNavigation: Navigation?
  
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  
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
    plaidHelper.onLoading = { @MainActor [weak self] isLoading in
      self?.isLoadingLinkExternalBank = isLoading
    }

    plaidHelper.onFailure = { @MainActor [weak self] _ in
      self?.onLinkExternalBankFailure()
    }

    plaidHelper.onExit = { @MainActor [weak self] in
      self?.onPlaidUIDisappear()
    }

    plaidHelper.onSuccess = { @MainActor [weak self] in
      self?.onLinkExternalBankSuccess()
    }

    plaidHelper.load { @MainActor [weak self] value in
      self?.plaidConfig = value
    }
  }
  
  func onPlaidUIDisappear() {
    plaidConfig = nil
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
    customerSupportService.openSupportScreen()
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
