import Foundation
import UIKit
import VGSShowSDK
import LFUtilities
import LFServices
import UniformTypeIdentifiers

final class CardViewModel: ObservableObject, Identifiable {
  @Published var cardModel: CardModel
  @Published var isCardAvailable = false
  @Published var isShowCardCopyMessage = false
  @Published var cardNumber: String = ""
  @Published var expirationTime: String = ""
  @Published var cvvNumber: String = ""

  init(cardModel: CardModel) {
    self.cardModel = cardModel
    hideCardInformation()
  }
}

// MARK: - View Helpers
extension CardViewModel {
  func copyAction(cardNumber: String?) {
    guard let cardNumber else { return }
    UIPasteboard.general.setValue(
      cardNumber,
      forPasteboardType: UTType.plainText.identifier
    )
    isShowCardCopyMessage = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      self?.isShowCardCopyMessage = false
    }
  }
  
  func hideCardInformation() {
    cardNumber = "\(Constants.Default.cardNumberPlaceholder.rawValue)\(cardModel.last4)"
    expirationTime = Constants.Default.expirationDatePlaceholder.rawValue
    cvvNumber = Constants.Default.cvvPlaceholder.rawValue
  }
}
