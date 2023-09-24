import Combine
import Foundation
import UIKit
import Factory
import NetSpendData
import LFUtilities
import LFLocalizable
import LFServices
import NetspendSdk

class SelectBankAccountViewModel: ObservableObject {

  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.authenticationService) var authenticationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.intercomService) var intercomService
  
  @Published var linkedBanks: [APILinkedSourceData] = []
  @Published var navigation: Navigation?
  @Published var selectedBank: APILinkedSourceData?
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var popup: Popup?
  @Published var linkBankIndicator: Bool = false
  @Published var isDisableView: Bool = false
  @Published var isLoading: Bool = false
  @Published var netspendController: NetspendSdkViewController?
  
  let amount: String
  let kind: MoveMoneyAccountViewModel.Kind
  
  private var cancellable: Set<AnyCancellable> = []
  
  init(linkedAccount: [APILinkedSourceData], amount: String, kind: MoveMoneyAccountViewModel.Kind) {
    self.linkedBanks = linkedAccount.filter({ data in
      data.isVerified && data.sourceType == .externalBank
    })
    self.amount = amount
    self.kind = kind
    
    subscribeLinkedAccounts()
  }
  
  func subscribeLinkedAccounts() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else {
        return
      }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      self.linkedBanks = linkedSources.filter({ data in
        data.isVerified && data.sourceType == .externalBank
      })
    }
    .store(in: &cancellable)
  }
  
  func addNewBankAccount() {
    linkExternalBank()
  }
  
  func continueTapped() {
    guard selectedBank != nil else {
      return
    }
    callBioMetric()
  }
  
  func callBioMetric() {
    Task {
      if await authenticationService.authenticateWithBiometrics() {
        callTransferAPI()
      }
    }
  }
  
  func callTransferAPI() {
    guard let selectedBank = selectedBank, let amount = self.amount.asDouble else {
      toastMessage = LFLocalizable.MoveMoney.Error.noContact
      return
    }
    Task { @MainActor in
      defer {
        showIndicator = false
      }
      showIndicator = true
      do {
        let sessionID = self.accountDataManager.sessionID
        let parameters = ExternalTransactionParameters(
          amount: amount,
          sourceId: selectedBank.sourceId,
          sourceType: selectedBank.sourceType.rawValue
        )
        let type: ExternalTransactionType = kind == .receive ? .deposit : .withdraw
        let response = try await self.externalFundingRepository.newExternalTransaction(
          parameters: parameters,
          type: type,
          sessionId: sessionID
        )
        
        analyticsService.track(event: AnalyticsEvent(name: .sendMoneySuccess))
        
        //Push a notification for update transaction list event
        NotificationCenter.default.post(name: .moneyTransactionSuccess, object: nil)
        
        navigation = .transactionDetai(response.transactionId)
      } catch {
        handleTransferError(error: error)
      }
    }
  }
  
  func handleTransferError(error: Error) {
    guard let errorObject = error.asErrorObject else {
      toastMessage = error.localizedDescription
      return
    }
    switch errorObject.code {
      case Constants.ErrorCode.transferLimitExceeded.value:
        popup = .limitReached
      default:
        toastMessage = errorObject.message
    }
  }
}

// MARK: - ExternalLinkBank Functions
extension SelectBankAccountViewModel {
  func linkExternalBank() {
    Task { @MainActor in
      isDisableView = true
      linkBankIndicator = true
      do {
        let sessionID = accountDataManager.sessionID
        let tokenResponse = try await nsPersionRepository.getAuthorizationCode(sessionId: sessionID)
        let usingParams = ["redirectUri": LFUtility.universalLink]
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
    linkBankIndicator = false
    isDisableView = false
  }
  
  func onLinkExternalBankFailure() {
    onPlaidUIDisappear()
  }
  
  func onLinkExternalBankSuccess() {
    onPlaidUIDisappear()
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let sessionID = self.accountDataManager.sessionID
        async let linkedAccountResponse = self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        let linkedSources = try await linkedAccountResponse.linkedSources
        self.accountDataManager.storeLinkedSources(linkedSources)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func contactSupport() {
    intercomService.openIntercom()
  }
  
  func hidePopup() {
    popup = nil
  }
}

extension SelectBankAccountViewModel {

  func title(for account: APILinkedSourceData) -> String {
    switch account.sourceType {
    case .externalCard:
      return LFLocalizable.ConnectedView.Row.externalCard(account.last4)
    case .externalBank:
      return LFLocalizable.ConnectedView.Row.externalBank(account.name ?? "", account.last4)
    }
  }
  
}

// MARK: - Types
extension SelectBankAccountViewModel {
  enum Navigation {
    case transactionDetai(String)
  }
  
  enum Popup {
    case limitReached
  }
}
