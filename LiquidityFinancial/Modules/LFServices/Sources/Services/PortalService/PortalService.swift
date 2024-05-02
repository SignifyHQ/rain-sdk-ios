import Combine
import EnvironmentService
import Factory
import LFUtilities
import PortalSwift
import Web3
import Web3ContractABI

public class PortalService: PortalServiceProtocol {
  @LazyInjected(\.environmentService) var environmentService
  @Injected(\.cloudKitService) var cloudKitService

  public var portal: Portal?
  private var chainId: Int = 0
  
  init() {
    chainId = environmentService.networkEnvironment == .productionLive
    ? Configs.PortalNetwork.ethMainnet.chainID
    : Configs.PortalNetwork.ethSepolia.chainID
  }
}

// MARK: - Public Functions
public extension PortalService {
  func registerPortal(sessionToken: String) async throws {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      guard let self else { return }
      
      do {
        let backupOptions = BackupOptions(
          icloud: ICloudStorage(), passwordStorage: PasswordStorage()
        )
        let keychain = PortalKeychain()
        let gatewayConfig = Configs.PortalNetwork.configGateway(alchemyAPIKey: LFServices.alchemyAPIKey)
        
        portal = try Portal(
          apiKey: sessionToken,
          backup: backupOptions,
          chainId: chainId,
          keychain: keychain,
          gatewayConfig: gatewayConfig,
          autoApprove: true
        )
        
        log.debug("Portal Swift: Registered Portal successfully")
        continuation.resume(returning: ())
      } catch {
        log.error("Portal Swift: Error registering Portal \(error)")
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
      
      // We will automatically backup using iCloud after creating the wallet, checking the account status here will save the user's waiting time.
      if !cloudKitService.isICloudAccountAvailable {
        continuation.resume(throwing: LFPortalError.iCloudAccountUnavailable)
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
      
      if backupMethod == .iCloud, !cloudKitService.isICloudAccountAvailable {
        continuation.resume(throwing: LFPortalError.iCloudAccountUnavailable)
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
  
  func confirmWalletBackupStorage(
    backupMethod: BackupMethods,
    stored: Bool
  ) async throws {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      guard let self else { return }
      guard let portal = self.portal else {
        continuation.resume(throwing: LFPortalError.portalInstanceUnavailable)
        return
      }
      
      do {
        try portal.api.storedClientBackupShare(
          success: stored,
          backupMethod: backupMethod.rawValue,
          completion: { result -> Void in
            if let error = result.error {
              log.error("Portal Swift: Error confirming backup share storage \(error)")
              continuation.resume(throwing: self.handlePortalError(error: error))
              return
            }
            
            log.debug("Portal Swift: Backup share storage success")
            continuation.resume(returning: ())
          }
        )
      } catch {
        log.error("Portal Swift: SDK Error confirming backup share storage \(error)")
        continuation.resume(throwing: self.handlePortalError(error: error))
      }
    }
  }
  
  func recover(
    backupMethod: BackupMethods,
    backupConfigs: BackupConfigs?,
    cipherText: String
  ) async throws {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      guard let self else { return }
      guard let portal = self.portal else {
        continuation.resume(throwing: LFPortalError.portalInstanceUnavailable)
        return
      }
      
      if backupMethod == .iCloud, !cloudKitService.isICloudAccountAvailable {
        continuation.resume(throwing: LFPortalError.iCloudAccountUnavailable)
        return
      }
      
      portal.recoverWallet(
        cipherText: cipherText,
        method: backupMethod.rawValue,
        backupConfigs: backupConfigs
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
  
  func send(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws {
    let value = contractAddress == nil ? amount : 0
    let toAddress = contractAddress ?? address
    
    let tx = try await buildErc20Transaction(contractAddress: contractAddress, toAddress: address, amount: amount)
    
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Void, Error>) in
      guard let self
      else {
        continuation.resume(throwing: LFPortalError.unexpected)
        return
      }
      
      guard let walletAddress
      else {
        log.error("Portal Swift: Error sending transaction. Wallet missing)")
        continuation.resume(throwing: LFPortalError.walletMissing)
        
        return
      }
      
      self.portal?.ethSendTransaction(
        transaction: ETHTransactionParam(
          from: walletAddress,
          to: toAddress,
          value: value.ethToWei.toHexString,
          data: tx ?? ""
        )
      ) { (result: Result<TransactionCompletionResult>) in
        if let error = result.error {
          log.error("Portal Swift: Error sending transaction. \(error)")
          continuation.resume(throwing: self.handlePortalError(error: error))
          
          return
        }
        
        let txHash = (result.data?.result) ?? "-/-"
        log.debug("Portal Swift: Send transaction success.txHash: \(txHash)")
        continuation.resume(returning: ())
      }
    }
  }
  
  func estimateFee(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws -> Double {
    let value = contractAddress == nil ? amount : 0
    let toAddress = contractAddress ?? address
    
    let tx = try await buildErc20Transaction(contractAddress: contractAddress, toAddress: address, amount: amount)
    
    return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<Double, Error>) in
      guard let self
      else {
        continuation.resume(throwing: LFPortalError.unexpected)
        return
      }
      
      guard let walletAddress
      else {
        log.error("Portal Swift: Error estimating fee. Wallet missing)")
        continuation.resume(throwing: LFPortalError.walletMissing)
        
        return
      }
      
      self.portal?.ethEstimateGas(
        transaction: ETHTransactionParam(
          from: walletAddress,
          to: toAddress,
          value: value.ethToWei.toHexString,
          data: tx ?? ""
        )
      ) { result in
        if let error = result.error {
          log.error("Portal Swift: Error estimating gas. \(error)")
          continuation.resume(throwing: self.handlePortalError(error: error))
          
          return
        }
        
        guard let rpcResponse = result.data?.result as? PortalProviderRpcResponse,
              let gas = rpcResponse.result?.asDouble
        else {
          log.error("Portal Swift: Error estimating gas. Unexpected")
          continuation.resume(throwing: LFPortalError.unexpected)
          
          return
        }
        
        self.portal?.ethGasPrice { result in
          if let error = result.error {
            log.error("Portal Swift: Error estimating gas price. \(error)")
            continuation.resume(throwing: self.handlePortalError(error: error))
            
            return
          }
          
          guard let rpcResponse = result.data?.result as? PortalProviderRpcResponse,
                let gasPrice = rpcResponse.result?.asDouble?.weiToEth
          else {
            log.error("Portal Swift: Error estimating gas price. Unexpected")
            continuation.resume(throwing: LFPortalError.unexpected)
            
            return
          }
          
          let txFee: Double = gas * gasPrice
          
          log.debug("Portal Swift: Transaction fee estimation success. TxFee: \(txFee)")
          continuation.resume(returning: (txFee))
        }
      }
    }
  }
  
  private func buildErc20Transaction(
    contractAddress: String?,
    toAddress: String,
    amount: Double
  ) async throws -> String? {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<String?, Error>) in
      guard let contractAddress
      else {
        continuation.resume(returning: nil)
        return
      }
      
      guard let gatewayUrl = self?.portal?.gatewayConfig[11_155_111]
      else {
        log.error("Portal Swift: Error building ERC20 transaction. Gateway URL unavailable")
        continuation.resume(throwing: LFPortalError.unexpected)
        
        return
      }
      
      guard let walletAddressString = self?.walletAddress,
            let ethereumFromAddress = try? EthereumAddress(hex: walletAddressString, eip55: false)
      else {
        log.error("Portal Swift: Error building ERC20 transaction. Wallet address unavailable")
        continuation.resume(throwing: LFPortalError.unexpected)
        
        return
      }
      
      guard let ethereumToAddress = try? EthereumAddress(hex: toAddress, eip55: false)
      else {
        log.error("Portal Swift: Error building ERC20 transaction. ToAddress invalid")
        continuation.resume(throwing: LFPortalError.unexpected)
        
        return
      }
      
      let web3 = Web3(rpcURL: gatewayUrl)
      let contract = web3.eth.Contract(
        type: GenericERC20Contract.self,
        address: EthereumAddress(hexString: contractAddress)
      )
      
      let conversionFactor: Double = 1e6
      let value = BigUInt(amount * conversionFactor)
      guard let tx = contract
        .transfer(
          to: ethereumToAddress,
          value: value
        )
          .createTransaction(
            nonce: nil,
            gasPrice: nil,
            maxFeePerGas: nil,
            maxPriorityFeePerGas: nil,
            gasLimit: nil,
            from: ethereumFromAddress,
            value: 0,
            accessList: [:],
            transactionType: .legacy
          )
      else {
        log.error("Portal Swift: Error building ERC20 transaction. Could not build transaction")
        continuation.resume(throwing: LFPortalError.unexpected)
        
        return
      }

      continuation.resume(returning: tx.data.hex())
      return
    }
  }
  
  func refreshBalances(
  ) async throws -> (walletAddress: String?, balances: [String: Double]) {
    guard let portal = portal else {
      log.error("Portal Swift: Error fetching wallet balances. Portal instance unavailable")
      throw(LFPortalError.portalInstanceUnavailable)
    }
    
    // Fetching ERC20 token balances for wallet
    let erc20Balances = try await portal.api.getBalances("eip155:\(chainId)")
    var portalBalances = erc20Balances.reduce(into: [String: Double]()) { partialResult, balance in
      partialResult[balance.contractAddress] = balance.balance.asDouble
    }
    
    return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<(walletAddress: String?, balances: [String: Double]), Error>) in
      guard let self else {
        continuation.resume(throwing: LFPortalError.unexpected)
        return
      }
      
      guard let portal = self.portal else {
        log.error("Portal Swift: Error fetching wallet balances. Portal instance unavailable")
        continuation.resume(throwing: LFPortalError.portalInstanceUnavailable)
        return
      }
      
      // Fetching Eth balance for wallet
      portal.ethGetBalance { result in
        guard let ethBalanceResponse = result.data?.result as? ETHGatewayResponse
        else {
          log.error("Portal Swift: Error fetching ETH wallet balances \(result.error ?? "")")
          continuation.resume(throwing: self.handlePortalError(error: result.error))
          
          return
        }
        
        let ethBalance = ethBalanceResponse.result?.asDouble?.weiToEth
        portalBalances[""] = ethBalance
        
        log.debug("Portal Swift: Wallet balances for \(self.walletAddress ?? "-/-") fetched successfully")
        continuation.resume(returning: (walletAddress: self.walletAddress, balances: portalBalances))
        
        return
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
