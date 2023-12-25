import Foundation
import ZerohashDomain

public struct APIGetSellQuote: Codable, GetSellQuoteEntity {
  public var id, cryptoCurrency, quotedCurrency: String?
  public var amount, quantity, price: Double?
}
