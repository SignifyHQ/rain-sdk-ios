import Foundation
import Web3
import Web3Core

// MARK: Internal helpers for RainSdkManager (RainClient)
extension RainSdkManager {
  /// Maps an error thrown on a withdrawal flow (`withdrawCollateral` / `estimateWithdrawalFee`).
  /// A simulation revert on this path means the network rejected the withdrawal itself (e.g. a
  /// duplicate withdrawal or an already-used signature), so it surfaces as
  /// `.withdrawalRevertedByNetwork` (RAIN_405) here and only here; plain sends and reads keep
  /// `.transactionSimulationFailed` (RAIN_403) / their own codes.
  func mapWithdrawalError(_ error: Error) -> RainSDKError {
    let mapped = RainSDKError.from(underlying: error)
    if case .transactionSimulationFailed = mapped {
      return .withdrawalRevertedByNetwork
    }
    return mapped
  }

  /// Rejects withdrawal parameters that cannot produce a valid transaction, before any network
  /// call or signature prompt. Mirrors Android's `TransactionValidator.validateWithdrawRequest`.
  func validateWithdrawRequest(chainId: Int, amount: Decimal, decimals: Int) throws {
    guard chainId > 0 else {
      throw RainSDKError.invalidConfig(chainId: chainId, rpcUrl: "")
    }
    guard amount > 0 else {
      throw RainSDKError.invalidAmount(
        amount: "\(amount)",
        reason: "amount must be greater than zero"
      )
    }
    guard decimals >= 0 else {
      throw RainSDKError.invalidAmount(
        amount: "\(amount)",
        reason: "decimals must be non-negative, got \(decimals)"
      )
    }
  }

  /// Composes and submits a Solana collateral withdrawal.
  ///
  /// On Solana the withdrawal is authorized by Rain's coordinator executor signing a keccak
  /// message off chain (the admin signature) rather than by EIP-712 calldata, so core composes the
  /// transaction and the provider only signs the bytes it is handed.
  func withdrawSolanaCollateral(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Decimal,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String
  ) async throws -> String {
    guard let solanaProvider = walletProvider as? any RainSolanaTransfersProvider else {
      throw RainSDKError.internalLogicError(
        details: "The active wallet provider does not support Solana transfers"
      )
    }

    let owner = try await walletProvider.getAddress(chainId: chainId)
    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)

    let unsigned = try await solanaWithdrawComposer.composeWithdraw(
      chainId: chainId,
      ownerAddress: owner,
      collateralAddress: assetAddresses.proxyAddress,
      mintAddress: assetAddresses.tokenAddress,
      recipientAddress: assetAddresses.recipientAddress,
      amountBaseUnits: amountBaseUnits,
      adminSignature: RainAdminSignature(salt: salt, signature: signature, expiresAt: expiresAt)
    )

