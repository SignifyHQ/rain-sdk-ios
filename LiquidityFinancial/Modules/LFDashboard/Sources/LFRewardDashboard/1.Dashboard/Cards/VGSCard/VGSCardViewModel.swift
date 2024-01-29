import Foundation
import Combine
import Factory
import SolidData
import SolidDomain
import LFStyleGuide
import LFUtilities
import LFLocalizable
import GeneralFeature
import VGSShowSDK
import Services
import SwiftUI

@MainActor
final class VGSCardViewModel: ObservableObject {
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  
  lazy var createVGSShowTokenUseCase: SolidCreateVGSShowTokenUseCaseProtocol = {
    SolidCreateVGSShowTokenUseCase(repository: solidCardRepository)
  }()
  
  @Published var isCardAvailable = false
  @Published var isShowCardNumber = false
  @Published var isShowExpDateAndCVVCode = false
  @Published var copyMessage: String?
  @Published var toastMessage: String?

  let card: CardModel
  let vgsShow = VGSShow(id: LFServices.vgsConfig.id, environment: LFServices.vgsConfig.env)
  private let pasteboard = UIPasteboard.general
  
  private var subscribers: Set<AnyCancellable> = []
  
  init(card: CardModel) {
    self.card = card
    getVGSShowTokenAPI()
  }
}

// MARK: - API Handler
private extension VGSCardViewModel {
  func getVGSShowTokenAPI() {
    Task {
      guard card.cardStatus != .closed else {
        isCardAvailable = true
        return
      }
      isCardAvailable = false
      
      do {
        let response = try await createVGSShowTokenUseCase.execute(cardID: card.id)
        revealCard(showToken: response.showToken, cardID: response.solidCardId)
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Handler
extension VGSCardViewModel {
  func hideSensitiveData() {
    isShowCardNumber = false
    isShowExpDateAndCVVCode = false
  }
  
  func copyToClipboard(from type: VGSLabelType) {
    let vgsText = getVGSLabelText(with: type.rawValue)
    
    switch type {
    case .cardNumber:
      pasteboard.string = vgsText
      copyMessage = L10N.Common.Card.CardNumberCopied.title
    case .expDateAndCVV:
      pasteboard.string = "\(card.expirationDate) \(vgsText)"
      copyMessage = L10N.Common.Card.ExpAndCVVCodeCopied.title
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      self?.copyMessage = nil
    }
  }
  
  func showCardNumber() {
    isShowCardNumber = true
  }
  
  func showExpDateAndCVVCode() {
    isShowExpDateAndCVVCode = true
  }
}

// MARK: - Private Functions
private extension VGSCardViewModel {
  func revealCard(showToken: String, cardID: String) {
    let path = "/v1/card/\(cardID)/show"
    vgsShow.customHeaders = ["sd-show-token": showToken]
    
    vgsShow.request(path: path, method: .get) { [weak self] requestResult in
      guard let self else { return }
      
      switch requestResult {
      case let .success(code):
        self.isCardAvailable = true
        log.info("VGSShow success, code: \(code)")
      case let .failure(code, _):
        log.error("VGSShow failed with code: \(code)")
      }
    }
  }
  
  func getVGSLabelText(with index: Int) -> String {
    guard index <= vgsShow.subscribedLabels.count else {
      return .empty
    }
    let text = vgsShow.subscribedLabels[index] as VGSLabel
    text.copyTextToClipboard()
    
    return pasteboard.string ?? .empty
  }
}

// MARK: - Types
extension VGSCardViewModel {
  enum VGSLabelType: Int {
    case cardNumber
    case expDateAndCVV
  }
}
