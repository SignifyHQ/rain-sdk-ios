import Foundation
import OnboardingDomain

public struct APIZeroHashAccount: ZeroHashAccount, Decodable {
  public var externalAccountId: String?
  public var id: String?
}
