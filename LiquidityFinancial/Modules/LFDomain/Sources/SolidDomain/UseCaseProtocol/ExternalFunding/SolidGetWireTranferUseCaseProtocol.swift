import Foundation

public protocol SolidGetWireTranferUseCaseProtocol {
  func execute(accountId: String) async throws -> SolidWireTransferResponseEntity
}
