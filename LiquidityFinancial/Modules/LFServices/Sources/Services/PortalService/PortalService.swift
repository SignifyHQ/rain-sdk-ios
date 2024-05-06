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
    do {
      let withRpcConfig = Configs.PortalNetwork.configRPC(alchemyAPIKey: LFServices.alchemyAPIKey)
      
      portal = try Portal(
        sessionToken,
        withRpcConfig: withRpcConfig,
        autoApprove: true,
        iCloud: ICloudStorage(),
        keychain: PortalKeychain(),
        passwords: PasswordStorage()
      )
      
      log.debug("Portal Swift: Registered Portal successfully")
    } catch {
      log.error("Portal Swift: Error registering Portal \(error)")
      throw handlePortalError(error: error)
    }
  }
  
  func createWallet() async throws -> String {
    guard let portal else {
      throw LFPortalError.portalInstanceUnavailable
    }
    
    // We will automatically backup using iCloud after creating the wallet, checking the account status here will save the user's waiting time.
    if !cloudKitService.isICloudAccountAvailable {
      throw LFPortalError.iCloudAccountUnavailable
    }
    
    do {
      let addresses = try await portal.createWallet { status in
        log.debug("Wallet Creation Status: \(status)")
      }
      return addresses.ethereum ?? "N/A"
    } catch {
      throw handlePortalError(error: error)
    }
  }
  
  func backup(
    backupMethod: BackupMethods,
    password: String? = nil
  ) async throws -> (String, () async throws -> Void) {
    guard let portal else {
      throw LFPortalError.portalInstanceUnavailable
    }
    
    if backupMethod == .iCloud, !cloudKitService.isICloudAccountAvailable {
      throw LFPortalError.iCloudAccountUnavailable
    }
    
    if let password, backupMethod == .Password {
      try portal.setPassword(password)
    }
    
    do {
      let (cipherText, storageCallback) = try await portal.backupWallet(backupMethod) { status in
        log.debug("Backup Wallet Status: \(status)")
      }
      
      log.debug("Portal Swift: Wallet backup success")
      return (cipherText, storageCallback)
    } catch {
      log.error("Portal Swift: Error backing up wallet \(error)")
      throw handlePortalError(error: error)
    }
  }
  
  func recover(
    backupMethod: BackupMethods,
    password: String? = nil,
    cipherText: String
  ) async throws {
    guard let portal else {
      throw LFPortalError.portalInstanceUnavailable
    }
    
    if backupMethod == .iCloud, !cloudKitService.isICloudAccountAvailable {
      throw LFPortalError.iCloudAccountUnavailable
    }
    
    if let password, backupMethod == .Password {
      try portal.setPassword(password)
    }
    
    do {
      _ = try await portal.recoverWallet(backupMethod, withCipherText: cipherText) { status in
        log.debug("Recover Status: \(status)")
      }
      
      log.debug("Portal Swift: Wallet recover success")
      
    } catch {
      log.error("Portal Swift: Error backing up wallet \(error)")
      throw handlePortalError(error: error)
    }
  }
  
  func send(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws {
    // Build params from the inputs
    let transaction = try await buildEthTransaction(to: address, contractAddress: contractAddress, amount: amount)
    
    // Throw an error if Portal clent instance is not ready
    guard let portal = portal else {
      log.error("Portal Swift: Error sending transaction for \(transaction.walletAddress). Portal instance is unavailable")
      throw(LFPortalError.portalInstanceUnavailable)
    }
    
    // Send the transaction to the blockchain
    let ethSendResponse = try await portal.request(
      "eip155:\(chainId)",
      withMethod: .eth_sendTransaction,
      andParams: [transaction.transactionParams]
    )
    
    let txHash = ethSendResponse.result as? String ?? "-/-"
    log.debug("Portal Swift: Send transaction success for \(transaction.walletAddress). txHash: \(txHash)")
  }
  
  func estimateFee(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws -> Double {
    // Build transaction from the inputs
    let transaction = try await buildEthTransaction(to: address, contractAddress: contractAddress, amount: amount)
    
    // Throw an error if Portal clent instance is not ready
    guard let portal = portal else {
      log.error("Portal Swift: Error estimating fee for \(transaction.walletAddress). Portal instance is unavailable")
      throw(LFPortalError.portalInstanceUnavailable)
    }
    
    // Fetch estimated gas for the transaction
    let ethEstimateGasResonse = try await portal.request(
      "eip155:\(chainId)",
      withMethod: .eth_estimateGas,
      andParams: [transaction.transactionParams]
    )
    guard let ethEstimateGasRpcResponse = ethEstimateGasResonse.result as? PortalProviderRpcResponse,
          let gas = ethEstimateGasRpcResponse.result?.asDouble
    else {
      log.error("Portal Swift: Error estimating gas for \(transaction.walletAddress). Unexpected RPC response")
      throw(LFPortalError.unexpected)
    }
    
    // Fetch current gas price
    let ethEstimateGasPriceResonse = try await portal.request(
      "eip155:\(chainId)",
      withMethod: .eth_gasPrice,
      andParams: []
    )
    guard let ethEstimateGasPriceRpcResponse = ethEstimateGasPriceResonse.result as? PortalProviderRpcResponse,
          let gasPrice = ethEstimateGasPriceRpcResponse.result?.asDouble?.weiToEth
    else {
      log.error("Portal Swift: Error estimating gas price for \(transaction.walletAddress). Unexpected RPC response")
      throw(LFPortalError.unexpected)
    }
    
    // Calculate the total fees
    let txFee: Double = gas * gasPrice
    
    log.debug("Portal Swift: Transaction fee estimation success for \(transaction.walletAddress). tx fee: \(txFee)")
    return(txFee)
  }
  
  func refreshBalances(
  ) async throws -> (walletAddress: String?, balances: [String: Double]) {
    guard let walletAddress
    else {
      log.error("Portal Swift: Error fetching wallet balances. Wallet missing)")
      throw(LFPortalError.walletMissing)
    }
    
    // Throw an error if Portal clent instance is not ready
    guard let portal = portal else {
      log.error("Portal Swift: Error fetching wallet balances for \(walletAddress). Portal instance is unavailable")
      throw(LFPortalError.portalInstanceUnavailable)
    }
    
    // Fetch ERC20 token balances for wallet
    let erc20Balances = try await portal.api.getBalances("eip155:\(chainId)")
    var portalBalances = erc20Balances.reduce(into: [String: Double]()) { partialResult, balance in
      partialResult[balance.contractAddress] = balance.balance.asDouble
    }
    
    // Fetch ETH token balance for wallet
    let ethBalanceResponse = try await portal
      .request(
        "eip155:\(chainId)",
        withMethod: .eth_getBalance,
        andParams: [walletAddress, "latest"]
      )
    guard let ethBalanceRpcResponse = ethBalanceResponse.result as? PortalProviderRpcResponse
    else {
      log.error("Portal Swift: Error fetching ETH wallet balances for \(walletAddress). Unexpected RPC response")
      throw(LFPortalError.unexpected)
    }
    
    let ethBalance = ethBalanceRpcResponse.result?.asDouble?.weiToEth
    portalBalances[""] = ethBalance
    
    log.debug("Portal Swift: Wallet balances for \(walletAddress) fetched successfully")
    return(walletAddress: walletAddress, balances: portalBalances)
  }
}

// MARK: - Helper
public extension PortalService {
  func getWalletAddress() async -> String? {
    do {
      guard let portal else {
        return nil
      }
      
      // Currently, we only use eip55 address
      let addresses = try await portal.addresses
      return addresses[PortalNamespace.eip155] ?? nil
    } catch {
      return nil
    }
  }
  
  func isWalletOnDevice() async -> Bool {
    do {
      guard let portal else {
        return false
      }
      return try await portal.isWalletOnDevice()
    } catch {
      return false
    }
  }
  
  var walletAddress: String? {
    portal?.address
  }
}

// MARK: - Private Functions
private extension PortalService {
  private func buildEthTransaction(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws -> (walletAddress: String, transactionParams: ETHTransactionParam) {
    guard let walletAddress
    else {
      log.error("Portal Swift: Error estimating fee. Wallet missing)")
      throw(LFPortalError.walletMissing)
    }
    
    // If sending ERC20 token, the value parameter should be 0 because it's encoded in the tx hash
    let value = contractAddress == nil ? amount : 0
    // If sending ERC20 token, the toAddress should be the address of token contract, the recipient address is encoded in the tx hash
    let toAddress = contractAddress ?? address
    
    // Build transaction params. In case of sendind native token, tx will be nil
    let tx = try await buildErc20Transaction(contractAddress: contractAddress, toAddress: address, amount: amount)
    let transactionParams = ETHTransactionParam(
      from: walletAddress,
      to: toAddress,
      value: value.ethToWei.toHexString,
      data: tx ?? ""
    )
    
    return (walletAddress: walletAddress, transactionParams: transactionParams)
  }
  
  private func buildErc20Transaction(
    contractAddress: String?,
    toAddress: String,
    amount: Double
  ) async throws -> String? {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<String?, Error>) in
      guard let self
      else {
        continuation.resume(throwing: LFPortalError.unexpected)
        return
      }
      
      guard let contractAddress
      else {
        continuation.resume(returning: nil)
        return
      }
      
      guard let gatewayUrl = portal?.gatewayConfig[chainId]
      else {
        log.error("Portal Swift: Error building ERC20 transaction. Gateway URL is unavailable")
        continuation.resume(throwing: LFPortalError.unexpected)
        
        return
      }
      
      guard let walletAddressString = walletAddress,
            let ethereumFromAddress = try? EthereumAddress(hex: walletAddressString, eip55: false)
      else {
        log.error("Portal Swift: Error building ERC20 transaction. Wallet address is unavailable")
        continuation.resume(throwing: LFPortalError.unexpected)
        
        return
      }
      
      guard let ethereumToAddress = try? EthereumAddress(hex: toAddress, eip55: false)
      else {
        log.error("Portal Swift: Error building ERC20 transaction. ToAddress is invalid")
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
  
  func handlePortalError(error: Error?) -> Error {
    guard let portalMpcError = error as? PortalMpcError else {
      return error ?? LFPortalError.unexpected
    }
    
    switch portalMpcError.code {
    case 320:
      return LFPortalError.expirationToken
    case PortalErrorCodes.INVALID_API_KEY.rawValue:
      return LFPortalError.expirationToken
    case PortalErrorCodes.BAD_REQUEST.rawValue:
      return portalMpcError.message.lowercased().contains(PortalErrorMessage.walletAlreadyExists) ? LFPortalError.walletAlreadyExists : portalMpcError
    default:
      return portalMpcError
    }
  }
}

// MARK: - PortalErrorMessage
extension PortalService {
  enum PortalErrorMessage {
    static let walletAlreadyExists = "wallet already exists"
  }
}
