import Foundation
import NetspendDomain

public struct APIExternalCardFeeResponse: ExternalCardFeeEntity, Decodable {
  public let id: String
  public let amount: Double
  public var currency: String
  public var memo: String
}

extension APIExternalCardFeeResponse {
  
  public init(entity: ExternalCardFeeEntity) {
    self.id = entity.id
    self.amount = entity.amount
    self.currency = entity.currency
    self.memo = entity.memo
  }
  
}
