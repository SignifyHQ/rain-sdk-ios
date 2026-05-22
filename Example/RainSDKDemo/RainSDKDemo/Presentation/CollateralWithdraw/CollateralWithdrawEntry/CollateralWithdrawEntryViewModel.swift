import Foundation

@MainActor
class CollateralWithdrawEntryViewModel: ObservableObject {
  @Published var userAccessToken: String = ""
  @Published var isLoading: Bool = false
  @Published var error: Error?
  @Published var pendingContract: RainCollateralContractResponse?

  init() {
    userAccessToken = AuthTokenStorage.getToken() ?? ""
  }

  /// Verifies the Rain API access token by loading credit contracts, then navigates to collateral withdraw.
  func verifyAndContinue() async {
    let token = userAccessToken.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !token.isEmpty else {
      return
    }

    isLoading = true
    error = nil
    pendingContract = nil

    defer {
      isLoading = false
    }

    AuthTokenStorage.saveToken(token)

    let repository = CreditContractsRepository()

    do {
      pendingContract = try await repository.getCreditContracts()
    } catch {
      self.error = error
    }
  }

  func clearError() {
    error = nil
  }
}
