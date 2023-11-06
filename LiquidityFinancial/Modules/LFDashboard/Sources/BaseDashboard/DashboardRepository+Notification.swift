import Foundation
import Services
import LFUtilities
import UIKit
import DevicesDomain

public extension DashboardRepository {
  func checkNotificationsStatus(completion: @escaping (Bool) -> Void) {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        completion(status == .authorized)
      } catch {
        completion(false)
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
        let response = try await deviceRegisterUseCase.execute(deviceId: LFUtilities.deviceId, token: token)
        if response.success {
          UserDefaults.lastestFCMToken = token
        }
      } catch {
        log.error(error)
      }
    }
  }

}
