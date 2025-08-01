import Combine
import Factory
import Foundation
import LinkKit
@preconcurrency import LinkSDK
import LFUtilities

public class MeshService: MeshServiceProtocol {
  init() {}
}

// MARK: - Public Functions
public extension MeshService {
  func showMeshFlow(
    with linkToken: String,
    accountId: String?,
    accountName: String?,
    accessToken: String?,
    brokerType: String?,
    brokerName: String?
  ) async throws -> AccessTokenPayload? {
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<AccessTokenPayload?, Error>) in
      var hasResumed = false
      
      func safelyResume(
        with result: Result<AccessTokenPayload?, Error>
      ) {
        guard !hasResumed else { return }
        hasResumed = true
        
        switch result {
        case .success(let payload):
          continuation.resume(returning: payload)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
      
      var settings: LinkSettings?
      
      if let accountId,
         let accountName,
         let accessToken,
         let brokerType,
         let brokerName,
         let integrationAccessToken = getIntegrationAccessToken(
          accountId: accountId,
          accountName: accountName,
          accessToken: accessToken,
          brokerType: brokerType,
          brokerName: brokerName
        ) {
        
        settings = LinkSettings(accessTokens: [integrationAccessToken])
      }

      let meshConfiguraion = LinkConfiguration(
        linkToken: linkToken,
        settings: settings
      ) { linkPayload in
        if case let .accessToken(token) = linkPayload {
          log.debug("Mesh Connect. Successfully connected to \(token.brokerName). Id: \(token.id)")
          safelyResume(with: .success(token))
        }
      } onTransferFinished: { transferFinishedPayload in
        log.debug("Mesh Connect. Transfer finished")
      } onEvent: { event in
        log.debug("Mesh Connect. New event: \(event ?? [:])")
      } onExit: {
        log.debug("Mesh Connect. Did Exit")
        safelyResume(with: .success(nil))
      }
      
      let result = meshConfiguraion.createHandler()
      switch result {
      case .failure(let errorMessage):
        log.error("Mesh Connect. Error launching Mesh flow: \(errorMessage)")
        safelyResume(with: .failure(LFMeshError.customError(message: errorMessage)))
      case .success(let handler):
        DispatchQueue.main.async {
          if let topViewController = LFUtilities.visibleViewController {
            log.debug("Mesh Connect. Successfully presented Mesh flow")
            handler.present(in: topViewController)
          } else {
            log.error("Mesh Connect. Error launching Mesh flow: unknown")
            safelyResume(with: .failure(LFMeshError.customError(message: "Unknown error presenting Mesh flow.")))
          }
        }
      @unknown default:
        log.error("Mesh Connect. Error launching Mesh flow: unknown")
        safelyResume(with: .failure(LFMeshError.unknown))
      }
    }
  }
}

private extension MeshService {
  func getIntegrationAccessToken(
    accountId: String,
    accountName: String,
    accessToken: String,
    brokerType: String,
    brokerName: String
  ) -> IntegrationAccessToken? {
    let payload: [String: String] = [
      "accountId": accountId,
      "accountName": accountName,
      "accessToken": accessToken,
      "brokerType": brokerType,
      "brokerName": brokerName
    ]
    
    guard let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: [])
    else {
      return nil
    }
    
    let token = try? JSONDecoder().decode(IntegrationAccessToken.self, from: jsonData)
    return token
  }
}
