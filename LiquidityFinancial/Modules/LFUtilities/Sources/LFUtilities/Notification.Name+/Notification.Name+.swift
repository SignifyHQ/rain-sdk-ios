import Foundation

public extension Notification.Name {
  static let selectedFundraisersSuccess = Notification.Name("com.liquidityfinancial.rewards.selectedFundraisersSuccess")
  static let selectedReward = Notification.Name("com.liquidityfinancial.rewards.selectedReward")
  
  static let moneyTransactionSuccess = Notification.Name("com.liquidityfinancial.funding.moneyTransactionSuccess")
  
  static let noLinkedCards = Notification.Name("com.liquidityfinancial.cards.noLinkedCards")
  
  static let refreshListCards = Notification.Name("com.liquidityfinancial.cards.refreshListCards")
  
  static let environmentChanage = Notification.Name("com.liquidityfinancial.environment.change")
  
  static let forceLogoutInAnyWhere = Notification.Name("com.liquidityfinancial.errorView.forceLogout")
  
  static let didReceiveRegistrationToken = Notification.Name("com.liquidityfinancial.didReceiveRegistrationToken")
  
  static let didLoginComplete = Notification.Name("com.liquidityfinancial.didLoginComplete")
  
  static let didCardsListChange = Notification.Name("com.liquidityfinancial.cards.didCardsListChange")
  
  static let didCardCreateSuccess = Notification.Name("com.liquidityfinancial.cards.didCardCreateSuccess")
  
  static let didBackupByPasswordSuccess = Notification.Name("com.liquidityfinancial.didBackupByPasswordSuccess")
}
