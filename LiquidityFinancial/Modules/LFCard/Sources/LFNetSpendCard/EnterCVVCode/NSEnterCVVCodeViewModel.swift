import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import NetSpendData
import NetspendDomain
import Factory
import AccountData
import BaseCard

@MainActor
public final class NSEnterCVVCodeViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository

  @Published public var isShowSetPinSuccessPopup: Bool = false
  @Published public var isShown: Bool = true
  @Published public var isShowIndicator: Bool = false
  @Published public var isCVVCodeEntered: Bool = false
  
  @Published public var generatedCVV: String = .empty
  @Published public var toastMessage: String?
  
  public let cardID: String
  public let cvvCodeDigits = Int(Constants.Default.cvvCodeDigits.rawValue) ?? 3
  
  lazy var verifyCardUseCase: NSVerifyCVVCodeUseCaseProtocol = {
    NSVerifyCVVCodeUseCase(repository: cardRepository)
  }()
  
  public init(cardID: String) {
    self.cardID = cardID
    observeCVVInput()
  }
}

// MARK: - API Handle
public extension NSEnterCVVCodeViewModel {
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

// MARK: - View Helpers
public extension NSEnterCVVCodeViewModel {
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
