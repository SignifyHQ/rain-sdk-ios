import Foundation
import RainDomain

public struct APIRainSecretCardInformation: Decodable, RainSecretCardInformationEntity {
  public let userId: String
  public let cardId: String
  public let rainPersonId: String
  public let rainCardId: String
  public let encryptedPan: APIEncryptedData
  public let encryptedCvc: APIEncryptedData
  
  public var encryptedPanEntity: EncryptedDataEntity {
    encryptedPan
  }
  
  public var encryptedCVCEntity: EncryptedDataEntity {
    encryptedCvc
  }
}

public struct APIEncryptedData: Decodable, EncryptedDataEntity {
  public let iv: String
  public let data: String
}
