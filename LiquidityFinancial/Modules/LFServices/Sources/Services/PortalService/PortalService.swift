import PortalSwift
import Combine
import LFUtilities
import EnvironmentService
import Factory

public class PortalService: PortalServiceProtocol {
  @LazyInjected(\.environmentService) var environmentService
  
  public var portal: Portal?
  
  public init() {
  }
}

// MARK: - Public Functions
public extension PortalService {
  func registerPortal(sessionToken: String, alchemyAPIKey: String = "") -> AnyPublisher<Bool, Error> {
    Future<Bool, Error> { [weak self] promise in
      guard let self else { return }
      
      do {
        let backupOptions = BackupOptions(
          icloud: ICloudStorage(), passwordStorage: PasswordStorage()
        )
        let keychain = PortalKeychain()
        let gatewayConfig = Configs.PortalNetwork.configGateway(alchemyAPIKey: alchemyAPIKey)
        let chainId = self.environmentService.networkEnvironment == .productionLive
        ? Configs.PortalNetwork.ethGoerli.chainID
        : Configs.PortalNetwork.ethMainnet.chainID
        
        portal = try Portal(
          apiKey: sessionToken,
          backup: backupOptions,
          chainId: chainId,
          keychain: keychain,
          gatewayConfig: gatewayConfig
        )
        
        promise(.success(true))
      } catch {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }
  
  func createWallet() -> AnyPublisher<String, Error> {
    Future<String, Error> { [weak self] promise in
      guard let self else { return }
      
      self.portal?.createWallet(
        completion: { addressResult in
          guard let error = addressResult.error else {
            promise(.success(addressResult.data ?? "N/A"))
            return
          }
          promise(.failure(error))
        },
        progress: { status in
          log.debug("Wallet Creation Status: \(status)")
        }
      )
    }
    .eraseToAnyPublisher()
  }
  
  func backup(
    backupMethod: BackupMethods.RawValue,
    clientID: String,
    backupConfigs: BackupConfigs? = nil
  ) -> AnyPublisher<String, Error> {
    Future<String, Error> { [weak self] promise in
      guard let self else { return }
      
      self.portal?.backupWallet(method: backupMethod, backupConfigs: backupConfigs) { result in
        if let error = result.error {
          log.error("Portal Swift: Error backing up wallet \(error)")
          promise(.failure(error))
          return
        }
        
        guard let data = result.data else {
          log.error("Portal Swift: Error backing up wallet No Data")
          promise(.failure(PortalError.noData))
          return
        }
        
        // TODO: - Push cipher text to our server
        // Will remove bellow code later
        promise(.success(data))
        
      } progress: { status in
        log.debug("Backup Wallet Status: \(status)")
      }
    }
    .eraseToAnyPublisher()
  }
}
