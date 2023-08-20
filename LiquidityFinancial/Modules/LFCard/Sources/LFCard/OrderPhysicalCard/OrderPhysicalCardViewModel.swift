import NetSpendData
import NetSpendDomain
import Foundation
import LFStyleGuide
import LFUtilities
import Factory
import LFServices
import SwiftUI
import OnboardingData
import AccountData
import AccountDomain

@MainActor
final class OrderPhysicalCardViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  @Published var isOrderingCard: Bool = false
  @Published var isShowOrderSuccessPopup: Bool = false
  @Published var fees: Double = 0
  @Published var navigation: Navigation?
  @Published var shippingAddress: ShippingAddress?
  @Published var toastMessage: String?
  
  let onOrderSuccess: ((CardModel) -> Void)?
  lazy var cardUseCase: NSCardUseCaseProtocol = {
    NSCardUseCase(repository: cardRepository)
  }()
  
  init(onOrderSuccess: ((CardModel) -> Void)?) {
    self.onOrderSuccess = onOrderSuccess
    getUser(from: accountDataManager.userInfomationData)
  }
}

// MARK: - API Handle
extension OrderPhysicalCardViewModel {
  
  func getUser(from userEntity: UserInfomationDataProtocol) {
    shippingAddress = ShippingAddress(
      line1: userEntity.addressLine1 ?? "",
      line2: userEntity.addressLine2,
      city: userEntity.city ?? "",
      state: userEntity.state ?? "",
      postalCode: userEntity.postalCode ?? "",
      country: userEntity.country
    )
  }
  
  func orderPhysicalCard() {
    guard let shippingAddress = shippingAddress else {
      return
    }
    isOrderingCard = true
    Task {
      do {
        let address = AddressCardParameters(
          line1: shippingAddress.line1,
          line2: shippingAddress.line2,
          city: shippingAddress.city,
          state: shippingAddress.state,
          country: shippingAddress.country,
          postalCode: shippingAddress.postalCode
        )
        let response = try await cardUseCase.orderPhysicalCard(
          address: address,
          sessionID: accountDataManager.sessionID
        )
        self.onOrderSuccess?(
          mapToCardModel(entity: response)
        )
        self.isOrderingCard = false
        self.isShowOrderSuccessPopup = true
      } catch {
        self.isOrderingCard = false
        log.error(error.localizedDescription)
        self.toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - View Helpers
extension OrderPhysicalCardViewModel {
  func onClickedEditAddressButton() {
    navigation = .shippingAddress
  }
  
  func primaryOrderSuccessAction() {
    isShowOrderSuccessPopup = false
  }
}

// MARK: - Private Functions
private extension OrderPhysicalCardViewModel {
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
}

// MARK: - Types
extension OrderPhysicalCardViewModel {
  enum Navigation {
    case shippingAddress
  }
}
