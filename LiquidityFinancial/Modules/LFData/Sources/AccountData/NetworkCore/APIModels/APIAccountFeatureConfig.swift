import Foundation
import AccountDomain

public struct APIAccountFeatureConfig: Decodable, AccountFeatureConfigEntity {
  public let config: String?
}
