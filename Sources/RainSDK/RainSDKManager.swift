import Foundation
import CoreGraphics
import PortalSwift
import QRCode
import TurnkeySwift
import Web3
import Web3Core
import web3swift
import Web3ContractABI

public final class RainSDKManager: RainSDK {
  // MARK: - Properties

  // Internal storage for Portal instance (using protocol for testability)
  private var _portal: PortalRequestProtocol?
  private var _turnkey: TurnkeyContextProtocol?

  /// Wallet provider for address, balance, signing, and submission.
  /// Set when `initializePortal` or `initializeTurnkey` is used; nil in wallet-agnostic mode.
  var _walletProvider: (any RainWalletProvider)?
  
  // Transaction builder service
  private var _transactionBuilder: TransactionBuilderProtocol?
  
  private var _networkConfigs: [NetworkConfig] = []

  /// Token metadata store shared with the active wallet provider. Nil in wallet-agnostic mode.
  private var _tokenStore: TokenMetadataStore?

  /// Host-registered tokens, retained so they re-seed the store on each (re)initialization.
  private var _registeredTokens: [TokenInfo] = []

  /// Throws `sdkNotInitialized` if Portal has not been initialized, or if the stored
  /// `PortalRequestProtocol` is a mock (use `portalProtocol` for test contexts).
  public var portal: Portal {
    get throws {
      guard let portalProtocol = _portal
      else {
        throw RainSDKError.sdkNotInitialized
      }
      
      // Cast to Portal for public API
      guard let portal = portalProtocol as? Portal
      else {
        throw RainSDKError.sdkNotInitialized
      }
      
      return portal
    }
  }

  /// Throws `sdkNotInitialized` if Turnkey has not been initialized, or if the stored
  /// context is a mock.
  public var turnkey: TurnkeyContext {
    get throws {
      guard let turnkeyProtocol = _turnkey else {
        throw RainSDKError.sdkNotInitialized
      }

      guard let turnkey = turnkeyProtocol as? TurnkeyContext else {
        throw RainSDKError.sdkNotInitialized
      }

      return turnkey
    }
  }
  
  /// Internal property for testing - returns PortalRequestProtocol which works with both Portal and MockPortal
  /// Use this property in tests when working with mocks
  internal var portalProtocol: PortalRequestProtocol? {
    return _portal
  }

  internal var turnkeyProtocol: TurnkeyContextProtocol? {
    return _turnkey
  }
  
  /// Internal: use for all Portal requests so that both Portal and MockPortal work in production and tests.
  /// Throws if SDK is not initialized.
  internal var portalForRequest: PortalRequestProtocol {
    get throws {
      guard let portal = _portal else { throw RainSDKError.sdkNotInitialized }
      return portal
    }
  }
  
  // MARK: - Initialization
  public init() {}

  /// Designated internal initializer used by tests to inject any combination of Portal,
  /// Turnkey, and transaction-builder mocks. Pass `portal` *or* `turnkey` (not both);
  /// the wallet provider is built from whichever is supplied.
  internal init(
    portal: PortalRequestProtocol? = nil,
    turnkey: TurnkeyContextProtocol? = nil,
    transactionBuilder: TransactionBuilderProtocol? = nil,
    networkConfigs: [NetworkConfig] = [],
    walletAddress: String? = nil
  ) {
    self._portal = portal
    self._turnkey = turnkey
    self._transactionBuilder = transactionBuilder
    self._networkConfigs = networkConfigs

    let reader = EVMChainReader(networkConfigs: networkConfigs)
    let store = TokenMetadataStore(chainReader: reader)

    if let portal {
      self._tokenStore = store
      self._walletProvider = PortalWalletProviderAdapter(
        portal: portal,
        transactionBuilder: transactionBuilder,
        tokenStore: store
      )
    } else if let turnkey {
      self._tokenStore = store
      self._walletProvider = TurnkeyWalletProviderAdapter(
        turnkey: turnkey,
        transactionBuilder: transactionBuilder,
        networkConfigs: networkConfigs,
        walletAddress: walletAddress,
        chainReader: reader,
        tokenStore: store
      )
    }
  }
  
