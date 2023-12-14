import Combine
import Foundation
import UIKit
import Factory
import NetSpendData
import LFUtilities
import LFLocalizable
import Services
import NetspendSdk
import NetspendDomain
import EnvironmentService
import BiometricsManager

class SelectBankAccountViewModel: ObservableObject {
  
  var networkEnvironment: NetworkEnvironment {
    environmentService.networkEnvironment
  }
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.nsPersonRepository) var nsPersonRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  
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
  
  lazy var getLinkedAccountUsecase: NSGetLinkedAccountUseCaseProtocol = {
    NSGetLinkedAccountUseCase(repository: externalFundingRepository)
  }()
  
  lazy var newExternalTransactionUseCase: NSNewExternalTransactionUseCaseProtocol = {
    NSNewExternalTransactionUseCase(repository: externalFundingRepository)
  }()
  
  lazy var getAuthorizationUseCase: NSGetAuthorizationCodeUseCaseProtocol = {
    NSGetAuthorizationCodeUseCase(repository: nsPersonRepository)
  }()
  
  private var cancellables: Set<AnyCancellable> = []
  
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
    .store(in: &cancellables)
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
    biometricsManager.performDeviceAuthentication()
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        switch completion {
        case .finished:
          log.debug("Device authentication check completed.")
        case .failure(let error):
          self.toastMessage = error.localizedDescription
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        if result {
          self.callTransferAPI()
        }
      })
      .store(in: &cancellables)
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
          sourceType: selectedBank.sourceType.rawValue,
          m2mFeeRequestId: nil
        )
        let type: ExternalTransactionType = kind == .receive ? .deposit : .withdraw
        let response = try await self.newExternalTransactionUseCase.execute(
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
        let tokenResponse = try await getAuthorizationUseCase.execute(sessionId: sessionID)
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
        async let linkedAccountResponse = self.getLinkedAccountUsecase.execute(sessionId: sessionID)
        let linkedSources = try await linkedAccountResponse.linkedSources
        self.accountDataManager.storeLinkedSources(linkedSources)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func contactSupport() {
    customerSupportService.openSupportScreen()
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
