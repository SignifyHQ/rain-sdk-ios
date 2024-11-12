import Foundation
import RainDomain

public struct APIRainCollateralContract: Decodable {
  public let contractId: String
  public let network: String
  public let chainId: Int
  public let address: String
  public let controllerAddress: String?
  public let tokens: [APIRainToken]
  
  public var creditLimit: Double {
    tokens.reduce(into: 0) { partialResult, token in
      partialResult += token.availableUsdBalance
    }
  }
}

public struct APIRainToken: Decodable, RainTokenEntity {
  public let address: String
  public let name: String?
  public let symbol: String?
  public let decimals: Double?
  public let logo: String?
  public let balance: Double
  public let exchangeRate: Double
  public let advanceRate: Double
  
  public init(
    address: String,
    name: String?,
    symbol: String?,
    decimals: Double?,
    logo: String?,
    balance: Double,
    exchangeRate: Double,
    advanceRate: Double
  ) {
    self.address = address
    self.name = name
    self.symbol = symbol
    self.decimals = decimals
    self.logo = logo
    self.balance = balance
    self.exchangeRate = exchangeRate
    self.advanceRate = advanceRate
  }
  
  public var availableUsdBalance: Double {
    balance * exchangeRate * advanceRate / 100
  }
}

extension APIRainCollateralContract: RainCollateralContractEntity {
  public var tokensEntity: [RainTokenEntity] {
    tokens
  }
}