  public func initializePortal(
    portalSessionToken: String,
    networkConfigs: [NetworkConfig]
  ) async throws {
    // Validate inputs
    try validateInputs(portalSessionToken: portalSessionToken, networkConfigs: networkConfigs)

    // Store network configs
    _networkConfigs = networkConfigs

    // Convert network configs to Portal format
    let eip155RpcEndpointsConfig = try buildRpcConfig(from: networkConfigs)
    
    do {
      // Initialize Portal instance
      let portal = try Portal(
        portalSessionToken,
        withRpcConfig: eip155RpcEndpointsConfig,
        autoApprove: true,
        iCloud: ICloudStorage(),
        keychain: PortalKeychain(),
        passwords: PasswordStorage()
      )
      
      // Store portal instance (Portal conforms to PortalProtocol via extension)
      _portal = portal
      _turnkey = nil
      // Initialize transaction builder service with network configs
      let transactionBuilder = TransactionBuilderService(networkConfigs: networkConfigs)
      _transactionBuilder = transactionBuilder
      let reader = EVMChainReader(networkConfigs: networkConfigs)
      let store = TokenMetadataStore(chainReader: reader, seedTokens: _registeredTokens)
      _tokenStore = store
      _walletProvider = PortalWalletProviderAdapter(
        portal: portal,
        transactionBuilder: transactionBuilder,
        tokenStore: store
      )
      
      RainLogger.info("Rain SDK: Registered Portal instance successfully with \(networkConfigs.count) network(s)")
    } catch let error as RainSDKError {
      RainLogger.error("Rain SDK: Initialization error - \(error.localizedDescription)")
      throw error
    } catch {
      RainLogger.error("Rain SDK: Portal SDK error - \(error.localizedDescription)")
      throw RainSDKError.from(underlying: error)
    }
  }

  public func initializeTurnkey(
    turnkey: TurnkeyContext,
    networkConfigs: [NetworkConfig],
    walletAddress: String? = nil
  ) async throws {
    try validateNetworkConfigs(networkConfigs)

    let transactionBuilder = TransactionBuilderService(networkConfigs: networkConfigs)
    let reader = EVMChainReader(networkConfigs: networkConfigs)
    let store = TokenMetadataStore(chainReader: reader, seedTokens: _registeredTokens)
    let provider = TurnkeyWalletProviderAdapter(
      turnkey: turnkey,
      transactionBuilder: transactionBuilder,
      networkConfigs: networkConfigs,
      walletAddress: walletAddress,
      chainReader: reader,
      tokenStore: store
    )

    do {
      _ = try await provider.address()

      _networkConfigs = networkConfigs
      _portal = nil
      _turnkey = turnkey
      _transactionBuilder = transactionBuilder
      _tokenStore = store
      _walletProvider = provider

      RainLogger.info("Rain SDK: Registered Turnkey context successfully with \(networkConfigs.count) network(s)")
    } catch {
      RainLogger.error("Rain SDK: Turnkey initialization error - \(error.localizedDescription)")
      throw RainSDKError.from(underlying: error)
    }
  }
  
  public func initialize(
    networkConfigs: [NetworkConfig]
  ) async throws {
    // Validate network configs
    try validateNetworkConfigs(networkConfigs)

    // Store network configs; no wallet provider in wallet-agnostic mode
    _networkConfigs = networkConfigs
    _portal = nil
    _turnkey = nil
    _walletProvider = nil
    _tokenStore = nil

    // Initialize transaction builder service with network configs
    _transactionBuilder = TransactionBuilderService(networkConfigs: networkConfigs)
    
    RainLogger.info("Rain SDK: Initialized in wallet-agnostic mode with \(networkConfigs.count) network(s)")
  }

  public func setWalletProvider(_ provider: (any RainWalletProvider)?) {
    _walletProvider = provider
  }

  /// Clears all SDK state — wallet provider, Portal/Turnkey instances, transaction
  /// builder, and network configs. After this returns, the SDK is back to the same
  /// state as immediately after `init()`. Idempotent.
  public func reset() {
    _portal = nil
    _turnkey = nil
    _walletProvider = nil
    _transactionBuilder = nil
    _networkConfigs = []
    _tokenStore = nil
    _registeredTokens = []
    RainLogger.info("Rain SDK: Reset SDK state")
  }

