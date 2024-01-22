import Foundation
import UIKit
import VGSShowSDK
import LFUtilities
import Services
import UniformTypeIdentifiers
import SolidData
import SolidDomain
import Factory

@MainActor
public final class SolidCardViewModel: ObservableObject, Identifiable {
  @LazyInjected(\.solidCardRepository) var solidCardRepository

  @Published public var cardModel: CardModel
  @Published public var isCardAvailable = false
  @Published public var isShowCardCopyMessage = false
  @Published public var toastMessage: String?
  
  let vgsShow: VGSShow
  
  lazy var createVGSShowTokenUseCase: SolidCreateVGSShowTokenUseCaseProtocol = {
    SolidCreateVGSShowTokenUseCase(repository: solidCardRepository)
  }()

  public init(cardModel: CardModel) {
    vgsShow = VGSShow(id: LFServices.vgsConfig.id, environment: LFServices.vgsConfig.env)
    self.cardModel = cardModel
  }
}

// MARK: - API
extension SolidCardViewModel {
  func getVGSShowTokenAPI() {
    Task {
      isCardAvailable = false
      do {
        let token = try await createVGSShowTokenUseCase.execute(cardID: cardModel.id)
        revealCard(vgsShowToken: token.showToken, solidCardID: token.solidCardId)
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
extension SolidCardViewModel {
  func copyAction() {
    let cardNumberLabel = vgsShow.subscribedLabels[0] as VGSLabel
    cardNumberLabel.copyTextToClipboard()
    isShowCardCopyMessage = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      self?.isShowCardCopyMessage = false
    }
  }
}

// MARK: - Private Functions
private extension SolidCardViewModel {
  func revealCard(vgsShowToken: String, solidCardID: String) {
    let path = "/v1/card/\(solidCardID)/show"
    vgsShow.customHeaders = ["sd-show-token": vgsShowToken]
    vgsShow.request(path: path, method: .get) { [weak self] requestResult in
      switch requestResult {
      case let .success(code):
        self?.isCardAvailable = true
        log.info("VGSShow success, code: \(code)")
      case let .failure(code, _):
        log.error("VGSShow failed with code: \(code)")
      }
    }
  }
}
