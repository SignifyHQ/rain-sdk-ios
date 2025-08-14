import Foundation

public protocol SavePopupShownUseCaseProtocol {
  func execute(campaign: String) async throws
}
