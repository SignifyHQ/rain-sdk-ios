import Combine
import Foundation
import SwiftUI
import UIKit
import LFUtilities
import Factory
import AccountDomain
import AccountData
import GeneralFeature
import RainFeature
import LFLocalizable
import LFStyleGuide
import Services
import DevicesDomain

@MainActor
class MyAccountViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var navigation: Navigation?
  @Published var isShowingLogoutPopup: Bool = false
  @Published var isShowingDeleteAccountPopup: Bool = false
  @Published var notificationsEnabled = false
  @Published var isFidesmoFlowPresented = false
  @Published var toastData: ToastData?
  @Published var isLoading: Bool = false
  @Published var popup: Popup?
  @Published var isWaitingEnableNotification: Bool = false // In case the user opens Settings and come back
  
  lazy var deviceDeregisterUseCase: DeviceDeregisterUseCaseProtocol = {
    DeviceDeregisterUseCase(repository: devicesRepository)
  }()
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
  }()
  
  private var cancellable: Set<AnyCancellable> = []
  
  let dashboardRepository: DashboardRepository
  init(dashboardRepository: DashboardRepository) {
    self.dashboardRepository = dashboardRepository

    self.notificationsEnabled = UserDefaults.enabledNotificationSetting
    handleForceLogoutInErrorView()
    checkNotificationsStatus()
    observeNotificationChanged()
  }
}

// MARK: Observable
extension MyAccountViewModel {
  private func handleForceLogoutInErrorView() {
    NotificationCenter.default.publisher(for: .forceLogoutInAnyWhere)
      .sink { [weak self] _ in
        guard let self else { return }
        self.logout(animated: false)
      }
      .store(in: &cancellable)
  }
  
  private func observeNotificationChanged() {
    $notificationsEnabled
      .scan((old: false, new: false)) { previous, current in
        (old: previous.new, new: current)
      }
      .sink { [weak self] oldValue, newValue in
        guard newValue != oldValue else { return }
        
        if newValue {
          self?.checkShouldRequestNotification()
        } else {
          UserDefaults.enabledNotificationSetting = false
          self?.deregisterFCMToken()
        }
      }
      .store(in: &cancellable)
  }
  
  func checkNotificationsStatus() {
    dashboardRepository.checkNotificationsStatus { @MainActor [weak self] status in
      if !status {
        UserDefaults.enabledNotificationSetting = false
      } else if self?.isWaitingEnableNotification == true {
        UserDefaults.enabledNotificationSetting = true
      }
      
      self?.isWaitingEnableNotification = false
      self?.notificationsEnabled = UserDefaults.enabledNotificationSetting
    }
  }
}

// MARK: Handle Interactions
extension MyAccountViewModel {
  func deleteAccount() {
    analyticsService.track(event: AnalyticsEvent(name: .deleteAccount))
    isShowingDeleteAccountPopup = false
    logout()
  }
  
  func logout(animated: Bool = true) {
    analyticsService.track(event: AnalyticsEvent(name: .loggedOut))
    isShowingLogoutPopup = false
    Task {
      do {
        if animated {
          isLoading = true
        }
        
        defer {
          isLoading = false
        }
        
        async let logoutEntity = accountRepository.logout()
        
        // Use loading state of the logout function
        deregisterFCMToken(animated: false)
        
        let logout = try await logoutEntity
        
        authorizationManager.clearToken()
        accountDataManager.clearUserSession()
        authorizationManager.forcedLogout()
        customerSupportService.pushEventLogout()
        pushNotificationService.signOut()
        featureFlagManager.signOut()
        
        log.debug(logout)
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func checkShouldRequestNotification() {
    Task { @MainActor in
      do {
        let initialStatus = try await pushNotificationService.notificationSettingStatus()
        
        switch initialStatus {
        case .authorized:
          registerFCMToken()
          UserDefaults.enabledNotificationSetting = true
        case .notDetermined:
          let granted = try await pushNotificationService.requestPermission()
          if granted {
            registerFCMToken()
          } else {
            // Set false again if the user denied
            self.notificationsEnabled = false
          }
          
          UserDefaults.enabledNotificationSetting = granted
        default:
          UserDefaults.enabledNotificationSetting = false
          // Set false again if the user denied
          self.notificationsEnabled = false
          self.popup = .openSettings
        }
        
      } catch {
        log.error(error)
      }
    }
  }
  
  func registerFCMToken() {
    Task {
      do {
        defer {
          isLoading = false
        }
        isLoading = true
        
        let token = try await pushNotificationService.fcmToken()
        
        let response = try await deviceRegisterUseCase.execute(
          deviceId: LFUtilities.deviceId,
          token: token
        )
        if response.success {
          UserDefaults.lastestFCMToken = token
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func deregisterFCMToken(animated: Bool = true) {
    if UserDefaults.lastestFCMToken.isEmpty {
      return
    }
    
    Task { @MainActor in
      do {
        if animated {
          defer {
            isLoading = false
          }
          
          isLoading = true
        }
        
        let response = try await deviceDeregisterUseCase.execute(
          deviceId: LFUtilities.deviceId,
          token: UserDefaults.lastestFCMToken
        )
        if response.success {
          UserDefaults.lastestFCMToken = .empty
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
}

// MARK: - View Helpers
extension MyAccountViewModel {
  func onCellTap(item: MyAccountItem) {
    switch item {
    case .personalProfile:
      navigation = .profile
    case .walletBackup:
      navigation = .backup
    case .savedWalletAddresses:
      navigation = .savedWalletAddresses
    case .activateLimitedEditionCard:
      isFidesmoFlowPresented = true
    default: break
    }
  }
  
  func openSettings() {
    if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
       UIApplication.shared.canOpenURL(settingsUrl) {
      UIApplication.shared.open(settingsUrl)
    }
  }
}

// MARK: - Enums
extension MyAccountViewModel {
  enum Navigation {
    case profile
    case backup
    case savedWalletAddresses
  }
  
  enum Popup: Identifiable {
    var id: Self { self }
    
    case openSettings
  }
  
  enum MyAccountItem: Identifiable, CaseIterable {
    case personalProfile
    case walletBackup
    case savedWalletAddresses
    case activateLimitedEditionCard
    case enableNotifications
    
    var id: Self { self }
    
    var title: String {
      switch self {
      case .personalProfile:
        L10N.Common.MyAccount.Item.PersonalProfile.title
      case .walletBackup:
        L10N.Common.MyAccount.Item.WalletBackup.title
      case .savedWalletAddresses:
        L10N.Common.MyAccount.Item.SavedWalletAddresses.title
      case .activateLimitedEditionCard:
        L10N.Common.MyAccount.Item.ActivateLimitedEditionCard.title
      case .enableNotifications:
        L10N.Common.MyAccount.Item.EnableNotifications.title
      }
    }
    
    var icon: Image {
      switch self {
      case .personalProfile:
        GenImages.Images.icoProfile.swiftUIImage
      case .walletBackup:
        GenImages.Images.icoWalletBackup.swiftUIImage
      case .savedWalletAddresses:
        GenImages.Images.icoSavedAddresses.swiftUIImage
      case .activateLimitedEditionCard:
        GenImages.Images.icoEditionCard.swiftUIImage
      case .enableNotifications:
        GenImages.Images.icoNotificationBell.swiftUIImage
      }
    }
    
    var type: CellType {
      switch self {
      case .enableNotifications:
          .switchCell
      default:
          .actionCell
      }
    }
  }
  
  enum CellType: CaseIterable {
    case actionCell
    case switchCell
  }
}
