import SolidDomain

public struct APISolidDebitCardTransferFeeResponse: Codable, SolidDebitCardTransferFeeResponseEntity {
  public var fee: Double
  public var amount: Double
  public var total: Double
}
