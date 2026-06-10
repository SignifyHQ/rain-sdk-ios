import Foundation

@MainActor
class GetBalancesDemoViewModel: ObservableObject {

  // MARK: - Native Balance

  @Published var nativeBalance: Double?
  @Published var nativeWalletAddress: String?
  @Published var isLoadingNative = false
  @Published var nativeError: Error?

  // MARK: - ERC-20 Balance

  @Published var tokenAddress: String = ""
  @Published var tokenDecimals: String = "18"
  @Published var erc20Balance: Double?
  @Published var erc20WalletAddress: String?
  @Published var isLoadingERC20 = false
  @Published var erc20Error: Error?

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

  var canFetchERC20: Bool {
    canFetch && !chain.isSolana && !tokenAddress.trimmingCharacters(in: .whitespaces).isEmpty
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

  // MARK: - Fetch ERC-20 Balance

  func fetchERC20Balance() async {
    guard canFetchERC20 else { return }
    isLoadingERC20 = true
    erc20Error = nil
    erc20Balance = nil
    erc20WalletAddress = nil

    do {
      erc20WalletAddress = try await sdkService.getWalletAddress(chainId: chain.chainId)
      erc20Balance = try await sdkService.getERC20Balance(
        chainId: chain.chainId,
        tokenAddress: tokenAddress.trimmingCharacters(in: .whitespaces),
        decimals: Int(tokenDecimals)
      )
    } catch {
      erc20Error = error
    }

    isLoadingERC20 = false
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
