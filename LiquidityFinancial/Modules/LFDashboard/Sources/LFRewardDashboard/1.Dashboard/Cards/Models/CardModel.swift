import Foundation
import LFUtilities
import LFStyleGuide
import SwiftUI

struct CardModel: Identifiable, Hashable {
  let id: String
  let cardName: String
  let cardType: CardType
  let cardholderName: String?
  let expiryMonth: Int
  let expiryYear: Int
  let last4: String
  let popularBackgroundColor: String?
  let popularTextColor: String?
  var cardStatus: CardStatus
  
  var isDisplayLogo: Bool {
    // TODO: - We will check merchantLocked type later
    cardType == .physical
  }
  
  var backgroundColor: Color {
    if let popularBackgroundColor {
      return Color(hex: popularBackgroundColor)
    }
    switch cardType {
    case .virtual:
      return Colors.virtualCardBackground.swiftUIColor
    case .physical:
      return Colors.darkText.swiftUIColor
    }
  }
  
  var textColor: Color {
    if let popularTextColor {
      return Color(hex: popularTextColor)
    }
    switch cardType {
    case .virtual:
      return Colors.label.swiftUIColor
    case .physical:
      return Colors.contrast.swiftUIColor
    }
  }
  
  init(
    id: String,
    cardName: String,
    cardType: CardType,
    cardholderName: String?,
    expiryMonth: Int,
    expiryYear: Int,
    last4: String,
    popularBackgroundColor: String?,
    popularTextColor: String?,
    cardStatus: CardStatus
  ) {
    self.id = id
    self.cardName = cardName
    self.cardType = cardType
    self.cardholderName = cardholderName
    self.expiryMonth = expiryMonth
    self.expiryYear = expiryYear
    self.last4 = last4
    self.popularBackgroundColor = popularBackgroundColor
    self.popularTextColor = popularTextColor
    self.cardStatus = cardStatus
  }
}
