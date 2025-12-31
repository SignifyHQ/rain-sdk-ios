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
final class RainEnterLastFourNumbersViewModel: ObservableObject {
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  
  lazy var activateCardUseCase: RainActivatePhysicalCardUseCaseProtocol = {
    RainActivatePhysicalCardUseCase(repository: rainCardRepository)
  }()
  
  @Published var isShown: Bool = true
  @Published var isShowIndicator: Bool = false
  @Published var isPanLast4Entered: Bool = false
  
  @Published var panLast4: String = .empty
  @Published var toastMessage: String?
  
  let cardID: String

  init(cardID: String) {
    self.cardID = cardID
    observeCVVInput()
  }
}

// MARK: - API Handler
extension RainEnterLastFourNumbersViewModel {
  func activatePhysicalCard(completion: @escaping (String) -> Void) {
    Task {
      defer { isShowIndicator = false }
      isShowIndicator = true
      
      do {
        let parameters = APIRainActivateCardParameters(last4: panLast4)
        _ = try await activateCardUseCase.execute(cardID: cardID, parameters: parameters)
        completion(cardID)
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - Private Functions
private extension RainEnterLastFourNumbersViewModel {
  func observeCVVInput() {
    $panLast4
      .map { cvv in
        cvv.count == 4
      }
      .assign(to: &$isPanLast4Entered)
  }
}
