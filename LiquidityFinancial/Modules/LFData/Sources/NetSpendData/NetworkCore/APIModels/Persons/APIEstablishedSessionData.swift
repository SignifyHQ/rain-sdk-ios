import Foundation
import NetspendDomain

public struct APIEstablishedSessionData: Decodable, EstablishedSessionEntity {
  public let id: String
  public let encryptedData: String
}
