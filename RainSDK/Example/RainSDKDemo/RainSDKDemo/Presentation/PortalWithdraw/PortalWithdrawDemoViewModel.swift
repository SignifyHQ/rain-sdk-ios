import Foundation
import Combine
import Web3

@MainActor
class PortalWithdrawDemoViewModel: ObservableObject {
  @Published var chainId: Int = 43113
  @Published var contractAddress: String = ""
  @Published var proxyAddress: String = ""
  @Published var tokenAddress: String = ""
  @Published var recipientAddress: String = "0x0C9049B5cCB1C893fc8a5c1CDa8B5cc64c3aA909"
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
    if let contract = initialContract {
      assets = contract.toAssetModels()
      
      if let contractAddress = contract.controllerAddress  {
        self.contractAddress = contractAddress
      }
      
      if let proxyAddress = contract.address  {
        self.proxyAddress = proxyAddress
      }
      
      if let chainId = contract.chainId {
        self.chainId = chainId
      }
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
  
  var hasPortal: Bool {
    sdkService.hasPortal
  }
  
  var canWithdraw: Bool {
    hasPortal
    && !recipientAddress.isEmpty
    && !amount.isEmpty
    && selectedAsset != nil
    && Double(amount) != nil
  }

  // MARK: - Credit contracts API → AssetModel

  /// Fetches credit contracts from the API and converts them to asset models.
  func loadCreditContracts() async {
    isLoadingAssets = true
    assetsError = nil

    do {
      let contracts = try await creditContractsRepository.getCreditContracts()
      assets = contracts.toAssetModels()
      assetsError = nil
    } catch {
      assets = []
      assetsError = error
    }

    isLoadingAssets = false
  }

  // MARK: - Withdrawal signature API

  /// Fetches withdrawal signature from POST /v1/rain/person/withdrawal/signature.
  /// Use the returned signature (data + salt) and expiresAt for Portal withdraw.
  func loadWithdrawalSignature(
    chainId: Int,
    token: String,
    amount: String,
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

    isProcessing = true
    error = nil
    txHash = nil
    withdrawalSignatureError = nil

    loadingMessage = "Getting withdrawal signature..."
    await loadWithdrawalSignature(
      chainId: chainId,
      token: tokenAddress,
      amount: amount,
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

    isProcessing = false
    loadingMessage = nil
  }
}
