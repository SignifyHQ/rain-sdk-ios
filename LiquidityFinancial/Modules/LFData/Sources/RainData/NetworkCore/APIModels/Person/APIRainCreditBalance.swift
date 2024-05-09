import Foundation
import RainDomain

public struct APIRainCreditBalance: Decodable {
  public let userId: String
  public let currency: String
  public let creditLimit: Double
  public let pendingCharges: Double?
  public let postedCharges: Double?
  public let balanceDue: Double?
}

extension APIRainCreditBalance: RainCreditBalanceEntity {}
