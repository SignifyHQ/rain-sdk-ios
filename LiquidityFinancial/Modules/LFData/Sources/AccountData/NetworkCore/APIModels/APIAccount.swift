import Foundation

  // MARK: - WelcomeElement
public struct APIAccount: Decodable {
  public let id: String
  public let externalAccountId: String?
  public let currency: String
  public let availableBalance: Double
  public let availableUsdBalance: Double
}
