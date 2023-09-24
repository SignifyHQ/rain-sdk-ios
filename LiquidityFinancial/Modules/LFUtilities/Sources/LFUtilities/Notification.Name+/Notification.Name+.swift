import Foundation

public extension Notification.Name {
  static let selectedFundraisersSuccess = Notification.Name("com.liquidityfinancial.rewards.selectedFundraisersSuccess")
  
  static let moneyTransactionSuccess = Notification.Name("com.liquidityfinancial.funding.moneyTransactionSuccess")
  
  static let noLinkedCards = Notification.Name("com.liquidityfinancial.cards.noLinkedCards")
  
  static let refreshListCards = Notification.Name("com.liquidityfinancial.cards.refreshListCards")
}
