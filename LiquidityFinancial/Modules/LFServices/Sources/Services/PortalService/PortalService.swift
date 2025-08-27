import Foundation
import Combine
import EnvironmentService
import Factory
import LFUtilities
import PortalSwift
import Web3
import Web3ContractABI
import web3swift
import Web3Core

public class PortalService: PortalServiceProtocol {
  @LazyInjected(\.environmentService) var environmentService
  @Injected(\.cloudKitService) var cloudKitService
  
  public var portal: Portal?
  public var chainId: Int = 0
  
  init() {
    chainId = environmentService.networkEnvironment == .productionLive
    ? Configs.PortalNetwork.avalancheMainnet.chainID
    : Configs.PortalNetwork.avalancheFuji.chainID
  }
}

// MARK: - Public Functions
public extension PortalService {
  func registerPortal(sessionToken: String) async throws {
    do {
      let withRpcConfig = Configs.PortalNetwork.configRPC()
      
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
      log.error("Portal Swift: Error recovering wallet \(error)")
      throw LFPortalError.handlePortalError(error: error)
    }
  }
  
  func send(
    to address: String,
    contractAddress: String?,
    amount: Double,
    conversionFactor: Int
  ) async throws -> String {
    let transaction = try await buildEthTransaction(
      to: address,
      contractAddress: contractAddress,
      amount: amount,
      conversionFactor: conversionFactor
    )
    
    let debugDescription = "Portal Swift: Send transaction success for \(transaction.walletAddress). Amount: \(amount)"
    return try await sendTransactionToBlockchain(
      walletAddress: transaction.walletAddress,
      transactionParams: transaction.transactionParams,
      debugDescription: debugDescription
    )
  }
  
  func withdrawAsset(
    addresses: WithdrawAssetAddresses,
    amount: Double,
    conversionFactor: Int,
    signature: WithdrawAssetSignature
  ) async throws -> String {
    let transaction = try await buildETHTransactionParamForWithdrawAsset(
      addresses: addresses,
      amount: amount,
      conversionFactor: conversionFactor,
      signature: signature
    )
    
    let debugDescription = "Portal Swift: Send transaction success for \(transaction.walletAddress)"
    return try await sendTransactionToBlockchain(
      walletAddress: transaction.walletAddress,
      transactionParams: transaction.transactionParams,
      debugDescription: debugDescription
    )
  }
  
  func estimateWithdrawalFee(
    addresses: WithdrawAssetAddresses,
    amount: Double,
    conversionFactor: Int,
    signature: WithdrawAssetSignature
  ) async throws -> Double {
    let transaction = try await buildETHTransactionParamForWithdrawAsset(
      addresses: addresses,
      amount: amount,
      conversionFactor: conversionFactor,
      signature: signature
    )
    
    return try await estimateTransactionFee(address: transaction.walletAddress, params: transaction.transactionParams)
  }
  
  func estimateTransferFee(
    to address: String,
    contractAddress: String?,
    amount: Double,
    conversionFactor: Int
  ) async throws -> Double {
    let transaction = try await buildEthTransaction(
      to: address,
      contractAddress: contractAddress,
      amount: amount,
      conversionFactor: conversionFactor
    )
    
    return try await estimateTransactionFee(address: transaction.walletAddress, params: transaction.transactionParams)
  }
  
