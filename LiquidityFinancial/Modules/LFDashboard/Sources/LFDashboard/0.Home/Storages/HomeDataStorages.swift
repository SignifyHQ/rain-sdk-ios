import UIKit
import Foundation
import Factory
import OnboardingData
import AccountData
import LFUtilities
import DevicesData
import LFAccountOnboarding
import OnboardingDomain
import AccountDomain
import NetSpendData
import Combine
import LFBank

@MainActor
final class HomeDataStorages: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @Published var isLoading: Bool = false
  @Published var allAssets: [AssetModel] = []
  @Published var fiatAccounts: [LFAccount] = []
  @Published var cryptoAccounts: [LFAccount] = []
  @Published var linkedAccount: [APILinkedSourceData] = []
  
  @Published var achInformationData: (model: ACHModel, loading: Bool) = (.default, false)
  
  private var cancellable: Set<AnyCancellable> = []
  
  var toastMessage: (String) -> Void
  init(toastMessage: @escaping (String) -> Void) {
    self.toastMessage = toastMessage
    initData()
  }
}

  // MARK: API init data tab content
extension HomeDataStorages {
  
  func initData() {
    apiFetchAssetFromAccounts()
    apiFetchListConnectedAccount()
    apiFetchACHInfo()
  }
  
  func refreshCash() {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let sessionID = self.accountDataManager.sessionID
        
        async let fiatAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.fiat.rawValue)
        
        async let linkedAccountEntity = self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        
        let fiatAccounts = try await fiatAccountsEntity
        let linkedSources = try await linkedAccountEntity.linkedSources
        
        let linkedAccount = linkedSources.compactMap({
          APILinkedSourceData(
            name: $0.name,
            last4: $0.last4,
            sourceType: APILinkSourceType(rawValue: $0.sourceType.rawString),
            sourceId: $0.sourceId,
            requiredFlow: $0.requiredFlow
          )
        })
        
        self.fiatAccounts = fiatAccounts
        self.linkedAccount = linkedAccount
      } catch {
        log.error(error.localizedDescription)
        toastMessage(error.localizedDescription)
      }
    }
  }
  
  func apiFetchAssetFromAccounts() {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        async let fiatAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.fiat.rawValue)
        async let cryptoAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.crypto.rawValue)
        let fiatAccounts = try await fiatAccountsEntity
        let cryptoAccounts = try await cryptoAccountsEntity
        let accounts = fiatAccounts + cryptoAccounts
        let assets = accounts.map {
          AssetModel(
            type: AssetType(rawValue: $0.currency),
            availableBalance: $0.availableBalance,
            availableUsdBalance: $0.availableUsdBalance
          )
        }
        self.fiatAccounts = fiatAccounts
        self.cryptoAccounts = cryptoAccounts
        self.allAssets = assets
      } catch {
        log.error(error.localizedDescription)
        toastMessage(error.localizedDescription)
      }
    }
  }
  
  func apiFetchListConnectedAccount() {
    Task {
      do {
        let sessionID = self.accountDataManager.sessionID
        let response = try await self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        let linkedAccount = response.linkedSources.compactMap({
          APILinkedSourceData(
            name: $0.name,
            last4: $0.last4,
            sourceType: APILinkSourceType(rawValue: $0.sourceType.rawString),
            sourceId: $0.sourceId,
            requiredFlow: $0.requiredFlow
          )
        })
        self.linkedAccount = linkedAccount
      } catch {
        log.error(error.localizedDescription)
        toastMessage(error.localizedDescription)
      }
    }
  }
  
  func apiFetchACHInfo() {
    Task {
      defer { achInformationData.loading = false }
      achInformationData.loading = true
      do {
        let achResponse = try await externalFundingRepository.getACHInfo(sessionID: accountDataManager.sessionID)
        let achInformation = ACHModel(
          accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
          routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
          accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
        )
        achInformationData.model = achInformation
      } catch {
        toastMessage(error.localizedDescription)
      }
    }
  }
}
