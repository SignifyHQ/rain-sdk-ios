import Foundation
import Combine
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
    didSet { saveRecipientAddress() }
  }
  @Published var amount: String = "1"
  @Published var decimals: Int = 18
  @Published var salt: String = ""
  @Published var signature: String = ""
  @Published var expiresAt: String = ""
  
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

  // Withdrawal signature API
  @Published var withdrawalSignature: RainWithdrawalSignatureEntity?
  @Published var isLoadingWithdrawalSignature: Bool = false
  @Published var withdrawalSignatureError: Error?

  private let sdkService = RainSDKService.shared
  private let creditContractsRepository = CreditContractsRepository()
  private let withdrawalSignatureRepository = WithdrawalSignatureRepository()
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
      // Rain's /contracts response omits token symbol/decimals, so the assets need on-chain
      // enrichment before they pass `isValidAsset` (which requires a resolved type). Kick that
      // off asynchronously; until it lands the list is empty rather than wrongly populated.
      Task { [weak self] in await self?.refreshAssets(from: contract) }
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
      }
      .store(in: &cancellables)
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

  var canWithdraw: Bool {
    hasWalletProvider
    && !recipientAddress.isEmpty
    && !amount.isEmpty
    && selectedAsset != nil
    && Double(amount) != nil
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

  /// Builds asset models from a contract, enriching each token's symbol/decimals on-chain via
  /// the SDK (the Rain `/contracts` endpoint omits them). Falls back to whatever the contract
  /// provided when the on-chain read fails.
  private func buildAssets(from contract: RainCollateralContractResponse) async -> [AssetModel] {
    let resolvedChainId = contract.chainId ?? chainId
    var result: [AssetModel] = []
    for token in contract.tokens ?? [] {
      guard let address = token.address, !address.isEmpty else { continue }
      let meta = await sdkService.resolveTokenMetadata(chainId: resolvedChainId, tokenAddress: address)
      let enriched = RainTokenResponse(
        address: token.address,
        name: meta?.name ?? token.name,
        symbol: meta?.symbol ?? token.symbol,
        decimals: meta.map { Double($0.decimals) } ?? token.decimals,
        logo: token.logo,
        balance: token.balance,
        exchangeRate: token.exchangeRate,
        advanceRate: token.advanceRate,
        availableUsdBalance: token.availableUsdBalance
      )
      result.append(AssetModel(rainCollateralAsset: enriched))
    }
    return result.filter { Self.isValidAsset($0) }
  }

  /// Rebuilds `assets` (enriched) from a contract and preserves the current selection.
  private func refreshAssets(from contract: RainCollateralContractResponse) async {
    let built = await buildAssets(from: contract)
    assets = built
    if let current = selectedAsset {
      selectedAsset = assets.first { $0.id == current.id }
    }
  }

  /// Fetches collateral contracts from the Rain API and converts them to asset models.
  func loadCreditContracts() async {
    isLoadingAssets = true
    defer {
      isLoadingAssets = false
    }

    do {
      let contract = try await creditContractsRepository.getCreditContracts()
      applyContractMetadata(contract)
      await refreshAssets(from: contract)
    } catch {
      print("Load credit contracts failed: \(error.localizedDescription)")
    }
  }

  // MARK: - Withdrawal signature API

  /// Fetches the admin withdrawal signature from the Rain dev API (CST auth).
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
      let result = try await withdrawalSignatureRepository.getWithdrawalSignature(
        chainId: chainId,
        token: token,
        amount: amount,
        adminAddress: adminAddress,
        recipientAddress: recipientAddress,
        isAmountNative: isAmountNative
      )
      withdrawalSignature = result
      withdrawalSignatureError = nil
      if let sig = result.signatureEntity {
        signature = sig.data ?? ""
        salt = sig.salt ?? ""
        if let exp = result.expiresAt { expiresAt = exp }
      }
    } catch {
      withdrawalSignature = nil
      withdrawalSignatureError = error
    }

    isLoadingWithdrawalSignature = false
  }
  
  func withdraw() async {
    guard let amountDouble = Double(amount) else { return }
    guard !adminAddress.isEmpty else {
      self.error = NSError(
        domain: "CollateralWithdraw",
        code: -1,
        userInfo: [NSLocalizedDescriptionKey: "Contract has no admin address."]
      )
      statusMessage = "Contract has no admin address"
      return
    }
    let newAmount = BigUInt(amountDouble * pow(10.0, Double(decimals)))

    isProcessing = true
    error = nil
    txHash = nil
    withdrawalSignatureError = nil

    loadingMessage = "Getting withdrawal signature..."
    await loadWithdrawalSignature(
      chainId: chainId,
      token: tokenAddress.lowercased(),
      amount: newAmount.description,
      adminAddress: adminAddress,
      recipientAddress: recipientAddress,
      isAmountNative: true
    )

    if withdrawalSignatureError != nil {
      self.error = withdrawalSignatureError
      statusMessage = "Failed to get withdrawal signature"
      isProcessing = false
      loadingMessage = nil
      return
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
        amount: amountDouble,
        decimals: decimals,
        salt: salt,
        signature: signature,
        expiresAt: expiresAt,
        nonce: nil
      )
      txHash = hash
      statusMessage = "Success! Transaction submitted."
      error = nil
    } catch {
      self.error = error
      statusMessage = "Withdrawal failed"
    }

    Task {
      // This is a sample app, so I want to delay to wait new balance
      try await Task.sleep(for: .seconds(5))
      await loadCreditContracts()
    }
    
    isProcessing = false
    loadingMessage = nil
  }
}
