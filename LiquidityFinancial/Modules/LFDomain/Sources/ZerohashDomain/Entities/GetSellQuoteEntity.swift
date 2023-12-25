import Foundation

public protocol GetSellQuoteEntity {
  var id: String? { get set }
  var cryptoCurrency: String? { get set }
  var quotedCurrency: String? { get set }
  var amount: Double? { get set }
  var quantity: Double? { get set }
  var price: Double? { get set }
}