  public func buildEIP712Message(
    chainId: Int,
    walletAddress: String,
    assetAddresses: EIP712AssetAddresses,
    amount: Double,
    decimals: Int,
    nonce: BigUInt?
  ) async throws -> (String, String) {
    // Ensure SDK is initialized with network configs
    guard let transactionBuilder = _transactionBuilder else {
      throw RainSDKError.sdkNotInitialized
    }
    
    // Generate or reuse salt (store internally for later use in transaction building)
    let salt = transactionBuilder.generateSalt()
    // Convert salt to hex string (bytes32 format)
    let saltHex = "0x" + salt.toHexString()
    
    // Get nonce - retrieve from network if not provided
    let finalNonce: BigUInt
    if let providedNonce = nonce {
      finalNonce = providedNonce
    } else {
      // Retrieve nonce from contract
      finalNonce = try await transactionBuilder.getLatestNonce(
        proxyAddress: assetAddresses.proxyAddress,
        chainId: chainId
      )
      RainLogger.debug("Rain SDK: Retrieved nonce \(finalNonce) from contract")
    }
    
    // Amount is already in smallest units (as per protocol documentation)
    // Convert Double to BigUInt
    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    
    // Build EIP-712 message using service
    let jsonMessage = try transactionBuilder.buildEIP712Message(
      chainId: chainId,
      collateralProxyAddress: assetAddresses.proxyAddress,
      walletAddress: walletAddress,
      tokenAddress: assetAddresses.tokenAddress,
      amount: amountBaseUnits,
      recipientAddress: assetAddresses.recipientAddress,
      nonce: finalNonce,
      salt: saltHex
    )
    return (jsonMessage, saltHex)
  }
  
  public func buildWithdrawTransactionData(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    expiresAt: String,
    salt: Data,
    signatureData: Data,
    adminSalt: Data,
    adminSignature: Data
  ) async throws -> String {
    // Ensure SDK is initialized with network configs
    guard let transactionBuilder = _transactionBuilder else {
      throw RainSDKError.sdkNotInitialized
    }
    
    // Convert string addresses to Web3Core.EthereumAddress objects
    guard let ethereumContractAddress = Web3Core.EthereumAddress(assetAddresses.contractAddress),
          let ethereumProxyAddress = Web3Core.EthereumAddress(assetAddresses.proxyAddress),
          let ethereumTokenAddress = Web3Core.EthereumAddress(assetAddresses.tokenAddress),
          let ethereumRecipientAddress = Web3Core.EthereumAddress(assetAddresses.recipientAddress)
    else {
      RainLogger.error("Rain SDK: Error building transaction parameters for withdrawal. One of the addresses could not be built")
      throw RainSDKError.internalLogicError(
        details: "Error building transaction parameters for withdrawal. One of the addresses could not be built"
      )
    }
    
    // Convert the amount to base units using decimals of the token
    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    
    // Convert the expiration timestamp string from Rain API to Unix Timestamp
    // Expects ISO8601 format or Unix timestamp string
    let unixTimestamp: Int
    if let timestamp = Int(expiresAt) {
      unixTimestamp = timestamp
    } else if let date = ISO8601DateFormatter().date(from: expiresAt) {
      unixTimestamp = Int(date.timeIntervalSince1970)
    } else {
      RainLogger.error("Rain SDK: Error building transaction parameters for withdrawal. Could not parse expiration to UNIX timestamp")
      throw RainSDKError.internalLogicError(
        details: "Invalid expiration timestamp format. Expected ISO8601 or Unix timestamp string"
      )
    }
    
    // Build WithdrawAssetParameter struct
    let withdrawAssetParameter = WithdrawAssetParameter(
      proxyAddress: ethereumProxyAddress,
      tokenAddress: ethereumTokenAddress,
      amount: amountBaseUnits,
      recipientAddress: ethereumRecipientAddress,
      expiryAt: BigUInt(unixTimestamp),
      salt: salt,
      signature: signatureData,
      adminSalt: adminSalt,
      adminSignature: adminSignature
    )
    
    // Build transaction data using service
    return try await transactionBuilder.buildErc20TransactionForWithdrawAsset(
      chainId: chainId,
      ethereumContractAddress: ethereumContractAddress,
      withdrawAssetParameter: withdrawAssetParameter
    )
  }
  
