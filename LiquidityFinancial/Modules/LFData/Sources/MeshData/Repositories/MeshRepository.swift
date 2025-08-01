import Foundation
import MeshDomain
import Services

public class MeshRepository: MeshRepositoryProtocol {
  private let meshAPI: MeshAPIProtocol
  private let meshService: MeshServiceProtocol
  
  public init(
    meshAPI: MeshAPIProtocol,
    meshService: MeshServiceProtocol
  ) {
    self.meshAPI = meshAPI
    self.meshService = meshService
  }
  
  public func launchMeshFlow(for methodId: String?) async throws {
    let response = try await meshAPI.getLinkToken(for: methodId)
    let accessToken = try await meshService.showMeshFlow(
      with: response.linkToken,
      accountId: response.accountId,
      accountName: response.accountName,
      accessToken: response.accessToken,
      brokerType: response.brokerType,
      brokerName: response.brokerName
    )
    
    if let accessToken,
    let accountToken = accessToken.accountTokens.first {
      let meshConnection = MeshConnection(
        brokerType: accessToken.brokerType,
        brokerName: accessToken.brokerName,
        brokerBase64Logo: accessToken.brokerBrandInfo.brokerLogo,
        accountId: accountToken.account.accountId,
        accountName: accountToken.account.accountName,
        accessToken: accountToken.accessToken,
        refreshToken: accountToken.refreshToken,
        expiresInSeconds: accessToken.expiresInSeconds,
        meshAccountId: accessToken.id,
        frontAccountId: accessToken.accountTokens.first?.account.frontAccountId,
        fund: accountToken.account.fund,
        cash: accountToken.account.cash
      )
      
      try await meshAPI.saveConnectedMethod(method: meshConnection)
    }
  }
  
  public func getConnectedMethods() async throws -> [any MeshPaymentMethodEntity] {
    try await meshAPI.getConnectedMethods()
  }
  
  public func deleteConnectedMethod(with methodId: String) async throws {
    try await meshAPI.deleteConnectedMethod(with: methodId)
  }
}
