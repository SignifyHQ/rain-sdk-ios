import Foundation
import RainDomain

public struct APIRainSmartContract: Decodable {
  public let id: String
  public let chainId: Int
  public let address: String
  public let tokens: [String]
  
  public init(id: String, chainId: Int, address: String, tokens: [String]) {
    self.id = id
    self.chainId = chainId
    self.address = address
    self.tokens = tokens
  }
}

extension APIRainSmartContract: RainSmartContractEntity {}
