import Foundation

public protocol RegisterPortalUseCaseProtocol {
  func execute(portalToken: String) async throws
}
