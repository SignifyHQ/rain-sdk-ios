import Foundation
import UIKit
import VGSShowSDK
import LFUtilities
import Services
import UniformTypeIdentifiers
import LFStyleGuide
import LFLocalizable

final class CardDetailItemViewModel: ObservableObject, Identifiable {
  @Published public var cardModel: CardModel
  @Published public var isCardAvailable = false
  @Published public var cardNumber: String = .empty
  @Published public var expirationTime: String = .empty
  @Published public var cvvNumber: String = .empty
  @Published public var toastData: ToastData?
  
  var cardType: String {
    var type = cardModel.cardType.title
    if cardModel.cardStatus == .closed {
      type += " (Disabled)"
    }
    
    return type
  }
  
  init(cardModel: CardModel) {
    self.cardModel = cardModel
    hideCardInformation()
  }
}

// MARK: - View Helpers
extension CardDetailItemViewModel {
  func copyAction(cardNumber: String?) {
    guard let cardNumber else { return }
    UIPasteboard.general.setValue(
      cardNumber,
      forPasteboardType: UTType.plainText.identifier
    )
    toastData = .init(type: .success, title: L10N.Common.Card.CardNumberCopied.title)
  }
  
  func hideCardInformation() {
    if cardModel.cardType == .physical {
      let secretText = cardModel.cardStatus == .active ? cardModel.last4 : Constants.Default.physicalCardNumberPlaceholder.rawValue
      cardNumber = "\(Constants.Default.physicalCardNumberPlaceholder.rawValue)\(secretText)"
    } else {
      cardNumber = "\(Constants.Default.cardNumberPlaceholder.rawValue)\(cardModel.last4)"
    }
    
    expirationTime = Constants.Default.expirationDatePlaceholder.rawValue
    cvvNumber = Constants.Default.cvvPlaceholder.rawValue
  }
  
  func showCardInformation(cardMetaData: CardMetaData?) {
    if cardModel.cardType == .physical {
      let secretText = cardModel.cardStatus == .active ? cardModel.last4 : Constants.Default.physicalCardNumberPlaceholder.rawValue
      cardNumber = "\(Constants.Default.physicalCardNumberPlaceholder.rawValue)\(secretText)"
    } else {
      cardNumber = cardMetaData?.panFormatted ?? "\(Constants.Default.cardNumberPlaceholder.rawValue)\(cardModel.last4)"
      expirationTime = cardModel.expiryTime
      cvvNumber = cardMetaData?.cvv ?? Constants.Default.cvvPlaceholder.rawValue
    }
  }
}
