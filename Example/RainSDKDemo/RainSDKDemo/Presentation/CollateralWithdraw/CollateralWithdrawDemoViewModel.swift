import Foundation
import Combine
import RainCore
import Web3

@MainActor
class CollateralWithdrawDemoViewModel: ObservableObject {
  @Published var chainId: Int = DemoLocalConfig.chainIdInt
  @Published var contractAddress: String = ""
  @Published var proxyAddress: String = ""
  /// An admin of the collateral contract; required by the Rain withdrawal-signature endpoint.
  @Published var adminAddress: String = ""
  @Published var tokenAddress: String = ""
  @Published var recipientAddress: String = "" {
    didSet {
      saveRecipientAddress()
      if recipientAddress != oldValue { invalidateSignature() }
    }
  }
  @Published var amount: String = "1" {
    didSet {
      if amount != oldValue {
        error = nil
        invalidateSignature()
      }
    }
  }
  @Published var decimals: Int = 18
  @Published var salt: String = ""
  @Published var signature: String = ""
  @Published var expiresAt: String = ""

  /// The (token, amount, recipient) a cached admin signature was issued for. A cached
  /// signature is only reused when the next withdraw targets the same key — preventing a
  /// signature minted for one amount being reused for another (which would revert).
  @Published var signatureKey: SignatureKey?
  
  @Published var isProcessing: Bool = false
  @Published var statusMessage: String = "Ready"
  @Published var loadingMessage: String?
  @Published var error: Error?
  @Published var txHash: String?
  @Published var showCopyFeedback: Bool = false

  // Credit contracts API → assets
  @Published var assets: [AssetModel] = []
  @Published var selectedAsset: AssetModel?
  @Published var isLoadingAssets: Bool = false
  @Published var assetsError: Error?

  // Withdrawal signature API (fetched through the SDK)
  @Published var withdrawalSignature: RainAdminSignature?
  @Published var isLoadingWithdrawalSignature: Bool = false
  @Published var withdrawalSignatureError: Error?

  private let sdkService = RainSDKService.shared
  private let initialContract: RainCollateralContractResponse?

  init(initialContract: RainCollateralContractResponse? = nil) {
    self.initialContract = initialContract
    
    if let saved = AppStorage.getCollateralWithdrawRecipientAddress() {
      self.recipientAddress = saved
    } else {
      self.recipientAddress = "0x0C9049B5cCB1C893fc8a5c1CDa8B5cc64c3aA909"
    }
    
    if let contract = initialContract {
      applyContractMetadata(contract)
      // Tokens arrive already enriched (the SDK resolves symbol/decimals), so the asset list
      // can be built synchronously.
      refreshAssets(from: contract)
    }

    sdkService.$isInitialized
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)

