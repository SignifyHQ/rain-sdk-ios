import Foundation
import LFUtilities
import Factory
import Combine
import AccountData
import AccountDomain
import NetSpendData
import NetspendDomain
import DevicesData
import DevicesDomain
import RainOnboarding
import RainDomain
import Services
import AccountService
import UIKit
import GeneralFeature
import RainFeature

final class DashboardRepository: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.rainRepository) var rainRepository
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  
  lazy var accountUseCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
  }()
  
  lazy var nsGetLinkedAccountUseCase: NSGetLinkedAccountUseCaseProtocol = {
    NSGetLinkedAccountUseCase(repository: externalFundingRepository)
  }()
  
  lazy var getCreditBalanceUseCase: GetCreditBalanceUseCaseProtocol = {
    GetCreditBalanceUseCase(repository: rainRepository)
  }()
  
  @Published var fiatData: (fiatAccount: [AccountModel], loading: Bool) = ([], false)
  @Published var cryptoData: (cryptoAccounts: [AccountModel], loading: Bool) = ([], false)
  @Published var achInformationData: (model: ACHModel, loading: Bool) = (.default, false)
  @Published var isLoadingRewardTab: Bool = false
  
  var toastMessage: ((String) -> Void)?
  
  func onAppear() {
    fetchRainAccount()
    fetchNetspendLinkedSources()
  }
}

// MARK: API
extension DashboardRepository {
  func fetchRainAccount() {
    Task { @MainActor in
      defer { fiatData.loading = false }
      isLoadingRewardTab = true
      fiatData.loading = true
      
      do {
        guard let rainAccount = try await getRainAccount() else {
          return
        }
        
        fiatData.fiatAccount = [rainAccount]
        accountDataManager.accountsSubject.send([rainAccount])
        analyticsService.set(params: [PropertiesName.cashBalance.rawValue: rainAccount.availableBalance])
        
        // TODO: MinhNguyen - Will check and update later
        let asset = AssetModel(account: rainAccount)
        getRewardCurrency(assets: [asset])
        
      } catch {
        isLoadingRewardTab = false
        toastMessage?(error.userFriendlyMessage)
      }
    }
  }
  
  func getRewardCurrency(assets: [AssetModel] = []) {
    Task { @MainActor in
      do {
        let availableRewardCurrencies = try await accountRepository.getAvailableRewardCurrrencies()
        accountDataManager.availableRewardCurrenciesSubject.send(availableRewardCurrencies)
        let selectedRewardCurrency = try await accountRepository.getSelectedRewardCurrency()
        accountDataManager.selectedRewardCurrencySubject.send(selectedRewardCurrency)
        
        isLoadingRewardTab = false
      } catch {
        guard let errorObject = error.asErrorObject else {
          toastMessage?(error.userFriendlyMessage)
          isLoadingRewardTab = false
          return
        }
        switch errorObject.code {
        case Constants.ErrorCode.accountCreationInProgress.rawValue:
          let availableRewardCurrencies = APIAvailableRewardCurrencies(
            availableRewardCurrencies: assets.compactMap { $0.type?.rawValue }
          )
          accountDataManager.selectedRewardCurrencySubject.send(nil)
          accountDataManager.availableRewardCurrenciesSubject.send(availableRewardCurrencies)
        default:
          toastMessage?(errorObject.message)
        }
        isLoadingRewardTab = false
      }
    }
  }
  
  func getRainAccount() async throws -> AccountModel? {
    let response = try await getCreditBalanceUseCase.execute()
    guard let account = AccountModel(
      id: response.userId,
      externalAccountId: nil,
      currency: response.currency,
      availableBalance: response.availableBalance,
      availableUsdBalance: 0
    ) else {
      return nil
    }
    
    self.accountDataManager.addOrUpdateAccounts([account])
    return account
  }
  
  func fetchNetspendLinkedSources() {
    Task { @MainActor in
      do {
        let sessionID = self.accountDataManager.sessionID
        let response = try await self.nsGetLinkedAccountUseCase.execute(sessionId: sessionID)
        self.accountDataManager.storeLinkedSources(response.linkedSources)
      } catch {
        toastMessage?(error.userFriendlyMessage)
      }
    }
  }
}

// MARK: Notification
extension DashboardRepository {
  func checkNotificationsStatus(completion: @escaping (Bool) -> Void) {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        completion(status == .authorized)
      } catch {
        completion(false)
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func notificationTapped() {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        switch status {
        case .authorized:
          break
        case .notDetermined:
          let success = try await pushNotificationService.requestPermission()
          if success {
            break
          }
          return
        case .denied:
          if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
            await UIApplication.shared.open(settingsUrl)
          }
          return
        default:
          return
        }
        self.pushFCMTokenIfNeed()
      } catch {
        log.error(error)
      }
    }
  }
  
  func pushFCMTokenIfNeed() {
    Task { @MainActor in
      do {
        let token = try await pushNotificationService.fcmToken()
        let response = try await deviceRegisterUseCase.execute(deviceId: LFUtilities.deviceId, token: token)
        if response.success {
          UserDefaults.lastestFCMToken = token
        }
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }

}
