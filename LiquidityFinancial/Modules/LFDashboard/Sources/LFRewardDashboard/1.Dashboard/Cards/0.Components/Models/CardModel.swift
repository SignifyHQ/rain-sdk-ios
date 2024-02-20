import Foundation
import LFUtilities
import LFStyleGuide
import SwiftUI

public struct CardModel: Identifiable, Hashable {
  public let id: String
  public var cardName: String
  public let cardType: CardType
  public let cardholderName: String?
  public let expiryMonth: Int
  public let expiryYear: Int
  public let last4: String
  public let popularBackgroundColor: String?
  public let popularTextColor: String?
  public var cardStatus: CardStatus
  
  public init(
    id: String,
    cardName: String?,
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
    self.cardName = cardName ?? .empty
    self.cardType = cardType
    self.cardholderName = cardholderName
    self.expiryMonth = expiryMonth
    self.expiryYear = expiryYear
    self.last4 = last4
    self.popularBackgroundColor = popularBackgroundColor
    self.popularTextColor = popularTextColor
    self.cardStatus = cardStatus
  }
  
  public static let `default` = CardModel(
    id: .empty,
    cardName: .empty,
    cardType: .virtual,
    cardholderName: nil,
    expiryMonth: 9,
    expiryYear: 2_023,
    last4: .empty,
    popularBackgroundColor: nil,
    popularTextColor: nil,
    cardStatus: .unactivated
  )
}

// MARK: - Computed Properties
extension CardModel {
  var displayCardName: String {
    cardName.isEmpty ? titleWithTheLastFourDigits : cardName
  }
  
  var isDisplayLogo: Bool {
    // TODO: - We will check merchantLocked type in phase 3
    cardType == .physical
  }
  
  var expirationDate: String {
    let expiryMonthFormated = expiryMonth < 10 ? "0\(expiryMonth)" : "\(expiryMonth)"
    let expiryYearFormated = "\(expiryYear)".suffix(2)
    return "\(expiryMonthFormated)/\(expiryYearFormated)"
  }
  
  var titleWithTheLastFourDigits: String {
    let cardName = cardName.isEmpty ? cardType.title : cardName
    return "\(cardName.prefix(10)) **** \(last4)"
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
}
