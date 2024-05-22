import Foundation
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
      throw LFPortalError.handlePortalError(error: error)
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
      throw LFPortalError.handlePortalError(error: error)
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
      throw LFPortalError.handlePortalError(error: error)
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
      throw LFPortalError.handlePortalError(error: error)
    }
  }
  
  func send(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws {
    let transaction = try await buildEthTransaction(
      to: address,
      contractAddress: contractAddress,
      amount: amount
    )
    
    let debugDescription = "Portal Swift: Send transaction success for \(transaction.walletAddress)"
    _ = try await sendTransactionToBlockchain(
      walletAddress: transaction.walletAddress,
      transactionParams: transaction.transactionParams,
      debugDescription: debugDescription
    )
  }
  
  func withdrawAsset(
    addresses: WithdrawAssetAddresses,
    amount: Double,
    signature: WithdrawAssetSignature
  ) async throws {
    let transaction = try await buildETHTransactionParamForWithdrawAsset(
      addresses: addresses,
      amount: amount,
      signature: signature
    )
    
    let debugDescription = "Portal Swift: Send transaction success for \(transaction.walletAddress)"
    _ = try await sendTransactionToBlockchain(
      walletAddress: transaction.walletAddress,
      transactionParams: transaction.transactionParams,
      debugDescription: debugDescription
    )
  }
  
  func estimateFee(
    to address: String,
    contractAddress: String?,
    amount: Double
  ) async throws -> Double {
    // Build transaction from the inputs
    let transaction = try await buildEthTransaction(to: address, contractAddress: contractAddress, amount: amount)
    
    // Throw an error if Portal clent instance is not ready
    guard let portal else {
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
  
  func refreshBalances() async throws -> (walletAddress: String?, balances: [String: Double]) {
    guard let walletAddress
    else {
      log.error("Portal Swift: Error fetching wallet balances. Wallet missing)")
      throw(LFPortalError.walletMissing)
    }
    
    // Throw an error if Portal clent instance is not ready
    guard let portal else {
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
  
  func getSwapQuote(
    sellToken: String,
    buyToken: String,
    buyAmount: Double
  ) async throws -> Quote {
    let walletAddress = walletAddress ?? "-/-"
    // Throw an error if Portal clent instance is not ready
    guard let portal else {
      log.error("Portal Swift: Error getting swap quote for \(walletAddress). Portal instance is unavailable")
      throw(LFPortalError.portalInstanceUnavailable)
    }
    
    // TODO(Volo): Make sure we handle conversion factor correctly. It's ok to hardcode for now
    let conversionFactor: Double = 1e18
    let buyAmountBaseUnits: BigUInt = BigUInt(buyAmount * conversionFactor)
    
    // Build the quote parameters
    let quoteArguments = QuoteArgs(
      buyToken: buyToken,
      sellToken: sellToken,
      buyAmount: "\(buyAmountBaseUnits)"
    )
    
    // Get the swap quote
    let swapsKey = environmentService.networkEnvironment == .productionLive ?
    Configs.PortalSwaps.prodKey :
    Configs.PortalSwaps.devKey
    
    let quote = try await portal.api.getQuote(
      swapsKey,
      withArgs: quoteArguments,
      forChainId: "eip155:\(chainId)"
    )
    
    let debugDescription = "\(walletAddress), sellToken: \(sellToken), buyToken: \(buyToken), buyAmount: \(buyAmount). Quote: \(quote)"
    log.debug("Portal Swift: Swap quote fetched successfully for address: \(debugDescription)")
    return quote
  }
  
  func executeSwap(quote: Quote) async throws -> String {
    let walletAddress = walletAddress ?? "-/-"
    let debugDescription = "Portal Swift: Swap execution success for address: \(walletAddress) with quote: \(quote)"
    let txHash = try await sendTransactionToBlockchain(
      walletAddress: walletAddress,
      transactionParams: quote.transaction,
      debugDescription: debugDescription
    )
    
    return txHash
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
  func buildEthTransaction(
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
      data: tx ?? .empty
    )
    
    return (walletAddress: walletAddress, transactionParams: transactionParams)
  }
  
  func buildETHTransactionParamForWithdrawAsset(
    addresses: WithdrawAssetAddresses,
    amount: Double,
    signature: WithdrawAssetSignature
  ) async throws -> (walletAddress: String, transactionParams: ETHTransactionParam) {
    guard let walletAddress else {
      log.error("Portal Swift: Error estimating fee. Wallet missing)")
      throw(LFPortalError.walletMissing)
    }
    
    let ethereumContractAddress = try createEthereumAddress(hex: addresses.contractAddress, description: "Contract")
    let ethereumProxyAddress = try createEthereumAddress(hex: addresses.proxyAddress, description: "Proxy")
    let ethereumRecipientAddress = try createEthereumAddress(hex: addresses.recipientAddress, description: "Recipient")
    let ethereumTokenAddress = try createEthereumAddress(hex: addresses.tokenAddress, description: "Token")
    
    guard let saltData = Data(base64Encoded: signature.salt),
          let signatureData = Data(hexString: signature.signature, length: 65)
    else {
      throw LFPortalError.unexpected
    }
    
    guard let unixTimestamp = signature.expiresAt.parseToUnixTimestamp() else {
      throw LFPortalError.unexpected
    }
    
    let withdrawAssetParameter = WithdrawAssetParameter(
      proxyAddress: ethereumProxyAddress,
      tokenAddress: ethereumTokenAddress,
      amount: amount,
      recipientAddress: ethereumRecipientAddress,
      expiryAt: unixTimestamp,
      salt: saltData,
      signature: signatureData
    )
    let tx = try await buildErc20TransactionForWithdrawAsset(
      ethereumContractAddress: ethereumContractAddress,
      withdrawAssetParameter: withdrawAssetParameter
    )
    
    let transactionParams = ETHTransactionParam(
      from: walletAddress,
      to: addresses.contractAddress,
      value: 0.ethToWei.toHexString,
      data: tx ?? .empty
    )
    
    return (walletAddress: walletAddress, transactionParams: transactionParams)
  }
  
  func buildErc20TransactionForWithdrawAsset(
    ethereumContractAddress: EthereumAddress,
    withdrawAssetParameter: WithdrawAssetParameter
  ) async throws -> String? {
    return try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<String?, Error>) in
      guard let self else {
        continuation.resume(throwing: LFPortalError.unexpected)
        return
      }
      
      do {
        let rpcURL = try getRpcURL()
        let contractJsonABI = try getContractJsonABI()
        let web3 = Web3(rpcURL: rpcURL)
        let contract = try web3.eth.Contract(json: contractJsonABI, abiKey: nil, address: ethereumContractAddress)
        let transaction = try createWithdrawAssetTransaction(
          with: contract,
          ethereumContractAddress: ethereumContractAddress,
          withdrawAssetParameter: withdrawAssetParameter
        )
        continuation.resume(returning: transaction.data.hex())
        return
      } catch {
        log.error("Portal Swift: Error building ERC20 transaction. Web3 contract is unavailable")
        continuation.resume(throwing: error)
        return
      }
    }
  }
  
  func buildErc20Transaction(
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
      
      do {
        let rpcURL = try getRpcURL()
        let ethereumFromAddress = try createEthereumAddress(hex: walletAddress, description: "Wallet")
        let ethereumToAddress = try createEthereumAddress(hex: toAddress, description: "To")
        
        let web3 = Web3(rpcURL: rpcURL)
        let contract = web3.eth.Contract(
          type: GenericERC20Contract.self,
          address: EthereumAddress(hexString: contractAddress)
        )
        
        guard let tx = contract
          .transfer(
            to: ethereumToAddress,
            value: BigUInt(amount * 1e6)
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
          throw LFPortalError.unexpected
        }
        
        continuation.resume(returning: tx.data.hex())
        return
      } catch {
        log.error("Portal Swift: Error building ERC20 transaction. Could not build transaction")
        continuation.resume(throwing: error)
        return
      }
    }
  }
  
  func getRpcURL() throws -> String {
    guard let rpcURL = portal?.rpcConfig["eip155:\(chainId)"] else {
      log.error("Portal Swift: Error building ERC20 transaction. rpcURL is unavailable")
      throw LFPortalError.unexpected
    }
    
    return rpcURL
  }
  
  func getContractJsonABI() throws -> Data {
    guard let contractABIJson = FileHelpers.readJSONFile(forName: "contractJsonABI", type: [String: String].self),
          let contractABIJsonString = contractABIJson["result"],
          let contractJsonABI = contractABIJsonString.data(using: .utf8)
    else {
      log.error("Portal Swift: Error building ERC20 transaction. ContractJsonABI is unavailable")
      throw LFPortalError.unexpected
    }
    
    return contractJsonABI
  }
  
  func createEthereumAddress(hex: String?, description: String) throws -> EthereumAddress {
    guard let hex, let address = try? EthereumAddress(hex: hex, eip55: false) else {
      log.error("Portal Swift: Error building ERC20 transaction. \(description) address is unavailable")
      throw LFPortalError.unexpected
    }
    return address
  }
  
  func createWithdrawAssetTransaction(
    with contract: DynamicContract,
    ethereumContractAddress: EthereumAddress,
    withdrawAssetParameter: WithdrawAssetParameter
  ) throws -> EthereumTransaction {
    let withdrawAssetMethod = contract["withdrawAsset"]?(
      withdrawAssetParameter.proxyAddress,
      withdrawAssetParameter.tokenAddress,
      withdrawAssetParameter.amount,
      withdrawAssetParameter.recipientAddress,
      withdrawAssetParameter.expiryAt,
      withdrawAssetParameter.salt,
      withdrawAssetParameter.signature
    )
    
    guard let transaction = withdrawAssetMethod?.createTransaction(
      nonce: nil,
      gasPrice: nil,
      maxFeePerGas: nil,
      maxPriorityFeePerGas: nil,
      gasLimit: nil,
      from: ethereumContractAddress,
      value: 0,
      accessList: [:],
      transactionType: .legacy
    ) else {
      log.error("Portal Swift: Error building ERC20 transaction. Web3 transaction is unavailable")
      throw LFPortalError.unexpected
    }
    
    return transaction
  }
  
  func sendTransactionToBlockchain(
    walletAddress: String,
    transactionParams: ETHTransactionParam,
    debugDescription: String = .empty
  ) async throws -> String {
    // Throw an error if Portal clent instance is not ready
    guard let portal else {
      log.error("Portal Swift: Error sending transaction for \(walletAddress). Portal instance is unavailable")
      throw(LFPortalError.portalInstanceUnavailable)
    }
    
    // Send the transaction to the blockchain
    let ethSendResponse = try await portal.request(
      "eip155:\(chainId)",
      withMethod: .eth_sendTransaction,
      andParams: [transactionParams]
    )
    let txHash = ethSendResponse.result as? String ?? "-/-"
    log.debug("\(debugDescription) - txHash: \(txHash)")
    
    return txHash
  }
}

// MARK: - Types
extension PortalService {
  public struct WithdrawAssetAddresses {
    let contractAddress: String
    let proxyAddress: String
    let recipientAddress: String
    let tokenAddress: String
    
    public init(contractAddress: String, proxyAddress: String, recipientAddress: String, tokenAddress: String) {
      self.contractAddress = contractAddress
      self.proxyAddress = proxyAddress
      self.recipientAddress = recipientAddress
      self.tokenAddress = tokenAddress
    }
  }
  
  public struct WithdrawAssetSignature {
    let expiresAt: String
    let salt: String
    let signature: String
    
    public init(expiresAt: String, salt: String, signature: String) {
      self.expiresAt = expiresAt
      self.salt = salt
      self.signature = signature
    }
  }
  
  struct WithdrawAssetParameter {
    let proxyAddress: EthereumAddress
    let tokenAddress: EthereumAddress
    let amount: BigUInt
    let recipientAddress: EthereumAddress
    let expiryAt: BigUInt
    let salt: Data
    let signature: Data
    
    init(
      proxyAddress: EthereumAddress,
      tokenAddress: EthereumAddress,
      amount: Double,
      recipientAddress: EthereumAddress,
      expiryAt: TimeInterval,
      salt: Data,
      signature: Data
    ) {
      self.proxyAddress = proxyAddress
      self.tokenAddress = tokenAddress
      self.amount = BigUInt(amount * 1e6)
      self.recipientAddress = recipientAddress
      self.expiryAt = BigUInt(expiryAt)
      self.salt = salt
      self.signature = signature
    }
  }
}
