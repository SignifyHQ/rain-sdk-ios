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
  public var expirationEntity: ExternalCardExpirationEntity {
    expiration
  }
  
  public var expiration: ExternalCardExpiration
  public var nameOnCard: String
  public var nickname: String
  public var postalCode: String
  public let encryptedData: String
  
  public init(month: String, year: String, nameOnCard: String, nickname: String, postalCode: String, encryptedData: String) {
    self.expiration = ExternalCardExpiration(month: month, year: year)
    self.nameOnCard = nameOnCard
    self.nickname = nickname
    self.postalCode = postalCode
    self.encryptedData = encryptedData
  }
}
