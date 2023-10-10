import LinkKit
import LFUtilities

class PlaidHelper {
  
  var onExit: (() -> Void)?
  var onSuccess: (() -> Void)?
  var onFailure: ((Error) -> Void)?
  var onLoading: ((Bool) -> Void)?

  func load(completion: @escaping (PlaidConfig) -> Void) {
    onLoading?(true)
    // TODO: Will need call API to get Plaid token from BE later
    let configuration = self.createLinkTokenConfiguration(token: "link-sandbox-af1a0311-da53-4636-b754-dd15cc058176")
    completion(.init(config: configuration))
  }

  private func createLinkTokenConfiguration(token: String) -> LinkTokenConfiguration {
    var configuration = LinkTokenConfiguration(
      token: token,
      onSuccess: { success in
        let publicToken = success.publicToken
        let plaidAccountId = success.metadata.accounts[0].id
        self.linkPlaidTokenApi(plaidToken: publicToken, plaidAccountId: plaidAccountId)
      }
    )

    configuration.onEvent = { event in
      log.info("Link Event: \(event)")
    }

    configuration.onExit = { [weak self] exit in
      if let error = exit.error {
        log.error(error.localizedDescription)
      } else {
        log.info("exit with \(exit.metadata)")
      }
      self?.onExit?()
    }
    return configuration
  }

  private func linkPlaidTokenApi(plaidToken: String, plaidAccountId: String) {
    onLoading?(true)
    // TODO: Will implement later when BE ready
    self.onSuccess?()
  }
}
