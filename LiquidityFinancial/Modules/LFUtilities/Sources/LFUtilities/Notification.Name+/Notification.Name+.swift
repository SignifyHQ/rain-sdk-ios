import Foundation

public extension Notification.Name {
  static let selectedFundraisersSuccess = Notification.Name("com.liquidityfinancial.rewards.selectedFundraisersSuccess")
  
  static let moneyTransactionSuccess = Notification.Name("com.liquidityfinancial.funding.moneyTransactionSuccess")
  
  static let noLinkedCards = Notification.Name("com.liquidityfinancial.cards.noLinkedCards")
  
  static let addedNewVirtualCard = Notification.Name("com.liquidityfinancial.cards.addedNewVirtualCard")
}
