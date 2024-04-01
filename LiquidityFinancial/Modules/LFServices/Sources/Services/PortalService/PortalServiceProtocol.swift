import Foundation
import Combine
import PortalSwift

// MARK: - PortalServiceProtocol

public protocol PortalServiceProtocol {
  func registerPortal(sessionToken: String, alchemyAPIKey: String) -> AnyPublisher<Bool, Error>
  func createWallet() -> AnyPublisher<String, Error>
  func backup(
    backupMethod: BackupMethods.RawValue,
    clientID: String,
    backupConfigs: BackupConfigs?
  ) -> AnyPublisher<String, Error>
}
