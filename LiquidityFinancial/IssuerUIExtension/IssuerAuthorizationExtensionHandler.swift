import os
import PassKit
import UIKit

@available(iOS 14.0, *)
class IssuerAuthorizationExtensionHandler: UIViewController,
                                           PKIssuerProvisioningExtensionAuthorizationProviding {
  var completionHandler: ((PKIssuerProvisioningExtensionAuthorizationResult) -> Void)?
  
  let logger = Logger(subsystem: "com.rain-liquidity.avalanche.IssuerUIExtension", category: "AvalancheWalletExtension")
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Set up view and authenticate user.
    logger.info("IssuerAuthorizationExtensionHandler viewDidLoad")
  }
  
  func authenticateUser() {
    let userAuthenticated = true // User authentication outcome.
    
    let authorizationResult: PKIssuerProvisioningExtensionAuthorizationResult = userAuthenticated ? .authorized : .canceled
    
    self.completionHandler?(authorizationResult)
  }
}
