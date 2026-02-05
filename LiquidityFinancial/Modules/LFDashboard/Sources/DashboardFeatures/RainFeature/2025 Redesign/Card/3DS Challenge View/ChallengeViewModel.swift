import Combine
import Factory
import LFLocalizable
import LFStyleGuide
import RainData
import RainDomain

@MainActor
public final class ChallengeViewModel: ObservableObject {
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  
  @Published var shouldDismiss3dsChallengeSheet: Bool = false
  
  @Published var isApproving: Bool = false
  @Published var isDeclining: Bool = false
  @Published var currentToast: ToastData? = nil
  
  lazy var make3dsChallengeDecisionUseCase: RainMake3dsChallengeDecisionUseCaseProtocol = {
    RainMake3dsChallengeDecisionUseCase(repository: rainCardRepository)
  }()
  
  private let challenge: Pending3DSChallenge
  
  var areButtonsDisabled: Bool {
    isApproving || isDeclining
  }
  
  var displayLast4: String {
    challenge.rainCardLast4 ?? "n/a"
  }
  
  var displayPurchaseAmount: String {
    challenge.amount?.formattedAmount(currencyCode: challenge.currency ?? "USD") ?? "$0.00"
  }
  
  var displayMerchantName: String {
    challenge.merchantName ?? "n/a"
  }
  
  var displayMerchantCountry: String {
    challenge.merchantCountry ?? "n/a"
  }
  
  public init(
    challenge: Pending3DSChallenge
  ) {
    self.challenge = challenge
  }
}

// MARK: - Binding Observables
extension ChallengeViewModel {}

// MARK: - Handling UI/UX Logic
extension ChallengeViewModel {}

// MARK: - Handling Interations
extension ChallengeViewModel {
  func onDecisionButtonTap(
    decision: ChallengeDecision
  ) {
    Task {
      defer {
        isApproving = false
        isDeclining = false
      }
      // Show the button loader only on the button which was tapped
      if decision == .approve {
        isApproving = true
      } else {
        isDeclining = true
      }
      
      do {
        try await make3dsDecision(decision: decision)
        // Present success toast
        currentToast = ToastData(
          type: .success,
          title: "Success",
          body: "Purchase \(decision.displayValue) successfully!"
        )
        // Give a second for the toast to stay on before dismissing the sheet
        try await Task.sleep(for: .seconds(1))
        // Dismiss the sheet
        shouldDismiss3dsChallengeSheet = true
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

// MARK: - API Calls
extension ChallengeViewModel {
  private func make3dsDecision(
    decision: ChallengeDecision
  ) async throws {
    try await make3dsChallengeDecisionUseCase.execute(approvalId: challenge.id, decision: decision.rawValue)
  }
}

// MARK: - Helper Functions
extension ChallengeViewModel {}

// MARK: - Private Enums
extension ChallengeViewModel {
  enum ChallengeDecision: String {
    case approve = "APPROVE"
    case decline = "DECLINE"
    
    var displayValue: String {
      switch self {
      case .approve:
        "approved"
      case .decline:
        "declined"
      }
    }
  }
}
