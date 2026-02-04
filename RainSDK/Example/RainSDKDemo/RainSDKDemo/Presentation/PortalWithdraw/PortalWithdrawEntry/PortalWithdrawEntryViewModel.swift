import Foundation

@MainActor
class PortalWithdrawEntryViewModel: ObservableObject {
  @Published var userAccessToken: String = ""
  @Published var isLoading: Bool = false
  @Published var error: Error?
  @Published var navigationRoute: PortalWithdrawRoute?

  init() {
    userAccessToken = AuthTokenStorage.getToken() ?? ""
  }

  /// Verifies the access token by loading credit contracts. Saves token to UserDefaults first; APIClient reads it for headers. On success sets navigationRoute to trigger navigation.
  func verifyAndLoadContracts() async {
    let token = userAccessToken.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !token.isEmpty else {
      return
    }

    isLoading = true
    error = nil
    navigationRoute = nil
    
    defer {
      isLoading = false
    }

    AuthTokenStorage.saveToken(token)

    let repository = CreditContractsRepository()

    do {
      let contract = try await repository.getCreditContracts()
      navigationRoute = .portalWithdraw(contract: contract)
    } catch {
      self.error = error
    }
  }

  func clearError() {
    error = nil
  }
}

extension PortalWithdrawEntryViewModel {
  // MARK: - Navigation
  enum PortalWithdrawRoute: Hashable {
    case portalWithdraw(contract: RainCollateralContractResponse)
  }
}
