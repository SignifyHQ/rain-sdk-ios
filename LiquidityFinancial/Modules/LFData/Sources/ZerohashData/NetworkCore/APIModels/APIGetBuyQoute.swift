import Foundation
import ZerohashDomain

public struct APIGetBuyQuote: Codable, GetBuyQuoteEntity {
  public var id, cryptoCurrency, quotedCurrency: String?
  public var amount, quantity, price: Double?
}
