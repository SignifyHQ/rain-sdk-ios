import Combine
import Foundation
import UIKit
import Factory
import NetSpendData
import LFUtilities
import LFLocalizable
import LFServices

class SelectBankAccountViewModel: ObservableObject {

  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.authenticationService) var authenticationService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var linkedBanks: [APILinkedSourceData] = []
  @Published var navigation: Navigation?
  @Published var selectedBank: APILinkedSourceData?
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
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
        toastMessage = error.localizedDescription
      }
    }
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
}
