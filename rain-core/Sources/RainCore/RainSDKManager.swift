import Foundation
import CoreGraphics
import QRCode
import Web3
import Web3Core

/// Concrete ``RainClient`` bound to a single resolved wallet provider. Constructed by
/// ``RainSdk`` when a provider is resolved; not created directly by hosts.
///
/// Holds the shared vendor-free services (transaction builder, token store) plus the one
/// `RainWalletProvider` this client speaks to. All wallet operations delegate to that provider.
final class RainSdkManager: RainClient, @unchecked Sendable {
  let walletProvider: any RainWalletProvider
  private let networkConfigs: [NetworkConfig]
  let transactionBuilderService: TransactionBuilderProtocol
  private let tokenStore: TokenMetadataStore

  init(
    walletProvider: any RainWalletProvider,
    networkConfigs: [NetworkConfig],
    transactionBuilder: TransactionBuilderProtocol,
    tokenStore: TokenMetadataStore
  ) {
    self.walletProvider = walletProvider
    self.networkConfigs = networkConfigs
    self.transactionBuilderService = transactionBuilder
    self.tokenStore = tokenStore
  }

  // MARK: - Collateral / fees

  func withdrawCollateral(
    chainId: Int,
    assetAddresses: WithdrawAssetAddresses,
    amount: Decimal,
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

      let txHash = try await walletProvider.sendTransaction(chainId: chainId, params: transactionParams)
      RainLogger.info("Rain SDK: Withdrawal transaction submitted. Hash: \(txHash)")
      return txHash
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  func estimateWithdrawalFee(
    chainId: Int,
    addresses: WithdrawAssetAddresses,
    amount: Decimal,
    decimals: Int,
    salt: String,
    signature: String,
    expiresAt: String
  ) async throws -> Decimal {
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

  func getWalletAddress() async throws -> String {
    do {
      return try await walletProvider.address()
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  func getWalletAddress(chainId: Int) async throws -> String {
    do {
      return try await walletProvider.getAddress(chainId: chainId)
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  func generateWalletAddressQRCode(
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

  func getBalance(chainId: Int, token: Token) async throws -> Balance {
    do {
      return try await walletProvider.getBalance(chainId: chainId, token: token)
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  func getTokenBalances(chainId: Int) async throws -> [Balance] {
    do {
      return try await walletProvider.getBalances(chainId: chainId)
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  func getAllBalances() async throws -> [Balance] {
    let chainIds = networkConfigs.map(\.chainId)
    let provider = walletProvider
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

  // MARK: - Transactions

  func getTransactions(
    chainId: Int,
    limit: Int? = nil,
    offset: Int? = nil,
    order: WalletTransactionOrder? = nil
  ) async throws -> [WalletTransaction] {
    do {
      return try await walletProvider.getTransactions(
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

  func sendNative(
    chainId: Int,
    to: String,
    amount: Decimal
  ) async throws -> RainTokenTransferResult {
    do {
      if SolanaChains.isSolana(chainId) {
        guard let solanaProvider = walletProvider as? any RainSolanaTransfersProvider else {
          throw RainSDKError.internalLogicError(
            details: "The active wallet provider does not support Solana transfers"
          )
        }
        let signature = try await solanaProvider.sendSolanaNative(chainId: chainId, to: to, amount: amount)
        return RainTokenTransferResult(transactionHash: signature)
      }

      let from = try await walletProvider.address()
      let amountWei = try AmountHelpers.toBaseUnits(amount: amount, decimals: 18)
      let params = WalletTransactionParams(
        from: from,
        to: to,
        value: "0x" + String(amountWei, radix: 16),
        data: .empty
      )

      let hash = try await walletProvider.sendTransaction(chainId: chainId, params: params)
      return RainTokenTransferResult(transactionHash: hash)
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  func sendToken(
    chainId: Int,
    contractAddress: String,
    to: String,
    amount: Decimal,
    decimals: Int?
  ) async throws -> RainTokenTransferResult {
    do {
      if SolanaChains.isSolana(chainId) {
        guard let solanaProvider = walletProvider as? any RainSolanaTransfersProvider else {
          throw RainSDKError.internalLogicError(
            details: "The active wallet provider does not support Solana transfers"
          )
        }
        let resolvedDecimals = await resolveDecimals(
          chainId: chainId, contractAddress: contractAddress, decimals: decimals
        )
        let signature = try await solanaProvider.sendSolanaSPLToken(
          chainId: chainId,
          mintAddress: contractAddress,
          to: to,
          amount: amount,
          decimals: resolvedDecimals
        )
        return RainTokenTransferResult(transactionHash: signature)
      }

      let from = try await walletProvider.address()
      let resolvedDecimals = await resolveDecimals(
        chainId: chainId, contractAddress: contractAddress, decimals: decimals
      )
      let amountBaseUnits = try AmountHelpers.toBaseUnits(amount: amount, decimals: resolvedDecimals)
      let data = try await transactionBuilderService.buildERC20TransferData(
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

      let hash = try await walletProvider.sendTransaction(chainId: chainId, params: params)
      return RainTokenTransferResult(transactionHash: hash)
    } catch {
      throw RainSDKError.from(underlying: error)
    }
  }

  // MARK: - Internal helpers

  /// Resolves a token's decimals: caller value if supplied, else the token store (registry, then
  /// a one-time on-chain read), falling back to the default.
  private func resolveDecimals(chainId: Int, contractAddress: String, decimals: Int?) async -> Int {
    if let decimals { return decimals }
    return await tokenStore.tokenInfo(chainId: chainId, address: contractAddress).decimals
  }
}
