import Combine
import SwiftUI
import Factory
import NetSpendData
import SolidDomain
import LFUtilities
import SolidData

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
  
  private var nextNavigation: Navigation?
  
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.solidLinkSourceRepository) var solidLinkSourceRepository
  
  lazy var createPlaidTokenUseCase: CreatePlaidTokenUseCaseProtocol = {
    CreatePlaidTokenUseCase(repository: solidLinkSourceRepository)
  }()
  
  lazy var plaidLinkUseCase: PlaidLinkUseCaseProtocol = {
    PlaidLinkUseCase(repository: solidLinkSourceRepository)
  }()
  
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
    guard let accountId = accountDataManager.fiatAccountID else {
      return
    }
    Task { @MainActor in
      defer { self.isLoadingLinkExternalBank = false }
      self.isLoadingLinkExternalBank = true
      do {
        let response = try await self.createPlaidTokenUseCase.execute(accountId: accountId)
        let plaidResponse = try await PlaidHelper.createLinkTokenConfiguration(token: response.linkToken, onCreated: { [weak self] configuration in
          self?.plaidConfig = PlaidConfig(config: configuration)
        })
        let solidContact = try await self.plaidLinkUseCase.execute(
          accountId: accountId,
          token: plaidResponse.publicToken,
          plaidAccountId: plaidResponse.plaidAccountId
        )
        guard let linkedSource = APILinkedSourceData(
          name: solidContact.name,
          last4: solidContact.last4,
          sourceType: APILinkSourceType(rawValue: solidContact.type),
          sourceId: solidContact.solidContactId,
          requiredFlow: nil
        ) else {
          self.onPlaidUIDisappear()
          return
        }
        self.accountDataManager.addOrEditLinkedSource(linkedSource)
        
        navigation = .addMoney
      } catch {
        log.error(error.localizedDescription)
        if let liquidError = error as? LiquidityError, liquidError == .userCancelled {
          self.onPlaidUIDisappear()
        } else {
          self.onLinkExternalBankFailure()
        }
      }
    }
    
  }
  
  func onPlaidUIDisappear() {
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
    case .linkExternalBank:
      linkExternalBank()
    case .addBankDebit:
      self.navigation = navigation
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
