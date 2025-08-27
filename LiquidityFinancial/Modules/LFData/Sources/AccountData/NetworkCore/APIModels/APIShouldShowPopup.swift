import Foundation
import AccountDomain

public struct APIShouldShowPopup: Decodable, ShouldShowPopupEntity {
  public var shouldShow: Bool
}
