import Foundation
import UIKit
import VGSShowSDK
import LFUtilities
import Services
import UniformTypeIdentifiers

public final class NSCardViewModel: ObservableObject, Identifiable {
  @Published public var cardModel: CardModel
  @Published public var isCardAvailable = false
  @Published public var isShowCardCopyMessage = false
  @Published public var cardNumber: String = .empty
  @Published public var expirationTime: String = .empty
  @Published public var cvvNumber: String = .empty

  public init(cardModel: CardModel) {
    self.cardModel = cardModel
    hideCardInformation()
  }
}

// MARK: - View Helpers
public extension NSCardViewModel {
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
    if cardModel.cardType == .physical {
      cardNumber = "\(Constants.Default.physicalCardNumberPlaceholder.rawValue)\(cardModel.last4)"
    } else {
      cardNumber = "\(Constants.Default.cardNumberPlaceholder.rawValue)\(cardModel.last4)"
    }
    expirationTime = Constants.Default.expirationDatePlaceholder.rawValue
    cvvNumber = Constants.Default.cvvPlaceholder.rawValue
  }
}
