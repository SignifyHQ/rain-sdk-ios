import Foundation
import LFServices
import NetspendSdk
import FraudForce
import LFUtilities

public protocol NetSpendRepositoryProtocol {
  func clientSessionInit() async throws -> NetSpendJwkToken
  func establishingSessionWithJWKSet(jwtToken: NetSpendJwkToken) async -> NetspendSdkUserSessionConnectionJWKSet!
  func establishPersonSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData
}

public class NetSpendRepository: NetSpendRepositoryProtocol {
  
  private let netSpendAPI: NetSpendAPIProtocol
  
  public init(netSpendAPI: NetSpendAPIProtocol) {
    self.netSpendAPI = netSpendAPI
  }
  
  public func clientSessionInit() async throws -> NetSpendJwkToken {
    return try await netSpendAPI.sessionInit()
  }
  
  public func establishingSessionWithJWKSet(jwtToken: NetSpendJwkToken) async -> NetspendSdkUserSessionConnectionJWKSet! {
    var session: NetspendSdkUserSessionConnectionJWKSet!
    do {
      session = try NetspendSdk.shared.createUserSessionConnection(jwkSet: jwtToken.rawData, iovationToken: FraudForce.blackbox())
      try await Task.sleep(seconds: 1) // We need to wait for sdk make sure the init session
    } catch {
      log.error(error)
    }
    return session
  }
  
  public func establishPersonSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData {
    return try await netSpendAPI.establishSession(deviceData: deviceData)
  }
}
