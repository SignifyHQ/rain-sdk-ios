import Foundation

@MainActor
class GetBalancesDemoViewModel: ObservableObject {

  // MARK: - Shared Input

  @Published var chainId: String = "43113"

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

  // MARK: - Dependencies

  private let sdkService = RainSDKService.shared

  // MARK: - Validation

  var canFetch: Bool {
    sdkService.isInitialized && chainIdInt != nil
  }

  var canFetchERC20: Bool {
    canFetch && !tokenAddress.trimmingCharacters(in: .whitespaces).isEmpty
  }

  private var chainIdInt: Int? { Int(chainId) }

  // MARK: - Fetch Native Balance

  func fetchNativeBalance() async {
    guard let chainId = chainIdInt, canFetch else { return }
    isLoadingNative = true
    nativeError = nil
    nativeBalance = nil
    nativeWalletAddress = nil

    do {
      nativeWalletAddress = try await sdkService.getWalletAddress()
      nativeBalance = try await sdkService.getNativeBalance(chainId: chainId)
    } catch {
      nativeError = error
    }

    isLoadingNative = false
  }

  // MARK: - Fetch ERC-20 Balance

  func fetchERC20Balance() async {
    guard let chainId = chainIdInt, canFetchERC20 else { return }
    isLoadingERC20 = true
    erc20Error = nil
    erc20Balance = nil
    erc20WalletAddress = nil

    do {
      erc20WalletAddress = try await sdkService.getWalletAddress()
      erc20Balance = try await sdkService.getERC20Balance(
        chainId: chainId,
        tokenAddress: tokenAddress.trimmingCharacters(in: .whitespaces),
        decimals: Int(tokenDecimals)
      )
    } catch {
      erc20Error = error
    }

    isLoadingERC20 = false
  }
}
