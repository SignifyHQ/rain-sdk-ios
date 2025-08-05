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
    
    Task {
      var passEntries: [PKIssuerProvisioningExtensionPassEntry] = []
      
      self.logger.info("WalletExtension: Starting card retrieval")
      
      guard let cards = await getActiveCards(),
            !cards.isEmpty
      else {
        self.logger.error("WalletExtension: No active cards available")
        completion([])
        
        return
      }
    
      for card in cards {
        self.logger.info("WalletExtension: Processing card with ID \(card.id, privacy: .public)")
        
        let parameters = MppCardDataParameters(cardId: card.processorCardId, cardSecret: card.timeBasedSecret)
        guard let responseData = try? await MeaPushProvisioning.initializeOemTokenization(parameters)
        else {
          self.logger.error("initializeOemTokenization: Failed for card \(card.id, privacy: .public)")
          continue
        }
        
        guard let art = UIImage(named: "availableCard")?.cgImage
        else {
          self.logger.error("initializeOemTokenization: Missing image for card \(card.id, privacy: .public)")
          continue
        }
        
        guard let configuration = responseData.addPaymentPassRequestConfiguration
        else {
          self.logger.error("initializeOemTokenization: Missing configuration for card \(card.id, privacy: .public)")
          continue
        }
        
        guard let passEntry = PKIssuerProvisioningExtensionPaymentPassEntry(
          identifier: card.id,
          title: "Avalanche Card",
          art: art,
          addRequestConfiguration: configuration
        ) else {
          self.logger.error("initializeOemTokenization: Could not create pass entry for card \(card.id, privacy: .public)")
          continue
        }
        
        passEntries.append(passEntry)
      }
      
      self.logger.info("WalletExtension: Completed pass entry generation with \(passEntries.count) entries")
      completion(passEntries)
    }
  }
  
  override func remotePassEntries(
    completion: @escaping ([PKIssuerProvisioningExtensionPassEntry]
    ) -> Void) {
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
  
  func getActiveCards(
  ) async -> [ActiveCard]? {
    guard let accessToken = SharedUserDefaults.current.accessToken
    else {
      logger.error("❌ Error: Access token not found")
      
      return nil
    }
    
    guard let url = URL(string: "https://service-platform.liquidity-financial.com/v1/external/wallet-extension/active-cards")
    else {
      logger.error("❌ Invalid URL")
      
      return nil
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    
    let sessionId = CryptoService.shared.generateSessionId()
    request.setValue(sessionId, forHTTPHeaderField: "sessionId")
    
    do {
      let (data, response) = try await URLSession.shared.data(for: request)
      
      guard let httpResponse = response as? HTTPURLResponse else {
        logger.error("❌ Invalid response")
        
        return nil
      }
      
      guard (200...299).contains(httpResponse.statusCode) else {
        logger.error("❌ Server error: \(httpResponse.statusCode)")
        
        return nil
      }
      
      let cards = try JSONDecoder().decode([ActiveCard].self, from: data)
      logger.info("✅ Received cards: \(cards)")
      
      return cards
    } catch {
      logger.error("❌ Network or decoding error: \(error)")
      
      return nil
    }
  }
}
