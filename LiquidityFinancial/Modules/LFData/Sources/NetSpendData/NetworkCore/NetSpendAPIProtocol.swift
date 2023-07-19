import Foundation

public protocol NetSpendAPIProtocol {
  func sessionInit() async throws -> NetSpendJwkToken
  func establishSession(deviceData: EstablishSessionParameters) async throws -> NetSpendSessionData
}
