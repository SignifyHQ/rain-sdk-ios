import Foundation

// sourcery: AutoMockable
public protocol RainSecretCardInformationEntity {
  var userId: String { get }
  var cardId: String { get }
  var rainPersonId: String { get }
  var rainCardId: String { get }
  var processorCardId: String { get }
  var timeBasedSecret: String { get }
  var encryptedPanEntity: EncryptedDataEntity { get }
  var encryptedCVCEntity: EncryptedDataEntity { get }
}

public protocol EncryptedDataEntity {
  var iv: String { get }
  var data: String { get }
}
