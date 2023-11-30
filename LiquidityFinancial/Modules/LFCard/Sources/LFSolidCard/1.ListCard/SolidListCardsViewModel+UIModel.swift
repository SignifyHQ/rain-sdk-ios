import Foundation
import LFUtilities
import LFLocalizable
import SolidDomain
import SolidData

extension SolidListCardsViewModel {
  struct CardLimitUIModel {
    var solidCardID: String
    var limitAmount: Double
    var limitInterval: String
    var availableLimit: Double
    var platformPerTransactionLimit: Double
    
    init(entity: SolidCardLimitsEntity) {
      self.solidCardID = entity.solidCardId
      self.limitAmount = entity.limitAmount ?? 0
      self.limitInterval = entity.limitInterval ?? ""
      self.availableLimit = entity.availableLimit ?? 0
      self.platformPerTransactionLimit = entity.platformPerTransactionLimit ?? 0
    }
    
    var limitAmountValue: String {
      limitAmount == 0 ? "-" : String(limitAmount)
    }
    
    var availableLimitValue: String {
      availableLimit == 0 ? "-" : String(availableLimit)
    }
    
    var platformPerTransactionLimitValue: String {
      platformPerTransactionLimit == 0 ? "-" : String(platformPerTransactionLimit)
    }
    
    var spendLimits: String {
      if limitInterval == "monthly", limitAmountValue != "-" {
        let limitAmount = limitAmountValue.asDouble ?? 0
        return LFUtilities.getCurrencyForAmount(currency: "$", amount: limitAmount, isDecimalRequired: true)
      }
      return "-"
    }
    
    var availableLimits: String {
      if availableLimitValue != "-" {
        return "$" + (availableLimitValue)
      }
      return "-"
    }
    
    var transactionLimits: String {
      if platformPerTransactionLimitValue != "-" {
        let limitAmount = platformPerTransactionLimitValue.asDouble ?? 0
        return LFUtilities.getCurrencyForAmount(currency: "$", amount: limitAmount, isDecimalRequired: true)
      }
      let amount = "10000".asDouble ?? 0
      return LFUtilities.getCurrencyForAmount(currency: "$", amount: amount, isDecimalRequired: true)
    }
  }
}
