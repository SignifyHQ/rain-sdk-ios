import Foundation

public struct DebitCardModel: Codable {
  let expiryMonth: String
  let expiryYear: String
  let cardNumber: String
  let cvv: String
  let address: VGSAddressModel
  
  public init(
    expiryMonth: String,
    expiryYear: String,
    cardNumber: String,
    cvv: String,
    address: VGSAddressModel
  ) {
    self.expiryMonth = expiryMonth
    self.expiryYear = expiryYear
    self.cardNumber = cardNumber
    self.cvv = cvv
    self.address = address
  }
}

struct VGSDebitCardModel: Codable {
  let debitCard: DebitCardModel
}
