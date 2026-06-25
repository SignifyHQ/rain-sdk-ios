import Foundation

@MainActor
class GetBalancesDemoViewModel: ObservableObject {

  // MARK: - Native Balance

  @Published var nativeBalance: Double?
  @Published var nativeWalletAddress: String?
  @Published var isLoadingNative = false
  @Published var nativeError: Error?

  // MARK: - ERC-20 Balances (auto-discovered)

  @Published var walletTokens: [DiscoveredTokenBalance] = []
  @Published var tokensWalletAddress: String?
  @Published var isLoadingTokens = false
  @Published var didFetchTokens = false
  @Published var tokensError: Error?

  // MARK: - All Balances (cross-chain)

  @Published var allBalances: [Int: [String: Double]]?
  @Published var isLoadingAll = false
  @Published var allError: Error?

  // MARK: - Dependencies

  private let sdkService = RainSDKService.shared

  /// Network selected on the connection screen.
  var chain: WalletChain { sdkService.selectedChain }

  // MARK: - Validation

  var canFetch: Bool {
    sdkService.isInitialized
  }

  var canFetchTokens: Bool {
    canFetch && !chain.isSolana
  }

  // MARK: - Fetch Native Balance

  func fetchNativeBalance() async {
    guard canFetch else { return }
    isLoadingNative = true
    nativeError = nil
    nativeBalance = nil
    nativeWalletAddress = nil

    do {
      nativeWalletAddress = try await sdkService.getWalletAddress(chainId: chain.chainId)
      nativeBalance = try await sdkService.getNativeBalance(chainId: chain.chainId)
    } catch {
      nativeError = error
    }

    isLoadingNative = false
  }

  // MARK: - Fetch ERC-20 Balances (auto-discovered)

  /// Lists every ERC-20 the wallet holds with a balance > 0 — no contract address or decimals
  /// input. Each token's symbol / name / decimals are resolved by the SDK.
  func fetchTokenBalances() async {
    guard canFetchTokens else { return }
    isLoadingTokens = true
    tokensError = nil
    walletTokens = []
    tokensWalletAddress = nil

    do {
      tokensWalletAddress = try await sdkService.getWalletAddress(chainId: chain.chainId)
      walletTokens = try await sdkService.getTokenBalances(chainId: chain.chainId)
      didFetchTokens = true
    } catch {
      tokensError = error
    }

    isLoadingTokens = false
  }

  // MARK: - Fetch All Balances (cross-chain)

  func fetchAllBalances() async {
    guard sdkService.isInitialized else { return }
    isLoadingAll = true
    allError = nil
    allBalances = nil

    do {
      allBalances = try await sdkService.getAllBalances()
    } catch {
      allError = error
    }

    isLoadingAll = false
  }
}
