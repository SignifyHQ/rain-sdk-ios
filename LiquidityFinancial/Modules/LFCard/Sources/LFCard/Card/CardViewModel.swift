import Foundation
import VGSShowSDK
import LFUtilities
import LFServices

final class CardViewModel: ObservableObject, Identifiable {
  @Published var cardModel: CardModel
  @Published var isCardAvailable = false
  @Published var isShowCardCopyMessage = false
  
  let vgsShow: VGSShow
  let networkEnvironment = EnvironmentManager().networkEnvironment
  
  init(cardModel: CardModel) {
    self.cardModel = cardModel
    vgsShow = networkEnvironment == .productionTest ? LFServices.vgsShowSandBox : LFServices.vgsShowLive
    getVGSShowTokenAPI()
  }
  
  private func getVGSShowTokenAPI() {
    // TODO: Will be removed - Fake call api
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.isCardAvailable = true
    }
//    CardsAPI().getVGSShowToken(cardID: cardModel.id) { [weak self] result in
//      switch result {
//        case let .success(vgsShowDetails):
//          guard let token = vgsShowDetails.showToken, let cardId = vgsShowDetails.solidCardId else {
//            return
//          }
//          self?.revealCard(vgsShowToken: token, solidCardId: cardId)
//        case let .failure(error):
//      }
//    }
  }
  
  private func revealCard(vgsShowToken: String, solidCardId: String) {
//    let path = "/v1/card/\(solidCardId)/show"
//    vgsShow.customHeaders = ["sd-show-token": vgsShowToken]
//    vgsShow.request(path: path, method: .get) { [weak self] requestResult in
//      switch requestResult {
//        case let .success(code):
//          self?.isCardAvailable = true
//          log.info("vgsshow success, code: \(code)")
//        case let .failure(code, error):
//          log.error(error ?? LiquidityError.logic, "vgsshow failed", userInfo: ["code": code])
//      }
//    }
  }
}

// MARK: - View Helpers
extension CardViewModel {
  func copyAction() {
    let lblCardNo = vgsShow.subscribedLabels[0] as VGSLabel
    lblCardNo.copyTextToClipboard()
    isShowCardCopyMessage = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      self?.isShowCardCopyMessage = false
    }
  }
}
