import Foundation
import DataUtilities
import ExternalFundingDomain

public struct ExternalCardExpiration: ExternalCardExpirationEntity {
  public var month: String
  public var year: String
  
  public init(month: String, year: String) {
    self.month = month
    self.year = year
  }
}

public struct ExternalCardParameters: Parameterable, ExternalCardParametersEntity {
  public var expiration: ExternalCardExpirationEntity {
    return ExternalCardExpiration(month: month, year: year)
  }
  
  public var month: String
  public var year: String
  public var nameOnCard: String
  public var nickname: String
  public var postalCode: String
  public let encryptedData: String
  
  public init(month: String, year: String, nameOnCard: String, nickname: String, postalCode: String, encryptedData: String) {
    self.month = month
    self.year = year
    self.nameOnCard = nameOnCard
    self.nickname = nickname
    self.postalCode = postalCode
    self.encryptedData = encryptedData
  }
}
