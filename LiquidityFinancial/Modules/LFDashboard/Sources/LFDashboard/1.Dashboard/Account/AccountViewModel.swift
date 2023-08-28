import Combine
import Foundation
import UIKit
import LFUtilities
import Factory
import NetSpendData
import NetSpendDomain
import NetspendSdk
import LFBank

@MainActor
class AccountViewModel: ObservableObject {
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.devicesRepository) var devicesRepository
  
  @Published var navigation: Navigation?
  @Published var isDisableView: Bool = false
  @Published var isLoadingACH: Bool = false
  @Published var isLoading: Bool = false
  @Published var netspendController: NetspendSdkViewController?
  @Published var toastMessage: String?
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var notificationsEnabled = false
  
  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  init() {
    getACHInfo()
    checkNotificationsStatus()
  }
}

// MARK: - View Helpers
extension AccountViewModel {
  func selectedAddOption(navigation: Navigation) {
    self.navigation = navigation
  }
  
  func connectedAccountsTapped() {
    navigation = .connectedAccounts
  }
  
  func bankStatementTapped() {
    navigation = .bankStatement
  }
  
  func checkNotificationsStatus() {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        self.notificationsEnabled = status == .authorized
      } catch {
        log.error(error.localizedDescription)
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
        if token == UserDefaults.lastestFCMToken {
          return
        }
        let response = try await devicesRepository.register(deviceId: LFUtility.deviceId, token: token)
        if response.success {
          UserDefaults.lastestFCMToken = token
        }
      } catch {
        log.error(error)
      }
    }
  }
}

// MARK: - API
extension AccountViewModel {
  func getATMAuthorizationCode() {
    Task {
      defer {
        isLoading = false
        isDisableView = false
      }
      isLoading = true
      isDisableView = true
      do {
        let sessionID = accountDataManager.sessionID
        let code = try await netspendRepository.getAuthorizationCode(sessionId: sessionID)
        navigation = .atmLocation(code.authorizationCode)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func getListConnectedAccount() {
    Task {
      do {
        let sessionID = accountDataManager.sessionID
        let response = try await externalFundingRepository.getLinkedAccount(sessionId: sessionID)
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
        log.error(error)
      }
    }
  }
  
  func getACHInfo() {
    isLoadingACH = true
    Task {
      do {
        let achResponse = try await externalFundingRepository.getACHInfo(sessionID: accountDataManager.sessionID)
        achInformation = ACHModel(
          accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
          routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
          accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
        )
        isLoadingACH = false
      } catch {
        isLoadingACH = false
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - Types
extension AccountViewModel {
  enum Navigation {
    case debugMenu
    case atmLocation(String)
    case connectedAccounts
    case bankStatement
  }
}

extension AccountViewModel {
  
  func onAppear() {
    getListConnectedAccount()
  }
}
