import Combine
import SwiftUI
import Factory
import SolidDomain
import LFUtilities
import SolidData
import ExternalFundingData
import LinkKit

@MainActor
public final class AddFundsViewModel: ObservableObject {
  @Published var isDisableView: Bool = false
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var popup: Popup?
  @Published var navigation: Navigation?
  @Published var plaidConfig: PlaidConfig?
  
  @Published var isLoadingLinkExternalBank: Bool = false
  
  private var nextNavigation: Navigation?
  
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  
  lazy var createPlaidTokenUseCase: CreatePlaidTokenUseCaseProtocol = {
    CreatePlaidTokenUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var plaidLinkUseCase: PlaidLinkUseCaseProtocol = {
    PlaidLinkUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var getAccountUsecase: SolidGetAccountsUseCaseProtocol = {
    SolidGetAccountsUseCase(repository: solidAccountRepository)
  }()
  
  func loading(option: FundOption) -> Bool {
    switch option {
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
    Task { @MainActor in
      defer { self.isLoadingLinkExternalBank = false }
      self.isLoadingLinkExternalBank = true
      do {
        let accounts = self.accountDataManager.fiatAccounts
        guard let accountId = accounts.first?.id else {
          return
        }
        let response = try await self.createPlaidTokenUseCase.execute(accountId: accountId)
        let plaidResponse = try await PlaidHelper.createLinkTokenConfiguration(token: response.linkToken, onCreated: { [weak self] configuration in
          guard let self = self else {
            return
          }
          Task {
            await MainActor.run {
              self.plaidConfig = PlaidConfig(config: configuration)
            }
          }
        })
        let solidContact = try await self.plaidLinkUseCase.execute(
          accountId: accountId,
          token: plaidResponse.publicToken,
          plaidAccountId: plaidResponse.plaidAccountId
        )
        guard let type = APISolidContactType(rawValue: solidContact.type) else {
          self.onPlaidUIDisappear()
          return
        }
        let sourceType: LinkedSourceContactType = type == .externalBank ? .bank : .card
        let contact = LinkedSourceContact(
          name: solidContact.name,
          last4: solidContact.last4,
          sourceType: sourceType,
          sourceId: solidContact.solidContactId
        )
        self.externalFundingDataManager.addOrEditLinkedSource(contact)
        
        navigation = .addMoney
      } catch {
        log.error(error.userFriendlyMessage)
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
  
  func plaidLinkingErrorPrimaryAction() {
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
    default:
      self.navigation = navigation
    }
  }
}

// MARK: Types
extension AddFundsViewModel {
  enum Navigation {
    case bankTransfers
    case addMoney
    case directDeposit
    case linkExternalBank
  }
  
  enum Popup {
    case plaidLinkingError
  }
}