  func refreshBalances(
  ) async throws -> (walletAddress: String?, balances: [String: Double]) {
    guard let walletAddress = try await portal?.addresses[PortalNamespace.eip155] ?? "-/-"
    else {
      log.error("Portal Swift: Error fetching wallet balances. Wallet missing")
      throw(LFPortalError.walletMissing)
    }
    
    // Throw an error if Portal clent instance is not ready
    guard let portal else {
      log.error("Portal Swift: Error fetching wallet balances for \(walletAddress). Portal instance is unavailable")
      throw(LFPortalError.portalInstanceUnavailable)
    }
    
    // Fetch ERC20 token balances for wallet
    let erc20Balances = try await portal.api.getBalances("eip155:\(chainId)")
    
    // Create portal balances dictionary with ERC20 token balances as initial data
    var portalBalances: [String: Double] = erc20Balances.reduce(
      into: [:], { partialResult, balance in
        partialResult[balance.contractAddress] = balance.balance.asDouble
      }
    )
    
    // Fetch ETH token balance for wallet
    let ethBalanceResponse = try await portal
      .request(
        "eip155:\(chainId)",
        withMethod: .eth_getBalance,
        andParams: [
          walletAddress,
          "latest"
        ]
      )
    
    guard let ethBalanceRpcResponse = ethBalanceResponse.result as? PortalProviderRpcResponse
    else {
      log.error("Portal Swift: Error fetching ETH wallet balances for \(walletAddress). Unexpected RPC response")
      throw(LFPortalError.unexpected)
    }
    
    // Add ETH token balance to the portal balances dictionary
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
    amount: Double,
    conversionFactor: Int
  ) async throws -> (walletAddress: String, transactionParams: ETHTransactionParam) {
    guard let walletAddress
    else {
      log.error("Portal Swift: Error estimating fee. Wallet missing")
      throw(LFPortalError.walletMissing)
    }
    
    // If sending ERC20 token, the value parameter should be 0 because it's encoded in the tx hash
    let value = contractAddress == nil ? amount : 0
    // If sending ERC20 token, the toAddress should be the address of token contract, the recipient address is encoded in the tx hash
    let toAddress = contractAddress ?? address
    
    // Build transaction params. In case of sendind native token, tx will be nil
    let tx = try await buildErc20Transaction(
      contractAddress: contractAddress,
      toAddress: address,
      amount: BigUInt(amount * pow(10.0, Double(conversionFactor)))
    )
    
    let transactionParams = ETHTransactionParam(
      from: walletAddress,
      to: toAddress,
      value: value.ethToWei.toHexString,
      data: tx ?? .empty
    )
    
    return (walletAddress: walletAddress, transactionParams: transactionParams)
  }
  