    let txSignature = try await solanaProvider.signAndSendSolanaTransaction(
      chainId: chainId,
      unsigned: unsigned
    )
    RainLogger.info("Rain SDK: Solana withdrawal submitted. Signature: \(txSignature)")
    return txSignature
  }

  /// Builds withdrawal transaction params: EIP-712 message, admin signature via the backing
  /// provider, and calldata. Returns the wallet address and wallet transaction params ready for
  /// fee estimation or submission.
  func buildTransactionParamForWithdrawAsset(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Decimal,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String,
    nonce: BigUInt?
  ) async throws -> (walletAddress: String, transactionParams: WalletTransactionParams) {
    guard let signerProvider = walletProvider as? any RainTypedDataSignerProvider else {
      throw RainSDKError.internalLogicError(
        details: "Current wallet provider does not support EIP-712 signing"
      )
    }

    let walletAddress = try await walletProvider.address()

    // `withdrawAsset` verifies the withdrawal signature against the collateral's admin set, so a
    // non-admin signer reverts on-chain with `InvalidSignature()`. Only a definitive `false`
    // blocks — an unknown result proceeds, so a check that cannot run never blocks a withdrawal.
    if await transactionBuilderService.isCollateralAdmin(
      proxyAddress: assetAddresses.proxyAddress,
      walletAddress: walletAddress,
      chainId: chainId
    ) == false {
      throw RainSDKError.walletNotAuthorized(
        walletAddress: walletAddress,
        proxyAddress: assetAddresses.proxyAddress
      )
    }

    guard let withdrawalSaltData = Data(base64Encoded: salt) else {
      throw RainSDKError.internalLogicError(details: "Failed to convert withdrawal salt base 64 string to Data")
    }

    guard let withdrawalSignatureData = Data(hexString: signature, length: 65) else {
      throw RainSDKError.internalLogicError(details: "Failed to convert withdrawal signature hex string to Data")
    }

    let eip712Addresses = EIP712AssetAddresses(
      proxyAddress: assetAddresses.proxyAddress,
      recipientAddress: assetAddresses.recipientAddress,
      tokenAddress: assetAddresses.tokenAddress
    )
    let (eip712Message, adminSaltHex) = try await buildEIP712Message(
      chainId: chainId,
      walletAddress: walletAddress,
      assetAddresses: eip712Addresses,
      amount: amount,
      decimals: decimals,
      nonce: nonce
    )
    let adminSignatureString = try await signerProvider.signTypedData(
      chainId: chainId,
      walletAddress: walletAddress,
      typedData: eip712Message
    )

    guard let adminSaltData = Data.fromHex(adminSaltHex) else {
      throw RainSDKError.internalLogicError(details: "Failed to convert admin salt hex string to Data")
    }

    guard let adminSignatureData = Data(hexString: adminSignatureString, length: 65) else {
      throw RainSDKError.internalLogicError(details: "Failed to convert admin signature hex string to Data or invalid length")
    }

    let transactionData = try await buildWithdrawTransactionData(
      chainId: chainId,
      assetAddresses: assetAddresses,
      amount: amount,
      decimals: decimals,
      expiresAt: expiresAt,
      salt: withdrawalSaltData,
      signatureData: withdrawalSignatureData,
      adminSalt: adminSaltData,
      adminSignature: adminSignatureData
    )

    let transactionParams = WalletTransactionParams(
      from: walletAddress,
      to: assetAddresses.contractAddress,
      value: 0.ethToWei.toHexString,
      data: transactionData
    )

    return (walletAddress, transactionParams)
  }

  /// Estimates total transaction fee (estimated gas × gas price) in native token via the backing provider.
  func estimateTransactionFee(chainId: Int, address: String, params: WalletTransactionParams) async throws -> Decimal {
    guard let estimatingProvider = walletProvider as? any RainTransactionFeeEstimatingProvider else {
      throw RainSDKError.internalLogicError(
        details: "Current wallet provider does not support fee estimation"
      )
    }

    return try await estimatingProvider.estimateTransactionFee(
      chainId: chainId,
      walletAddress: address,
      params: params
    )
  }

  // MARK: - Transaction building (bound to this client's shared services)

  /// Builds an EIP-712 message (and its salt) for the admin signature required for withdrawals.
  func buildEIP712Message(
    chainId: Int,
    walletAddress: String,
    assetAddresses: EIP712AssetAddresses,
    amount: Decimal,
    decimals: Int,
    nonce: BigUInt?
  ) async throws -> (String, String) {
    let salt = transactionBuilderService.generateSalt()
    let saltHex = "0x" + salt.toHexString()

    let finalNonce: BigUInt
    if let providedNonce = nonce {
      finalNonce = providedNonce
    } else {
      finalNonce = try await transactionBuilderService.getLatestNonce(
        proxyAddress: assetAddresses.proxyAddress,
        chainId: chainId
      )
    }

    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    let jsonMessage = try transactionBuilderService.buildEIP712Message(
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

  /// Builds the encoded withdrawal calldata for the collateral proxy contract.
  func buildWithdrawTransactionData(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Decimal,
    decimals: Int,
    expiresAt: String,
    salt: Data,
    signatureData: Data,
    adminSalt: Data,
    adminSignature: Data
  ) async throws -> String {
    guard let ethereumContractAddress = Web3Core.EthereumAddress(assetAddresses.contractAddress),
          let ethereumProxyAddress = Web3Core.EthereumAddress(assetAddresses.proxyAddress),
          let ethereumTokenAddress = Web3Core.EthereumAddress(assetAddresses.tokenAddress),
          let ethereumRecipientAddress = Web3Core.EthereumAddress(assetAddresses.recipientAddress)
    else {
      throw RainSDKError.internalLogicError(
        details: "Error building transaction parameters for withdrawal. One of the addresses could not be built"
      )
    }

    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)

    let unixTimestamp: Int
    if let timestamp = Int(expiresAt) {
      unixTimestamp = timestamp
    } else if let date = RainSdk.parseISO8601(expiresAt) {
      unixTimestamp = Int(date.timeIntervalSince1970)
    } else {
      throw RainSDKError.internalLogicError(
        details: "Invalid expiration timestamp format. Expected ISO8601 or Unix timestamp string"
      )
    }

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

    return try await transactionBuilderService.buildErc20TransactionForWithdrawAsset(
      chainId: chainId,
      ethereumContractAddress: ethereumContractAddress,
      withdrawAssetParameter: withdrawAssetParameter
    )
  }
}
