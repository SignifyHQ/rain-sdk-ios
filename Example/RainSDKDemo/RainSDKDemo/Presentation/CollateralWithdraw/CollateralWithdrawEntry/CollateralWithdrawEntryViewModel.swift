import Foundation

@MainActor
class CollateralWithdrawEntryViewModel: ObservableObject {
  @Published var rainApiKey: String = ""
  @Published var userId: String = ""
  @Published var isLoading: Bool = false
  @Published var error: Error?
  @Published var pendingContract: RainCollateralContractResponse?

  init() {
    rainApiKey = RainAPICredentialsStorage.apiKey ?? ""
    userId = RainAPICredentialsStorage.userId ?? ""
  }

  /// True once both credentials are entered.
  var canContinue: Bool {
    !rainApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
      && !userId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// Saves the Rain Api-Key + User ID, then verifies them by minting a CST and loading the
  /// collateral contracts. On success, navigates to collateral withdraw.
  func verifyAndContinue() async {
    let apiKey = rainApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
    let user = userId.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !apiKey.isEmpty, !user.isEmpty else {
      return
    }

    isLoading = true
    error = nil
    pendingContract = nil

    defer {
      isLoading = false
    }

    RainAPICredentialsStorage.save(apiKey: apiKey, userId: user)

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
