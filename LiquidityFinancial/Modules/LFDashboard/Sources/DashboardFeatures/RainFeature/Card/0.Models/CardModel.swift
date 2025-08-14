import Foundation

struct CardModel: Identifiable, Hashable {
  let id: String
  let cardType: CardType
  let cardholderName: String?
  let expiryMonth: Int
  let expiryYear: Int
  let last4: String
  var cardStatus: CardStatus
  var tokenExperiences: [String]?
  
  var expiryTime: String {
    let expiryMonthFormated = expiryMonth < 10 ? "0\(expiryMonth)" : "\(expiryMonth)"
    let expiryYearFormated = "\(expiryYear)".suffix(2)
    return "\(expiryMonthFormated)/\(expiryYearFormated)"
  }
  
  init(
    id: String,
    cardType: CardType,
    cardholderName: String?,
    expiryMonth: Int,
    expiryYear: Int,
    last4: String,
    cardStatus: CardStatus,
    tokenExperiences: [String]? = nil
  ) {
    self.id = id
    self.cardType = cardType
    self.cardholderName = cardholderName
    self.expiryMonth = expiryMonth
    self.expiryYear = expiryYear
    self.last4 = last4
    self.cardStatus = cardStatus
    self.tokenExperiences = tokenExperiences
  }
  
  static let virtualDefault = CardModel(
    id: "",
    cardType: .virtual,
    cardholderName: nil,
    expiryMonth: 9,
    expiryYear: 2_023,
    last4: "1891",
    cardStatus: .active
  )
}
