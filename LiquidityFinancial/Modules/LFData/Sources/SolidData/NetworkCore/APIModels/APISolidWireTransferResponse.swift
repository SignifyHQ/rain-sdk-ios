import SolidDomain

public struct APISolidWireTransferResponse: Codable, SolidWireTransferResponseEntity {
  public var accountNumber: String
  public var routingNumber: String
}
