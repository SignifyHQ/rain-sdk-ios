import SolidDomain

public struct APISolidDebitCardToken: Decodable, SolidDebitCardTokenEntity {
  public var linkToken: String
  public var solidContactId: String
}