  private func buildETHTransactionParamForWithdrawAsset(
    addresses: WithdrawAssetAddresses,
    amount: Double,
    conversionFactor: Int,
    signature: WithdrawAssetSignature
  ) async throws -> (walletAddress: String, transactionParams: ETHTransactionParam) {
    guard let walletAddress else {
      log.error("Portal Swift: Error estimating fee. Wallet missing")
      throw(LFPortalError.walletMissing)
    }
    
    guard let ethereumContractAddress = Web3Core.EthereumAddress(addresses.contractAddress),
          let ethereumProxyAddress = Web3Core.EthereumAddress(addresses.proxyAddress),
            let ethereumRecipientAddress = Web3Core.EthereumAddress(addresses.recipientAddress),
          let ethereumTokenAddress = Web3Core.EthereumAddress(addresses.tokenAddress)
    else {
      log.error("Portal Swift: Error building transaction parameters for withdrawal. One of the addresses could not be build")
      throw LFPortalError.unexpected
    }
      
    let amountBaseUnits = BigUInt(amount * pow(10.0, Double(conversionFactor)))
    
    guard let saltData = Data(base64Encoded: signature.salt),
          let signatureData = Data(hexString: signature.signature, length: 65)
    else {
      log.error("Portal Swift: Error building transaction parameters for withdrawal. Could not construct Data for salt or signature")
      throw LFPortalError.unexpected
    }
    
    guard let unixTimestamp = signature.expiresAt.parseToUnixTimestamp() else {
      log.error("Portal Swift: Error building transaction parameters for withdrawal. Could not parse expiration to UNIX timestamp")
      throw LFPortalError.unexpected
    }
    
    let adminSignature = try await getAdminSignature(
      addresses: addresses,
      walletAddress: walletAddress,
      amount: amountBaseUnits
    )
    
    let withdrawAssetParameter = WithdrawAssetParameter(
      proxyAddress: ethereumProxyAddress,
      tokenAddress: ethereumTokenAddress,
      amount: amountBaseUnits,
      recipientAddress: ethereumRecipientAddress,
      expiryAt: BigUInt(unixTimestamp),
      salt: saltData,
      signature: signatureData,
      adminSalt: adminSignature.salt,
      adminSignature: adminSignature.signature
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
  
  private func buildErc20TransactionForWithdrawAsset(
    ethereumContractAddress: Web3Core.EthereumAddress,
    withdrawAssetParameter: WithdrawAssetParameter
  ) async throws -> String? {
    let rpcURL = try getRpcURL()
    let contractJsonABI = try getContractJsonABI()
    
    guard let url = URL(string: rpcURL)
    else {
      log.error("Portal Swift: Error building transaction for withdrawal. PRC URL is missing")
      throw LFPortalError.unexpected
    }
    
    let web3 = try await Web3.new(url)
    let contract = web3.contract(
      contractJsonABI,
      at: ethereumContractAddress,
      abiVersion: 2
    )
    
    guard let tx = contract?
      .createWriteOperation(
        "withdrawAsset",
        parameters: [
          withdrawAssetParameter.proxyAddress,
          withdrawAssetParameter.tokenAddress,
          withdrawAssetParameter.amount,
          withdrawAssetParameter.recipientAddress,
          withdrawAssetParameter.expiryAt,
          withdrawAssetParameter.salt,
          withdrawAssetParameter.signature,
          [withdrawAssetParameter.adminSalt],
          [withdrawAssetParameter.adminSignature],
          true
        ]
      )?
      .data?
      .toHexString()
    else {
      log.error("Portal Swift: Error building transaction for withdrawal. Could not encode withdrawAsset contract function")
      throw LFPortalError.unexpected
    }
    
    return "0x" + tx
  }
  
  private func buildErc20Transaction(
    contractAddress: String?,
    toAddress: String,
    amount: BigUInt
  ) async throws -> String? {
    try await withCheckedThrowingContinuation { [weak self] (continuation: CheckedContinuation<String?, Error>) in
      guard let self
      else {
        continuation.resume(throwing: LFPortalError.unexpected)
        return
      }
      
      guard let walletAddress else {
        log.error("Portal Swift: Error estimating fee. Wallet missing")
        continuation.resume(throwing: LFPortalError.walletMissing)
        return
      }
      
      guard let contractAddress
      else {
        continuation.resume(returning: nil)
        return
      }
      
      do {
        let rpcURL = try getRpcURL()
        let ethereumFromAddress = EthereumAddress(hexString: walletAddress)
        
        let web3 = Web3(rpcURL: rpcURL)
        let contract = web3.eth.Contract(
          type: GenericERC20Contract.self,
          address: EthereumAddress(hexString: contractAddress)
        )
        
        guard let ethereumToAddress = EthereumAddress(hexString: toAddress),
              let tx = contract
          .transfer(
            to: ethereumToAddress,
            value: amount
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
  
  private func getAdminSignature(
    addresses: WithdrawAssetAddresses,
    walletAddress: String,
    amount: BigUInt
  ) async throws -> (salt: Data, signature: Data) {
    let nonce = try await getLatestNonce(proxyAddress: addresses.proxyAddress)
    let salt = generateSalt()
    
    guard let portal
    else {
      throw LFPortalError.unexpected
    }
    
    let messageToSign = try createEIP712Message(
      collateralProxyAddress: addresses.proxyAddress,
      walletAddress: walletAddress,
      tokenAddress: addresses.tokenAddress,
      amount: amount,
      recipientAddress: addresses.recipientAddress,
      salt: "0x" + salt.toHexString(),
      nonce: nonce
    )
    
    let response = try await portal.request("eip155:\(chainId)", withMethod: .eth_signTypedData_v4, andParams: [walletAddress, messageToSign])
    
    guard let signatureString = (response.result as? String),
          let signatureData = Data(hexString: signatureString, length: 65)
    else {
      log.error("Portal Swift: Error getting admin signature. Could not build Data for signature data or signature string is missing")
      throw LFPortalError.unexpected
    }
    
    return (salt, signatureData)
  }
  
  private func getLatestNonce(
    proxyAddress: String
  ) async throws -> BigUInt {
    let rpcURL = try getRpcURL()
    let collateralJsonABI = try getCollateralJsonABI()
    
    guard let url = URL(string: rpcURL),
          let ethereumCollateralAddress = Web3Core.EthereumAddress(proxyAddress)
    else {
      log.error("Portal Swift: Error getting contract's nonce. Could not build proxy address or RPC URL is missing")
      throw LFPortalError.unexpected
    }
    
    let web3 = try await Web3.new(url)
    let contract = web3.contract(
      collateralJsonABI,
      at: ethereumCollateralAddress,
      abiVersion: 2
    )
    
    let response = try await contract?
      .createWriteOperation(
        "adminNonce"
      )?
      .callContractMethod()
    
    guard let nonce = response?["0"] as? BigUInt
    else {
      log.error("Portal Swift: Error getting contract's nonce. Nonce is missing in the response")
      throw LFPortalError.unexpected
    }
    
    return nonce
  }
  
  private func sendTransactionToBlockchain(
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
  
  private func estimateTransactionFee(address: String, params: ETHTransactionParam) async throws -> Double {
    // Fetch estimated gas for the transaction
    let estimateGas = try await fetchGasData(method: .eth_estimateGas, address: address, params: [params])
    
    // Fetch current gas price
    let gasPrice = try await fetchGasData(method: .eth_gasPrice, address: address).weiToEth
    
    // Calculate the total fees
    let txFee: Double = estimateGas * gasPrice
    
    log.debug("Portal Swift: Transaction fee estimation success for \(address). tx fee: \(txFee)")
    return(txFee)
  }
  
  private func fetchGasData(method: PortalRequestMethod, address: String, params: [Any] = []) async throws -> Double {
    // Throw an error if Portal clent instance is not ready
    guard let portal else {
      log.error("Portal Swift: Error estimating fee for \(address). Portal instance is unavailable")
      throw(LFPortalError.portalInstanceUnavailable)
    }
    
    let response = try await portal.request(
      "eip155:\(chainId)",
      withMethod: method,
      andParams: params
    )
    
    guard let rpcResponse = response.result as? PortalProviderRpcResponse,
          let result = rpcResponse.result?.asDouble else {
      log.error("Portal Swift: Error fetching \(method) for \(address). Unexpected RPC response")
      throw LFPortalError.unexpected
    }
    
    return result
  }
  
  private func getRpcURL() throws -> String {
    guard let rpcURL = portal?.rpcConfig["eip155:\(chainId)"] else {
      log.error("Portal Swift: Error building ERC20 transaction. rpcURL is unavailable")
      throw LFPortalError.unexpected
    }
    
    return rpcURL
  }
  
  private func getContractJsonABI() throws -> String {
    guard let contractABIJsonString = FileHelpers.readJSONFile(forName: "contractJsonABI", type: String.self)
    else {
      log.error("Portal Swift: Error building ERC20 transaction. ContractJsonABI is unavailable")
      throw LFPortalError.unexpected
    }
    
    return contractABIJsonString
  }
  
  private func getCollateralJsonABI() throws -> String {
    guard let contractABIJsonString = FileHelpers.readJSONFile(forName: "collateralJsonABI", type: String.self)
    else {
      log.error("Portal Swift: Error building ERC20 transaction. ContractJsonABI is unavailable")
      throw LFPortalError.unexpected
    }
    
    return contractABIJsonString
  }
  
  func generateSalt() -> Data {
    // Generate random 32-byte salt
    var randomBytes = [UInt8](repeating: 0, count: 32)
    _ = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    
    return Data(randomBytes)
  }
  
  private func createEIP712Message(
    collateralProxyAddress: String,
    walletAddress: String,
    tokenAddress: String,
    amount: BigUInt,
    recipientAddress: String,
    salt: String,
    nonce: BigUInt
  ) throws -> String {
    // Build message to sign for obtaining adming signature
    let domain: [String: Any] = [
      "name": "Collateral",
      "version": "2",
      "chainId": chainId,
      "verifyingContract": collateralProxyAddress,
      "salt": salt
    ]
    
    let types: [String: Any] = [
      "EIP712Domain": [
        ["name": "name", "type": "string"],
        ["name": "version", "type": "string"],
        ["name": "chainId", "type": "uint256"],
        ["name": "verifyingContract", "type": "address"],
        ["name": "salt", "type": "bytes32"]
      ],
      "Withdraw": [
        ["name": "user", "type": "address"],
        ["name": "asset", "type": "address"],
        ["name": "amount", "type": "uint256"],
        ["name": "recipient", "type": "address"],
        ["name": "nonce", "type": "uint256"]
      ]
    ]
    
    let message: [String: Any] = [
      "user": walletAddress,
      "asset": tokenAddress,
      "amount": amount.description,
      "recipient": recipientAddress,
      "nonce": nonce.description
    ]
    
    let messageToSign: [String: Any] = [
      "types": types,
      "domain": domain,
      "primaryType": "Withdraw",
      "message": message
    ]
    
    let jsonData = try JSONSerialization.data(withJSONObject: messageToSign, options: [.sortedKeys])
    guard let messageString = String(data: jsonData, encoding: .utf8)
    else {
      log.error("Portal Swift: Error EIP712 message. Could not build message string")
      throw LFPortalError.unexpected
    }
    
    return messageString
  }
}

// MARK: - Types
extension PortalService {
  public struct WithdrawAssetAddresses {
    public let contractAddress: String
    public let proxyAddress: String
    public let recipientAddress: String
    public let tokenAddress: String
    
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
    let proxyAddress: Web3Core.EthereumAddress
    let tokenAddress: Web3Core.EthereumAddress
    let amount: BigUInt
    let recipientAddress: Web3Core.EthereumAddress
    let expiryAt: BigUInt
    let salt: Data
    let signature: Data
    let adminSalt: Data
    let adminSignature: Data
  }
}
