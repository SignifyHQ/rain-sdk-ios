import PortalSwift
import Combine
import LFUtilities
import EnvironmentService
import Factory

public class PortalService: PortalServiceProtocol {
  @LazyInjected(\.environmentService) var environmentService
  
  public var portal: Portal?
  
  public init() {}
}

// MARK: - Public Functions
public extension PortalService {
  func registerPortal(sessionToken: String, alchemyAPIKey: String) async throws {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      guard let self else { return }
      
      do {
        let backupOptions = BackupOptions(
          icloud: ICloudStorage(), passwordStorage: PasswordStorage()
        )
        let keychain = PortalKeychain()
        let gatewayConfig = Configs.PortalNetwork.configGateway(alchemyAPIKey: alchemyAPIKey)
        let chainId = self.environmentService.networkEnvironment == .productionLive
        ? Configs.PortalNetwork.ethMainnet.chainID
        : Configs.PortalNetwork.ethSepolia.chainID
        
        portal = try Portal(
          apiKey: sessionToken,
          backup: backupOptions,
          chainId: chainId,
          keychain: keychain,
          gatewayConfig: gatewayConfig
        )
        
        continuation.resume(returning: ())
      } catch {
        continuation.resume(
          throwing: self.handlePortalError(error: error)
        )
      }
    }
  }
  
  func createWallet() async throws -> String {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<String, Error>) in
      guard let self else { return }
      guard let portal = self.portal else {
        continuation.resume(throwing: LFPortalError.portalInstanceUnavailable)
        return
      }
      
      portal.createWallet(
        completion: { addressResult in
          guard let error = addressResult.error else {
            continuation.resume(returning: addressResult.data ?? "N/A")
            return
          }
          
          continuation.resume(
            throwing: self.handlePortalError(error: error)
          )
        },
        progress: { status in
          log.debug("Wallet Creation Status: \(status)")
        }
      )
    }
  }
  
  func backup(
    backupMethod: BackupMethods,
    backupConfigs: BackupConfigs? = nil
  ) async throws -> String {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<String, Error>) in
      guard let self else { return }
      guard let portal = self.portal else {
        continuation.resume(throwing: LFPortalError.portalInstanceUnavailable)
        return
      }
      
      portal.backupWallet(
        method: backupMethod.rawValue,
        backupConfigs: backupConfigs
      ) { result in
        if let error = result.error {
          log.error("Portal Swift: Error backing up wallet \(error)")
          continuation.resume(
            throwing: self.handlePortalError(error: error)
          )
          return
        }
        
        guard let data = result.data else {
          log.error("Portal Swift: Error backing up wallet No Data")
          continuation.resume(throwing: LFPortalError.dataUnavailable)
          return
        }
        
        log.debug("Portal Swift: Wallet backup success")
        continuation.resume(returning: data)
      } progress: { status in
        log.debug("Backup Wallet Status: \(status)")
      }
    }
  }
  
  func recover(
    backupMethod: BackupMethods,
    cipherText: String
  ) async throws {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      guard let self else { return }
      guard let portal = self.portal else {
        continuation.resume(throwing: LFPortalError.portalInstanceUnavailable)
        return
      }
      
      portal.recoverWallet(
        cipherText: cipherText,
        method: backupMethod.rawValue
      ) { result -> Void in
        if let error = result.error {
          log.error("Portal Swift: Error backing up wallet \(error)")
          continuation.resume(
            throwing: self.handlePortalError(error: error)
          )
          return
        }
        
        log.debug("Portal Swift: Wallet recover success")
        continuation.resume(returning: ())
      } progress: { status in
        log.debug("Recover Status: \(status)")
      }
    }
  }
  
  func getBalances(
  ) async throws -> [PortalBalance] {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<[PortalBalance], Error>) in
      guard let self else {
        continuation.resume(throwing: LFPortalError.unexpected)
        return
      }
      
      guard let portal = self.portal else {
        continuation.resume(throwing: LFPortalError.portalInstanceUnavailable)
        return
      }
      
      do {
        // Fetching ERC20 token balances for wallet
        try portal.api.getBalances { result in
          guard let erc20Balances = result.data
          else {
            log.error("Portal Swift: Error fetching ERC20 wallet balances \(result.error ?? "")")
            continuation.resume(throwing: self.handlePortalError(error: result.error))
            
            return
          }
          
          var portalBalances = erc20Balances.compactMap { balance in
            PortalBalance(
              token: PortalToken(
                contractAddress: balance.contractAddress,
                // TODO(Volo): Figure out how to handle symbol and name
                symbol: "",
                name: ""
              ),
              balance: balance.balance.asDouble
            )
          }
          
          // Fetching Eth balance for wallet
          portal.ethGetBalance { result in
            guard let ethBalanceResponse = result.data?.result as? ETHGatewayResponse
            else {
              log.error("Portal Swift: Error fetching ETH wallet balances \(result.error ?? "")")
              continuation.resume(throwing: self.handlePortalError(error: result.error))
              
              return
            }
            
            let ethBalance = ethBalanceResponse.result?.asDouble?.weiToEth()
            portalBalances.append(
              PortalBalance(
                token: PortalToken(
                  // Contract address will be blank for non-ERC20 tokens
                  // TODO(Volo): Figure out how to handle symbol and name
                  contractAddress: "",
                  symbol: "ETH",
                  name: "Ethereum"
                ),
                balance: ethBalance
              )
            )
            
            log.debug("Portal Swift: Wallet balances for \(self.walletAddress ?? "-/-") fetched successfully")
            continuation.resume(returning: portalBalances)
            
            return
          }
        }
      } catch {
        log.error("Portal Swift: API error fetching wallet balances \(error)")
        continuation.resume(throwing: self.handlePortalError(error: error))
      }
    }
  }
}

// MARK: - Helper
public extension PortalService {
  func checkWalletAddressExists() -> Bool {
    !(walletAddress ?? "").isEmpty
  }
  
  var walletAddress: String? {
    portal?.address
  }
}

// MARK: - Private Functions
private extension PortalService {
  func handlePortalError(error: Error?) -> Error {
    if let portalError = error as? PortalError, portalError.code == PortalErrorCodes.INVALID_API_KEY.rawValue {
      return LFPortalError.expirationToken
    }
    
    guard let portalMpcError = error as? PortalMpcError else {
      return error ?? LFPortalError.unexpected
    }
    
    switch portalMpcError.code {
    case 320:
      return LFPortalError.expirationToken
    case PortalErrorCodes.INVALID_API_KEY.rawValue:
      return LFPortalError.expirationToken
    case PortalErrorCodes.BAD_REQUEST.rawValue:
      return portalMpcError.message.contains(PortalErrorMessage.walletAlreadyExists) ? LFPortalError.walletAlreadyExists : portalMpcError
    default:
      return portalMpcError
    }
  }
}

// MARK: - PortalErrorMessage
extension PortalService {
  enum PortalErrorMessage {
    static let walletAlreadyExists = "Wallet already exists"
  }
}
