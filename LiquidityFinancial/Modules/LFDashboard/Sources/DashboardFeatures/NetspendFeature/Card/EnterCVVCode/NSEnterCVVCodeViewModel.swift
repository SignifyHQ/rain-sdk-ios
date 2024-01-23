import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import NetSpendData
import NetspendDomain
import Factory
import AccountData

@MainActor
final class NSEnterCVVCodeViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository

  lazy var verifyCardUseCase: NSVerifyCVVCodeUseCaseProtocol = {
    NSVerifyCVVCodeUseCase(repository: cardRepository)
  }()
  
  @Published var isShowSetPinSuccessPopup: Bool = false
  @Published var isShown: Bool = true
  @Published var isShowIndicator: Bool = false
  @Published var isCVVCodeEntered: Bool = false
  
  @Published var generatedCVV: String = .empty
  @Published var toastMessage: String?
  
  let cardID: String
  let cvvCodeDigits = Constants.MaxCharacterLimit.cvvCode.value

  init(cardID: String) {
    self.cardID = cardID
    observeCVVInput()
  }
}

// MARK: - API Handler
extension NSEnterCVVCodeViewModel {
  func verifyCVVCode(completion: @escaping (String) -> Void) {
    Task {
      isShowIndicator = true
      do {
        guard let session = netspendDataManager.sdkSession else { return }
        let encryptedData = try session.encryptWithJWKSet(
          value: [Constants.NetSpendKey.verificationValue.rawValue: generatedCVV]
        )
        let request = VerifyCVVCodeParameters(
          verificationType: Constants.NetSpendKey.cvc.rawValue, encryptedData: encryptedData
        )
        let response = try await verifyCardUseCase.execute(
          requestParam: request,
          cardID: cardID,
          sessionID: accountDataManager.sessionID
        )
        isShowIndicator = false
        completion(response.id)
      } catch {
        isShowIndicator = false
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - Private Functions
private extension NSEnterCVVCodeViewModel {
  func observeCVVInput() {
    $generatedCVV
      .map { [weak self] cvv in
        guard let self else {
          return false
        }
        return cvv.count == cvvCodeDigits
      }
      .assign(to: &$isCVVCodeEntered)
  }
}
