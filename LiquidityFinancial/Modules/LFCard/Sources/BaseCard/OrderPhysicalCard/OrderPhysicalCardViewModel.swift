import NetSpendData
import Foundation
import LFStyleGuide
import LFUtilities
import Factory
import LFServices
import SwiftUI
import OnboardingData
import AccountData
import AccountDomain
import NetspendDomain

public struct OrderPhysicalCardDestinationObservable {
  var navigation: Navigation?
  
  public enum Navigation {
    case shippingAddress(AnyView)
  }
}

@MainActor
public protocol OrderPhysicalCardViewModelProtocol: ObservableObject {
  // Published Properties
  var isOrderingCard: Bool { get set }
  var isShowOrderSuccessPopup: Bool { get set }
  var fees: Double { get set }
  var shippingAddress: ShippingAddress? { get set }
  var toastMessage: String? { get set }
  
  // Normal Properties
  var onOrderSuccess: ((CardModel) -> Void)? { get }
  
  var coordinator: BaseCardDestinationObservable { get }
  
  init(coordinator: BaseCardDestinationObservable, onOrderSuccess: ((CardModel) -> Void)?)
  
  // API
  func getUser(from userEntity: UserInfomationDataProtocol)
  func orderPhysicalCard()
  
  // View Helpers
  func onClickedEditAddressButton(shippingAddress: Binding<ShippingAddress?>)
  func primaryOrderSuccessAction()
}

public extension OrderPhysicalCardViewModelProtocol {
  func mapToCardModel(entity: CardEntity) -> CardModel {
    CardModel(
      id: entity.id,
      cardType: CardType(rawValue: entity.type) ?? .virtual,
      cardholderName: nil,
      expiryMonth: entity.expirationMonth,
      expiryYear: entity.expirationYear,
      last4: entity.panLast4,
      cardStatus: CardStatus(rawValue: entity.status) ?? .unactivated
    )
  }
  
  func setNavigationCoordinator(destinationView: OrderPhysicalCardDestinationObservable.Navigation) {
    coordinator.orderPhysicalCardDestinationObservable.navigation = destinationView
  }
}
