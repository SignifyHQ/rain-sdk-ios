import Foundation
import SolidDomain

public struct APISolidContact: Codable, SolidContactEntity {
  public var name: String?
  public var last4: String
  public var type: String
  public var solidContactId: String
  
  public var contactType: APISolidContactType? {
    APISolidContactType(rawValue: type)
  }
  
  public init(name: String?, last4: String, type: String, solidContactId: String) {
    self.name = name
    self.last4 = last4
    self.type = type
    self.solidContactId = solidContactId
  }
}

public enum APISolidContactType: String {
  
  case externalBank = "ACH"
  case externalCard = "DEBIT_CARD"
  
}
