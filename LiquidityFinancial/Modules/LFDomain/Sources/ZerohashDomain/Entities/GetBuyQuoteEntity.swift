import Foundation

public protocol GetBuyQuoteEntity {
  var id: String? { get set }
  var cryptoCurrency: String? { get set }
  var quotedCurrency: String? { get set }
  var amount: Double? { get set }
  var quantity: Double? { get set }
  var price: Double? { get set }
}
