import Foundation

// sourcery: AutoMockable
public protocol RainSmartContractEntity {
  var id: String { get }
  var chainId: Int { get }
  var address: String { get }
  var tokens: [String] { get }
  
  init(id: String, chainId: Int, address: String, tokens: [String])
}
