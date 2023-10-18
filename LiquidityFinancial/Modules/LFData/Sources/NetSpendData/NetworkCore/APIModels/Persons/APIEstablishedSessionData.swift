import Foundation
import BankDomain

public struct APIEstablishedSessionData: Decodable, EstablishedSessionEntity {
  public let id: String
  public let encryptedData: String
}
