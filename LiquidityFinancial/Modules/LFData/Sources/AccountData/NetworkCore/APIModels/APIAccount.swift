import Foundation

  // MARK: - WelcomeElement
public struct APIAccount: Codable {
  public let id: String
  public let externalAccountId: String?
  public let currency: String
  public let availableBalance: Double
  
}
