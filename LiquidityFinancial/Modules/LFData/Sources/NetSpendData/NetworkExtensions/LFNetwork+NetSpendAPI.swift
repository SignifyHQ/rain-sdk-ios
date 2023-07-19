import LFNetwork
import Foundation

extension LFNetwork: NetSpendAPIProtocol where R == NetSpendRoute {

  public func sessionInit() async throws -> NetSpendJwkToken {
    return try await request(NetSpendRoute.sessionInit, target: NetSpendJwkToken.self, decoder: .apiDecoder)
  }
  
  public func establishSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData {
    return try await request(NetSpendRoute.establishSession(deviceData), target: NetSpendSessionData.self, decoder: .apiDecoder)
  }
  
}
