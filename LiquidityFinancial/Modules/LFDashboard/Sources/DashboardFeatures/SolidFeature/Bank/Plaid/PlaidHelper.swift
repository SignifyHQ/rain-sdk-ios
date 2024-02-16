import LinkKit
import LFUtilities

class PlaidHelper {
  
  typealias PlaidResponse = (publicToken: String, plaidAccountIds: [String])

  static func createLinkTokenConfiguration(token: String, onCreated: ((LinkTokenConfiguration) -> Void)) async throws -> PlaidResponse {
    return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<PlaidResponse, Error>) in
      
      var configuration = LinkTokenConfiguration(
        token: token,
        onSuccess: { success in
          let publicToken = success.publicToken
          let plaidAccountIds = success.metadata.accounts.compactMap({ $0.id })
          guard plaidAccountIds.isNotEmpty else {
            continuation.resume(throwing: LiquidityError.invalidData)
            return
          }
          continuation.resume(returning: (publicToken: publicToken, plaidAccountIds: plaidAccountIds))
        }
      )
      
      configuration.onExit = { exit in
        if let error = exit.error {
          continuation.resume(throwing: error)
        } else {
          continuation.resume(throwing: LiquidityError.userCancelled)
        }
      }
      
      onCreated(configuration)
    })
  }
}
