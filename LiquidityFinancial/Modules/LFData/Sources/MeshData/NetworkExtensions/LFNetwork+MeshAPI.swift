import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: MeshAPIProtocol where R == MeshRoute {
  public func getLinkToken(for methodId: String?) async throws -> MeshLinkToken {
    guard let methodId else {
      let linkToken = try await request(
        MeshRoute.getLinkToken,
        target: MeshLinkToken.self,
        failure: LFErrorObject.self,
        decoder: .apiDecoder
      )
      
      return linkToken
    }
    
    return try await request(
      MeshRoute.getLinkTokenFor(methodId: methodId),
      target: MeshLinkToken.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getConnectedMethods() async throws -> [MeshPaymentMethod] {
    try await request(
      MeshRoute.getConnectedMethods,
      target: [MeshPaymentMethod].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func saveConnectedMethod(method: MeshConnection) async throws {
    try await requestNoResponse(
      MeshRoute.saveConnectedMethod(request: method),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func deleteConnectedMethod(with methodId: String) async throws {
    try await requestNoResponse(
      MeshRoute.deleteConnectedMethod(methodId: methodId),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
