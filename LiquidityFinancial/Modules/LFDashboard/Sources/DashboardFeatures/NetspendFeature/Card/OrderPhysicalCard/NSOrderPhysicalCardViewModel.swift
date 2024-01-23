import NetSpendData
import NetspendDomain
import Foundation
import LFStyleGuide
import LFUtilities
import Factory
import Services
import SwiftUI
import OnboardingData
import AccountData
import AccountDomain

@MainActor
final class NSOrderPhysicalCardViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  lazy var orderPhysicalCardUseCase: NSOrderPhysicalCardUseCaseProtocol = {
    NSOrderPhysicalCardUseCase(repository: cardRepository)
  }()
  
  @Published var isOrderingCard: Bool = false
  @Published var isShowOrderSuccessPopup: Bool = false
  @Published var toastMessage: String?
  @Published var fees: Double = 5
  
  @Published var shippingAddress: ShippingAddress?
  @Published var navigation: Navigation?
  
  let onOrderSuccess: ((CardModel) -> Void)?
  
  init(onOrderSuccess: ((CardModel) -> Void)?) {
    self.onOrderSuccess = onOrderSuccess
    getUser(from: accountDataManager.userInfomationData)
  }
}

// MARK: - API
extension NSOrderPhysicalCardViewModel {
  func getUser(from userEntity: UserInfomationDataProtocol) {
    shippingAddress = ShippingAddress(
      line1: userEntity.addressLine1 ?? .empty,
      line2: userEntity.addressLine2,
      city: userEntity.city ?? .empty,
      state: userEntity.state ?? .empty,
      postalCode: userEntity.postalCode ?? .empty,
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
        let response = try await orderPhysicalCardUseCase.execute(
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
        log.error(error.userFriendlyMessage)
        self.toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Helpers
extension NSOrderPhysicalCardViewModel {
  func onClickedEditAddressButton(shippingAddress: Binding<ShippingAddress?>) {
    let destinationView = NSShippingAddressView(
      viewModel: NSShippingAddressViewModel(shippingAddress: shippingAddress)
    )
    navigation = .shippingAddress(AnyView(destinationView))
  }
  
  func primaryOrderSuccessAction() {
    isShowOrderSuccessPopup = false
  }
}

// MARK: - Private Functions
private extension NSOrderPhysicalCardViewModel {
  func mapToCardModel(entity: NSCardEntity) -> CardModel {
    CardModel(
      id: entity.liquidityCardId,
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
extension NSOrderPhysicalCardViewModel {
  enum Navigation {
    case shippingAddress(AnyView)
  }
}
