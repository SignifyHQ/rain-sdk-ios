import MeaPushProvisioning
import PassKit
import os

@available(iOS 14.0, *)
class IssuerExtensionHandler: PKIssuerProvisioningExtensionHandler {
  
  let logger = Logger(subsystem: "com.rain-liquidity.avalanche.IssuerNonUIExtension", category: "AvalancheWalletExtension")
  
  override func status(completion: @escaping (PKIssuerProvisioningExtensionStatus) -> Void) {
    // Determines if there is a pass available and if adding the pass requires authentication.
    // The completion handler takes a parameter status of type PKIssuerProvisioningExtensionStatus that indicates
    // whether there are any payment cards available to add as Wallet passes.
    
    // PKIssuerProvisioningExtensionStatus has the following properties:
    // requiresAuthentication: Bool - authorization required before passes can be added.
    // passEntriesAvailable: Bool - passes will be available to add (at least one).
    // remotePassEntriesAvailable: Bool - passes will be available to add on the remote device (at least one).
    
    // The handler should be invoked within 100ms. The extension is not displayed to the user in Wallet if this criteria is not met.
    let status = PKIssuerProvisioningExtensionStatus()
    status.requiresAuthentication = false
    status.passEntriesAvailable = true
    status.remotePassEntriesAvailable = false
    
    completion(status)
  }
  
  override func passEntries(completion: @escaping ([PKIssuerProvisioningExtensionPassEntry]) -> Void) {
    // Finds the list of passes available to add to an iPhone.
    // The completion handler takes a parameter entries of type Array<PKIssuerProvisioningExtensionPassEntry> representing
    // the passes that are available to add to Wallet.
    
    // Call MeaPushProvisioning.initializeOemTokenization(cardParams, completionHandler: { (data: MppInitializeOemTokenizationResponseData, error: Error?) in ... }) and initialize PKIssuerProvisioningExtensionPaymentPassEntry for each card that can be added to Wallet and add to the array.
    // Use addPaymentPassRequestConfiguration of MppInitializeOemTokenizationResponseData object to set addRequestConfiguration.
    
    // PKIssuerProvisioningExtensionPaymentPassEntry has the following properties:
    // art: CGImage - image representing the card displayed to the user. The image must have square corners and should not include personally identifiable information like user name or account number.
    // title: String - a name for the pass that the system displays to the user when they add or select the card.
    // identifier: String - an internal value the issuer uses to identify the card. This identifier must be stable.
    // addRequestConfiguration: PKAddPaymentPassRequestConfiguration - the configuration data used for setting up and displaying a view controller that lets the user add a payment pass.
    
    // Do not return payment passes that are already present in the user’s pass library.
    // The handler should be invoked within 20 seconds or will be treated as a failure and the attempt halted.
    
    let cardParameters = MppCardDataParameters(cardId: "545504292", cardSecret: "001#76058563")
    MeaPushProvisioning.initializeOemTokenization(cardParameters) { responseData, error in
      self.logger.info("initializeOemTokenization: start the initialization")
      
      self.logger.info("initializeOemTokenization: responseData -> \(error, privacy: .public)")
      
      guard let configuration = responseData?.addPaymentPassRequestConfiguration,
            let art = UIImage(named: "availableCard")?.cgImage
      else {
        return
      }
      
      self.logger.info("initializeOemTokenization: configuration received")
      
      let passEntries = [
        PKIssuerProvisioningExtensionPaymentPassEntry(
          identifier: "545504292",
          title: "Card",
          art: art,
          addRequestConfiguration: configuration
        )!
      ]
      
      completion(passEntries)
    }
  }
  
  override func remotePassEntries(completion: @escaping ([PKIssuerProvisioningExtensionPassEntry]) -> Void) {
    // Finds the list of passes available to add to an Apple Watch.
    // The completion handler takes a parameter entries of type Array<PKIssuerProvisioningExtensionPassEntry> representing
    // the passes that are available to add to Apple Watch.
    
    // Call MeaPushProvisioning.initializeOemTokenization(cardParams, completionHandler: { (data: MppInitializeOemTokenizationResponseData, error: Error?) in ... }) and initialize PKIssuerProvisioningExtensionPaymentPassEntry for each card that can be added to Wallet and add to the array.
    // Use addPaymentPassRequestConfiguration of MppInitializeOemTokenizationResponseData object to set addRequestConfiguration.
    
    // PKIssuerProvisioningExtensionPaymentPassEntry has the following properties:
    // art: CGImage - image representing the card displayed to the user. The image must have square corners and should not include personally identifiable information like user name or account number.
    // title: String - a name for the pass that the system displays to the user when they add or select the card.
    // identifier: String - an internal value the issuer uses to identify the card. This identifier must be stable.
    // addRequestConfiguration: PKAddPaymentPassRequestConfiguration - the configuration data used for setting up and displaying a view controller that lets the user add a payment pass.
    
    // Do not return payment passes that are already present in the user’s pass library.
    // The handler should be invoked within 20 seconds or will be treated as a failure and the attempt halted.
  }
  
  override func generateAddPaymentPassRequestForPassEntryWithIdentifier(
    _ identifier: String,
    configuration: PKAddPaymentPassRequestConfiguration,
    certificateChain certificates: [Data],
    nonce: Data,
    nonceSignature: Data,
    completionHandler completion: @escaping (PKAddPaymentPassRequest?) -> Void) {
      
      // Creates an object with the data the system needs to add a card to Apple Pay.
      
      // identifier: String - an internal value the issuer uses to identify the card.
      // configuration: PKAddPaymentPassRequestConfiguration - the configuration the system uses to add a secure pass. This configuration is prepared in methods passEntriesWithCompletion: and remotePassEntriesWithCompletion:.
      // certificates, nonce, nonceSignature - parameters are generated by Apple Pay identically to PKAddPaymentPassViewControllerDelegate methods.
      
      // The completion handler is called by the system for the data needed to add a card to Apple Pay.
      // This handler takes a parameter request of type PKAddPaymentPassRequestConfiguration that contains the card data the system needs to add a card to Apple Pay.
      
      // Call MeaPushProvisioning.completeOemTokenization(tokenizationData, completionHandler: { (data: MppCompleteOemTokenizationResponseData, error: Error?) in ... }), and
      // use addPaymentPassRequest of MppCompleteOemTokenizationResponseData to set request in completion handler.
      
      // The continuation handler must be called within 20 seconds or an error is displayed.
      // Subsequent to timeout, the continuation handler is invalid and invocations is ignored.
    }
}
