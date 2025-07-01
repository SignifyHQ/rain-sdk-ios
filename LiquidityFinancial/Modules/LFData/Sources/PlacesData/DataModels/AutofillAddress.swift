import Foundation
import PlacesDomain

public struct AutofillAddress: AutofillAddressEntity {
  public var street: String?
  public var city: String?
  public var state: String?
  public var postalCode: String?
  public var country: String?
}
