import Foundation
import PortalSwift

public protocol RecoverWalletUseCaseProtocol {
  func execute(backupMethod: BackupMethods, password: String?) async throws
}
