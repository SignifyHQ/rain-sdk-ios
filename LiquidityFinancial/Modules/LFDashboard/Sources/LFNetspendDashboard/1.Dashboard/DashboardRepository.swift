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
import NetspendOnboarding
import Services
import AccountService
import UIKit
import GeneralFeature
import NetspendFeature

final class DashboardRepository: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  @LazyInjected(\.cryptoAccountService) var cryptoAccountService
  
  lazy var accountUseCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
  }()

  lazy var nsGetACHInfoUseCase: NSGetACHInfoUseCaseProtocol = {
    NSGetACHInfoUseCase(repository: externalFundingRepository)
  }()
  
  lazy var nsGetLinkedAccountUseCase: NSGetLinkedAccountUseCaseProtocol = {
    NSGetLinkedAccountUseCase(repository: externalFundingRepository)
  }()
  
  @Published var fiatData: (fiatAccount: [AccountModel], loading: Bool) = ([], false)
  @Published var cryptoData: (cryptoAccounts: [AccountModel], loading: Bool) = ([], false)
  @Published var achInformationData: (model: ACHModel, loading: Bool) = (.default, false)
  @Published var isLoadingRewardTab: Bool = false
  
  var toastMessage: ((String) -> Void)?
  
  func onAppear() {
    apiFetchAssetFromAccounts()
    apiFetchACHInfo()
    fetchNetspendLinkedSources()
  }
}

// MARK: API
extension DashboardRepository {
  
  func apiFetchAssetFromAccounts() {
    Task { @MainActor in
      defer {
        fiatData.loading = false
        cryptoData.loading = false
      }
      isLoadingRewardTab = true
      fiatData.loading = true
      cryptoData.loading = true
      
      do {
        async let fiatAccountModels = self.getFiatAccounts()
        async let cryptoAccountModels = self.getCryptoAccounts()
        let fiatAccounts = try await fiatAccountModels
        let cryptoAccounts = try await cryptoAccountModels
        let accounts = fiatAccounts + cryptoAccounts
        
        let assets = fiatAccounts.map { AssetModel(account: $0) }
        getRewardCurrency(assets: assets)
        
        analyticsService.set(params: [PropertiesName.cashBalance.rawValue: fiatAccounts.first?.availableBalance ?? "0"])
        analyticsService.set(params: [PropertiesName.cryptoBalance.rawValue: cryptoAccounts.first?.availableBalance ?? "0"])
        
        self.fiatData.fiatAccount = fiatAccounts
        self.cryptoData.cryptoAccounts = cryptoAccounts
        
        self.accountDataManager.accountsSubject.send(accounts)
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
  
  func apiFetchACHInfo() {
    Task { @MainActor in
      defer { achInformationData.loading = false }
      achInformationData.loading = true
      do {
        let achModel = try await getACHInformation()
        achInformationData.model = achModel
      } catch {
        toastMessage?(error.userFriendlyMessage)
      }
    }
  }
  
  func getFiatAccounts() async throws -> [AccountModel] {
    let accounts = try await fiatAccountService.getAccounts()
    self.accountDataManager.addOrUpdateAccounts(accounts)
    return accounts
  }
  
  func getCryptoAccounts() async throws -> [AccountModel] {
    let accounts = try await cryptoAccountService.getAccounts()
    self.accountDataManager.addOrUpdateAccounts(accounts)
    return accounts
  }
  
  func getACHInformation() async throws -> ACHModel {
    let achResponse = try await nsGetACHInfoUseCase.execute(sessionID: accountDataManager.sessionID)
    let achInformation = ACHModel(
      accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
      routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
      accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
    )
    return achInformation
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
