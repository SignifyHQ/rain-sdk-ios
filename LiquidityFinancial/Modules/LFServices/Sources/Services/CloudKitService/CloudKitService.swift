import Foundation
import Combine
import LFUtilities
import Factory
import CloudKit

public class CloudKitService: CloudKitServiceProtocol {
  private let container = CKContainer.default()
  private(set) var accountStatus: CKAccountStatus = .couldNotDetermine

  public var isICloudAccountAvailable = false
  
  public init() {
    requestAccountStatus()
    setupNotificationHandling()
  }
}

// MARK: - Private Functions
private extension CloudKitService {
  func requestAccountStatus() {
    container.accountStatus { [weak self] (accountStatus, error) in
      guard let self, error == nil else {
        return
      }
      
      self.accountStatus = accountStatus
      self.isICloudAccountAvailable = self.accountStatus == .available
    }
  }
  
  func setupNotificationHandling() {
    NotificationCenter.default.addObserver(
      forName: Notification.Name.CKAccountChanged,
      object: nil,
      queue: .main
    ) { _ in
      DispatchQueue.main.async {
        self.requestAccountStatus()
      }
    }
  }
}