  public func composeTransactionParameters(
    walletAddress: String,
    contractAddress: String,
    transactionData: String
  ) -> ETHTransactionParam {
    return ETHTransactionParam(
      from: walletAddress,
      to: contractAddress,
      value: 0.ethToWei.toHexString,
      data: transactionData
    )
  }
  
  public func withdrawCollateral(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?
  ) async throws -> String {
    do {
      let (_, transactionParams) = try await buildTransactionParamForWithdrawAsset(
        chainId: chainId,
        assetAddresses: assetAddresses,
        amount: amount,
        decimals: decimals,
        salt: salt,
        signature: signature,
        expiresAt: expiresAt,
        nonce: nil
      )
      
      guard let provider = _walletProvider else {
        throw RainSDKError.sdkNotInitialized
      }

      let txHash = try await provider.sendTransaction(
        chainId: chainId,
        params: transactionParams
      )

      RainLogger.info("Rain SDK: Withdrawal transaction submitted. Hash: \(txHash)")
      return txHash
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }
  
  public func estimateWithdrawalFee(
    chainId: Int,
    addresses: WithdrawAssetAddresses,
    amount: Double,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String
  ) async throws -> Double {
    do {
      let (walletAddress, transactionParams) = try await buildTransactionParamForWithdrawAsset(
        chainId: chainId,
        assetAddresses: addresses,
        amount: amount,
        decimals: decimals,
        salt: salt,
        signature: signature,
        expiresAt: expiresAt,
        nonce: nil
      )
      return try await estimateTransactionFee(
        chainId: chainId,
        address: walletAddress,
        params: transactionParams
      )
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  // MARK: - Wallet information

  /// Returns the current wallet address from the wallet provider.
  public func getWalletAddress(
  ) async throws -> String {
    do {
      guard let provider = _walletProvider else {
        throw RainSDKError.walletUnavailable
      }
      
      return try await provider.address()
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  /// Returns the wallet address for `chainId`'s chain family (Solana account for Solana
  /// sentinel chains, EVM address otherwise).
  public func getWalletAddress(
    chainId: Int
  ) async throws -> String {
    do {
      guard let provider = _walletProvider else {
        throw RainSDKError.walletUnavailable
      }

      return try await provider.getAddress(chainId: chainId)
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  /// Generates a square QR code image (PNG) encoding the current wallet address.
  public func generateWalletAddressQRCode(
    dimension: Int = 256,
    backgroundColor: CGColor? = nil,
    foregroundColor: CGColor? = nil
  ) async throws -> Data {
    let address = try await getWalletAddress()
    let bg = backgroundColor ?? CGColor(red: 0, green: 0, blue: 0, alpha: 1)
    let fg = foregroundColor ?? CGColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    guard let image = try? QRCode.build
      .text(address)
      .foregroundColor(fg)
      .backgroundColor(bg)
      .background.cornerRadius(0)
      .onPixels.shape(QRCode.PixelShape.RoundedPath(cornerRadiusFraction: 0))
      .eye.shape(QRCode.EyeShape.RoundedRect())
      .pupil.shape(QRCode.PupilShape.Square())
      .generate.image(dimension: dimension, representation: .png())
    else {
      throw RainSDKError.internalLogicError(details: "QR code image generation failed")
    }
    
    return image
  }

  // MARK: - Fetch balances

  /// Fetches a single balance (native or a contract token) for the current wallet via the wallet provider.
  public func getBalance(
    chainId: Int,
    token: Token
  ) async throws -> Balance {
    do {
      guard let provider = _walletProvider else {
        throw RainSDKError.walletUnavailable
      }

      return try await provider.getBalance(chainId: chainId, token: token)
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  /// Fetches all non-zero balances (native always included) for the current wallet on the given network.
  public func getBalances(
    chainId: Int
  ) async throws -> [Balance] {
    do {
      guard let provider = _walletProvider else {
        throw RainSDKError.walletUnavailable
      }

      return try await provider.getBalances(chainId: chainId)
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  /// Fetches balances across every configured chain in parallel, flattened into one list.
  /// Each `Balance` carries its own `chainId`. A chain that fails contributes no entries
  /// rather than failing the whole call, so one bad RPC endpoint doesn't hide the others.
  public func getAllBalances() async throws -> [Balance] {
    guard let provider = _walletProvider else {
      throw RainSDKError.walletUnavailable
    }
    let chainIds = _networkConfigs.map(\.chainId)
    return await withTaskGroup(of: [Balance].self) { group in
      for chainId in chainIds {
        group.addTask {
          (try? await provider.getBalances(chainId: chainId)) ?? []
        }
      }
      var output: [Balance] = []
      for await balances in group {
        output.append(contentsOf: balances)
      }
      return output
    }
  }

  /// Registers additional tokens so their metadata resolves from the store without an
  /// on-chain enrichment call. Retained across re-initialization; cleared by `reset()`.
  public func registerTokens(_ tokens: [TokenInfo]) {
    _registeredTokens.append(contentsOf: tokens)
    if let store = _tokenStore {
      Task { await store.register(tokens) }
    }
  }

  /// Fetches transaction history for the current wallet on the given network using Portal's `getTransactions` API via the wallet provider.
  public func getTransactions(
    chainId: Int,
    limit: Int? = nil,
    offset: Int? = nil,
    order: WalletTransactionOrder? = nil
  ) async throws -> [WalletTransaction] {
    do {
      guard let provider = _walletProvider else {
        throw RainSDKError.walletUnavailable
      }
      
      return try await provider.getTransactions(
        chainId: chainId,
        limit: limit,
        offset: offset,
        order: order
      )
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  // MARK: - Send tokens

  /// Sends native tokens (e.g. ETH, AVAX). Requires a wallet provider (e.g. `initializePortal` or `setWalletProvider`).
  public func sendNativeToken(
    chainId: Int,
    to: String,
    amount: Double
  ) async throws -> String {
    do {
      guard let provider = _walletProvider else {
        throw RainSDKError.walletUnavailable
      }

      // Solana sends use lamport scaling and a dedicated capability, not the EVM 1e18 path.
      if SolanaChains.isSolana(chainId) {
        guard let solanaProvider = provider as? any RainSolanaTransfersProvider else {
          throw RainSDKError.internalLogicError(
            details: "The active wallet provider does not support Solana transfers"
          )
        }
        return try await solanaProvider.sendSolanaNative(chainId: chainId, to: to, amount: amount)
      }

      let from = try await provider.address()
      let params = WalletTransactionParams(
        from: from,
        to: to,
        value: amount.ethToWei.toHexString,
        data: .empty
      )

      return try await provider.sendTransaction(
        chainId: chainId,
        params: params
      )
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  /// Sends ERC-20 tokens. Requires SDK initialized with network configs and a wallet provider.
  public func sendERC20Token(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Double,
    decimals: Int
  ) async throws -> String {
    do {
      if SolanaChains.isSolana(chainId) {
        throw RainSDKError.internalLogicError(
          details: "SPL token transfers are not supported on Solana chainId=\(chainId)"
        )
      }

      guard let transactionBuilder = _transactionBuilder else {
        throw RainSDKError.sdkNotInitialized
      }

      guard let provider = _walletProvider else {
        throw RainSDKError.walletUnavailable
      }

      let from = try await provider.address()
      let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
      let data = try await transactionBuilder.buildERC20TransferData(
        chainId: chainId,
        contractAddress: contractAddress,
        walletAddress: from,
        toAddress: to,
        amount: amountBaseUnits
      )
      
      let params = WalletTransactionParams(
        from: from,
        to: contractAddress,
        value: 0.ethToWei.toHexString,
        data: data
      )
      
      return try await provider.sendTransaction(
        chainId: chainId,
        params: params
      )
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }
}
