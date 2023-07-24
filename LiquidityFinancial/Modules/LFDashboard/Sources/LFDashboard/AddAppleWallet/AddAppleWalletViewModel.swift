import Foundation

@MainActor
final class AddAppleWalletViewModel: ObservableObject {
  @Published var isShowApplePay: Bool = false
  
  let cardModel: CardModel
  let onFinish: () -> Void

  init(cardModel: CardModel, onFinish: @escaping () -> Void) {
    self.cardModel = cardModel
    self.onFinish = onFinish
  }
}

// MARK: - View Helpers
extension AddAppleWalletViewModel {
  func onViewAppear() {
    // TODO: Will be implemented later
    //    let appState = UserModel.AppState(accountActivatedShown: true)
    //    guard let dictionary = appState.dictionary else {
    //      return
    //    }
    //    userManager.updateUser(param: ["appState": dictionary])
  }
  
  func onClickedAddToApplePay() {
    isShowApplePay = true
  }
}
