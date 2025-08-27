import Foundation

public protocol ShouldShowPopupUseCaseProtocol {
  func execute(campaign: String) async throws -> ShouldShowPopupEntity
}
