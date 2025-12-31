import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import RainData
import RainDomain
import Factory
import AccountData

@MainActor
final class ActivatePhysicalCardInputViewModel: ObservableObject {
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  
  lazy var activateCardUseCase: RainActivatePhysicalCardUseCaseProtocol = {
    RainActivatePhysicalCardUseCase(repository: rainCardRepository)
  }()
  
  @Published var isShown: Bool = true
  @Published var isLoading: Bool = false
  @Published var isPanLast4Entered: Bool = false
  @Published var errorInlineMessage: String?
  @Published var panLast4: String = .empty
  
  let cardID: String

  init(cardID: String) {
    self.cardID = cardID
    observeCVVInput()
  }
}

// MARK: - Observables
private extension ActivatePhysicalCardInputViewModel {
  func observeCVVInput() {
    $panLast4
      .map { cvv in
        cvv.count == 4
      }
      .assign(to: &$isPanLast4Entered)
  }
}

// MARK: - Handle APIs
extension ActivatePhysicalCardInputViewModel {
  func activatePhysicalCard(completion: @escaping (String) -> Void) {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let parameters = APIRainActivateCardParameters(last4: panLast4)
        _ = try await activateCardUseCase.execute(cardID: cardID, parameters: parameters)
        completion(cardID)
      } catch {
        log.error(error.userFriendlyMessage)
        errorInlineMessage = "Incorrect entry, try again"
      }
    }
  }
}
