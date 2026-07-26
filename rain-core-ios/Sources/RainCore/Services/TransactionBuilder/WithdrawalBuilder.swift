import Foundation
import Web3
import Web3Core

/// The wallet-agnostic withdrawal-building steps, in one place.
///
/// Both the public surface (``RainSdk``) and the resolved-client path (``RainSdkManager``, behind
/// `withdrawCollateral`) call through here, so there is a single implementation to keep correct.
enum WithdrawalBuilder {

  /// Builds the EIP-712 message the wallet signs, generating the salt bound into it.
  static func buildEIP712Message(
    builder: TransactionBuilderProtocol,
    chainId: Int,
    walletAddress: String,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    nonce: BigUInt?
  ) async throws -> RainEIP712Message {
    // Validate + checksum up front so the signed message can never carry an unvalidated or
    // differently-cased address than the calldata built later.
    let validated = try addresses.validated()
    let validWallet = try RainWithdrawAddresses.checksummed(walletAddress, label: "walletAddress")

    let salt = builder.generateSalt()
    let saltHex = "0x" + salt.toHexString()

    let finalNonce: BigUInt
    if let providedNonce = nonce {
      finalNonce = providedNonce
    } else {
      finalNonce = try await builder.getLatestNonce(
        proxyAddress: validated.proxyAddress,
        chainId: chainId
      )
    }

    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    let jsonMessage = try builder.buildEIP712Message(
      chainId: chainId,
      collateralProxyAddress: validated.proxyAddress,
      walletAddress: validWallet,
      tokenAddress: validated.tokenAddress,
      amount: amountBaseUnits,
      recipientAddress: validated.recipientAddress,
      nonce: finalNonce,
      salt: saltHex
    )
    return RainEIP712Message(message: jsonMessage, salt: salt)
  }

  /// ABI-encodes the `withdrawAsset` call. Pure encoding — no RPC.
  static func buildWithdrawTransactionData(
    builder: TransactionBuilderProtocol,
    addresses: RainWithdrawAddresses,
    amount: Decimal,
    decimals: Int,
    executorSignature: RainAdminSignature,
    walletSalt: Data,
    walletSignature: String
  ) throws -> String {
    let validated = try addresses.validated()

    guard let controllerAddress = Web3Core.EthereumAddress(validated.controllerAddress),
          let proxyAddress = Web3Core.EthereumAddress(validated.proxyAddress),
          let tokenAddress = Web3Core.EthereumAddress(validated.tokenAddress),
          let recipientAddress = Web3Core.EthereumAddress(validated.recipientAddress)
    else {
      throw RainSDKError.internalLogicError(
        details: "Error building transaction parameters for withdrawal. One of the addresses could not be built"
      )
    }

    // Rain's API returns the executor salt base64-encoded and the signature as hex.
    guard let executorSaltData = Data(base64Encoded: executorSignature.salt) else {
      throw RainSDKError.internalLogicError(
        details: "Failed to convert withdrawal salt base 64 string to Data"
      )
    }
    guard let executorSignatureData = Data(hexString: executorSignature.signature, length: 65) else {
      throw RainSDKError.internalLogicError(
        details: "Failed to convert withdrawal signature hex string to Data"
      )
    }
    guard let walletSignatureData = Data(hexString: walletSignature, length: 65) else {
      throw RainSDKError.internalLogicError(
        details: "Failed to convert admin signature hex string to Data or invalid length"
      )
    }

    let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: decimals)
    let expiryAt = try parseExpiresAt(executorSignature.expiresAt)

    let parameter = WithdrawAssetParameter(
      proxyAddress: proxyAddress,
      tokenAddress: tokenAddress,
      amount: amountBaseUnits,
      recipientAddress: recipientAddress,
      expiryAt: BigUInt(expiryAt),
      executorSalt: executorSaltData,
      executorSignature: executorSignatureData,
      walletSalt: walletSalt,
      walletSignature: walletSignatureData
    )

    return try builder.buildErc20TransactionForWithdrawAsset(
      ethereumContractAddress: controllerAddress,
      withdrawAssetParameter: parameter
    )
  }

  /// Accepts either a unix-seconds string or an ISO-8601 instant, in that order — Rain's API has
  /// returned both shapes.
  static func parseExpiresAt(_ expiresAt: String) throws -> Int {
    let trimmed = expiresAt.trimmingCharacters(in: .whitespacesAndNewlines)
    if let timestamp = Int(trimmed) { return timestamp }
    if let date = RainSdk.parseISO8601(trimmed) { return Int(date.timeIntervalSince1970) }
    throw RainSDKError.invalidConfig(
      details: "Invalid expiresAt format: \(expiresAt). Expected a unix-seconds or ISO-8601 string."
    )
  }
}