    $selectedAsset
      .sink { [weak self] asset in
        self?.tokenAddress = asset?.id ?? ""
        self?.decimals = asset?.conversionFactor ?? 18
        self?.invalidateSignature()
      }
      .store(in: &cancellables)
  }

  /// Clears any cached admin signature. Called whenever an input that the signature is bound
  /// to (token, amount, recipient) changes, so a stale signature is never sent for the wrong
  /// amount/recipient.
  private func invalidateSignature() {
    signatureKey = nil
    signature = ""
    salt = ""
    expiresAt = ""
    withdrawalSignature = nil
  }

  private var cancellables = Set<AnyCancellable>()

  private static func isValidAsset(_ asset: AssetModel) -> Bool {
    // Match Android (loadContractInfo): list every contract token regardless of balance —
    // zero-balance tokens stay selectable, and an empty withdrawal simply fails on-chain. A
    // resolved type is still required so the token's decimals are known for the withdraw math.
    asset.type != nil && !asset.id.isEmpty
  }

  private func saveRecipientAddress() {
    AppStorage.setCollateralWithdrawRecipientAddress(recipientAddress)
  }
  
  var hasPortal: Bool {
    sdkService.hasPortal
  }

  /// True when any wallet provider (Portal or Turnkey) is active.
  var hasWalletProvider: Bool {
    sdkService.hasWalletProvider
  }

  /// Available balance of the selected asset (0 when none selected).
  var availableBalance: Double {
    selectedAsset?.availableBalance ?? 0
  }

  /// Symbol shown alongside the balance in validation messages.
  var selectedSymbol: String {
    selectedAsset?.type?.rawValue.uppercased() ?? "tokens"
  }

  /// Parsed amount, or nil if the field is blank / non-numeric.
  private var parsedAmount: Double? {
    Double(amount)
  }

  /// True when the typed amount is positive and within the selected asset's balance.
  /// A tiny epsilon absorbs floating-point display rounding so an exact "max" isn't rejected.
  var isAmountValid: Bool {
    guard selectedAsset != nil, let value = parsedAmount else { return false }
    return value > 0 && value <= availableBalance + 1e-9
  }

  /// True when the typed amount exceeds the selected asset's available balance.
  var isAmountOverBalance: Bool {
    guard selectedAsset != nil, let value = parsedAmount else { return false }
    return value > availableBalance + 1e-9
  }

  var canWithdraw: Bool {
    hasWalletProvider
    && !recipientAddress.isEmpty
    && selectedAsset != nil
    && isAmountValid
  }

  /// "Withdraw Maximum" is available whenever a selected asset has a positive balance.
  var canWithdrawMaximum: Bool {
    hasWalletProvider && (selectedAsset?.availableBalance ?? 0) > 0
  }

  // MARK: - Credit contracts API → AssetModel

  /// Applies a contract's addressing metadata (controller/proxy/admin/chain) to the VM.
  private func applyContractMetadata(_ contract: RainCollateralContractResponse) {
    if let controllerAddress = contract.controllerAddress {
      self.contractAddress = controllerAddress
    }
    if let proxyAddress = contract.address {
      self.proxyAddress = proxyAddress
    }
    if let chainId = contract.chainId {
      self.chainId = chainId
    }
    // The Rain signature endpoint requires an admin of the collateral contract.
    self.adminAddress = contract.adminAddresses?.first ?? ""
  }

  /// Rebuilds `assets` from a contract (tokens already enriched by the SDK) and preserves
  /// the current selection.
  private func refreshAssets(from contract: RainCollateralContractResponse) {
    assets = contract.toAssetModels().filter { Self.isValidAsset($0) }
    if let current = selectedAsset {
      selectedAsset = assets.first { $0.id == current.id }
    }
  }

  /// Fetches collateral contracts through the SDK and converts them to asset models.
  func loadCreditContracts() async {
    isLoadingAssets = true
    defer {
      isLoadingAssets = false
    }

    do {
      let contract = RainCollateralContractResponse(
        contract: try await sdkService.fetchCollateralContract()
      )
      applyContractMetadata(contract)
      refreshAssets(from: contract)
    } catch {
      print("Load credit contracts failed: \(error.localizedDescription)")
    }
  }

  // MARK: - Withdrawal signature API

  /// Fetches the admin withdrawal signature through the SDK.
  /// Use the returned signature (data + salt) and expiresAt for the wallet-provider withdraw.
  func loadWithdrawalSignature(
    chainId: Int,
    token: String,
    amount: String,
    adminAddress: String,
    recipientAddress: String,
    isAmountNative: Bool = true
  ) async {
    isLoadingWithdrawalSignature = true
    withdrawalSignatureError = nil
    withdrawalSignature = nil

    do {
      let result = try await sdkService.fetchAdminSignature(
        chainId: chainId,
        tokenAddress: token,
        amountBaseUnits: BigUInt(amount, radix: 10) ?? BigUInt(0),
        adminAddress: adminAddress,
        recipientAddress: recipientAddress,
        isAmountNative: isAmountNative
      )
      withdrawalSignature = result
      withdrawalSignatureError = nil
      signature = result.signature
      salt = result.salt
      if !result.expiresAt.isEmpty { expiresAt = result.expiresAt }
    } catch {
      withdrawalSignature = nil
      withdrawalSignatureError = error
    }

    isLoadingWithdrawalSignature = false
  }
  
  /// Withdraw the typed amount.
  func withdraw() async {
    await performWithdraw()
  }

  /// Withdraw the full available balance of the selected asset. Gas estimation happens in the
  /// background as part of the withdraw, so it isn't surfaced to the user.
  func withdrawMaximum() async {
    guard let asset = selectedAsset else { return }
    // `availableBalance` is a Double from the balances API; bridge it to Decimal via its string
    // form so we don't fold binary floating-point drift into the amount we sign and send.
    let maxAmount = Decimal(string: String(asset.availableBalance)) ?? Decimal(asset.availableBalance)
    await performWithdraw(amountOverride: maxAmount)
  }

  /// Executes a collateral withdrawal.
  /// - Parameter amountOverride: when set (e.g. "Withdraw Maximum"), withdraws this amount
  ///   instead of the value typed into the amount field.
  private func performWithdraw(amountOverride: Decimal? = nil) async {
    guard let asset = selectedAsset else { return }
    // Parse the typed amount as a Decimal directly from its string — going through Double first
    // (e.g. Double("16.38")) reintroduces float drift the exact base-unit scaling exists to avoid.
    let rawAmount = amountOverride ?? Decimal(string: amount)
    guard let rawAmount, rawAmount > 0 else {
      setError("Enter a valid amount", status: "Enter a valid amount")
      return
    }
    guard !adminAddress.isEmpty else {
      setError("Contract has no admin address.", status: "Contract has no admin address")
      return
    }

    // Normalize to the token's precision (round DOWN) so the amount we sign for, the base
    // units we send, and the on-chain tx all agree — and so the SDK's scale guard never trips
    // on a long Double fraction. Rounding down keeps "Withdraw Maximum" at or below balance.
    guard let normalized = normalizedAmount(rawAmount, decimals: decimals) else {
      setError("Amount is below the token's minimum unit", status: "Amount too small")
      return
    }

    // UI-side guard: never request more than the available balance.
    if (normalized.value as NSDecimalNumber).doubleValue > asset.availableBalance + 1e-9 {
      let message = "Amount exceeds available balance " +
        "(\(String(format: "%.6f", asset.availableBalance)) \(selectedSymbol))"
      setError(message, status: "Amount exceeds balance")
      return
    }

    isProcessing = true
    error = nil
    txHash = nil
    withdrawalSignatureError = nil

    // Only reuse the cached signature when it was issued for THIS exact (token, amount,
    // recipient). Reusing matching inputs avoids the "active signature already exists" error
    // on a legitimate retry; a different amount must NOT reuse it (the contract would revert).
    let key = SignatureKey(
      tokenAddress: tokenAddress.lowercased(),
      amountBaseUnits: normalized.baseUnits.description,
      recipientAddress: recipientAddress.lowercased()
    )

    if signatureKey != key || signature.isEmpty {
      loadingMessage = "Getting withdrawal signature..."
      await loadWithdrawalSignature(
        chainId: chainId,
        token: key.tokenAddress,
        amount: key.amountBaseUnits,
        adminAddress: adminAddress,
        recipientAddress: recipientAddress,
        isAmountNative: true
      )

      if withdrawalSignatureError != nil {
        self.error = friendlySignatureError(withdrawalSignatureError)
        statusMessage = "Failed to get withdrawal signature"
        isProcessing = false
        loadingMessage = nil
        return
      }
      // Cache the signature with the inputs it's bound to so a retry reuses it.
      signatureKey = key
    }

    loadingMessage = "Submitting withdrawal..."
    statusMessage = "Building and submitting withdrawal..."

    do {
      let hash = try await sdkService.withdrawCollateral(
        chainId: chainId,
        contractAddress: contractAddress,
        proxyAddress: proxyAddress,
        tokenAddress: tokenAddress,
        recipientAddress: recipientAddress,
        amount: normalized.value,
        decimals: decimals,
        salt: salt,
        signature: signature,
        expiresAt: expiresAt,
        nonce: nil
      )
      txHash = hash
      statusMessage = "Success! Transaction submitted."
      error = nil
      // The signature is consumed; clear it so the next withdraw fetches a fresh one.
      invalidateSignature()

      // Refresh balances after the send settles. Only on success — reloading reassigns
      // selectedAsset, which clears the cached signature; on failure we keep it so an exact
      // retry reuses it instead of triggering "active signature already exists".
      Task {
        try await Task.sleep(for: .seconds(5))
        await loadCreditContracts()
      }
    } catch {
      self.error = error
      statusMessage = "Withdrawal failed"
    }

    isProcessing = false
    loadingMessage = nil
  }

  /// Normalizes a raw amount to the token's decimal precision (rounding DOWN) and returns both
  /// the normalized value and its exact base-unit representation. Returns nil when the result
  /// rounds to zero (below the token's minimum unit).
  private func normalizedAmount(_ raw: Decimal, decimals: Int) -> (value: Decimal, baseUnits: BigUInt)? {
    let handler = NSDecimalNumberHandler(
      roundingMode: .down,
      scale: Int16(decimals),
      raiseOnExactness: false,
      raiseOnOverflow: false,
      raiseOnUnderflow: false,
      raiseOnDivideByZero: false
    )
    let roundedDecimal = NSDecimalNumber(decimal: raw).rounding(accordingToBehavior: handler)
    guard roundedDecimal.doubleValue > 0 else { return nil }
    // Exact base-10 scaling (matches AmountHelpers.toBaseUnits); a Double multiply truncates
    // (e.g. 16.38 * 1e6 == 16_379_999.99…), under-paying the on-chain tx.
    let scaled = roundedDecimal.multiplying(byPowerOf10: Int16(decimals))
    let baseUnits = BigUInt(scaled.stringValue, radix: 10) ?? BigUInt(0)
    return (roundedDecimal.decimalValue, baseUnits)
  }

  /// Maps the raw signature error to a clearer hint. The Rain API returns "active signature
  /// already exists" when a previous withdrawal signature for this user is still pending.
  private func friendlySignatureError(_ error: Error?) -> Error {
    if case RainSDKError.signatureNotReady(_, let retryAfter) = error ?? RainSDKError.unauthorized {
      let hint = retryAfter.map { " Retry in \($0)s." } ?? ""
      return NSError(
        domain: "CollateralWithdraw",
        code: -3,
        userInfo: [NSLocalizedDescriptionKey: "Withdrawal signature is not ready yet.\(hint)"]
      )
    }
    let raw = error?.localizedDescription ?? "Failed to get withdrawal signature"
    if raw.range(of: "active signature", options: .caseInsensitive) != nil {
      return NSError(
        domain: "CollateralWithdraw",
        code: -2,
        userInfo: [NSLocalizedDescriptionKey:
          "A withdrawal signature is already active for this account. Wait for the previous " +
          "withdrawal to settle (or its signature to expire) before requesting a new one."]
      )
    }
    return error ?? NSError(
      domain: "CollateralWithdraw",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey: raw]
    )
  }

  private func setError(_ message: String, status: String) {
    self.error = NSError(
      domain: "CollateralWithdraw",
      code: -1,
      userInfo: [NSLocalizedDescriptionKey: message]
    )
    statusMessage = status
  }
}

/// Identifies the exact inputs an admin signature was issued for. A cached signature is only
/// reused when the next withdraw targets the same key.
struct SignatureKey: Equatable {
  let tokenAddress: String
  let amountBaseUnits: String
  let recipientAddress: String
}
