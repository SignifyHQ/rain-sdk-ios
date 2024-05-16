import RainData
import RainDomain
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
final class RainOrderPhysicalCardViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  
  lazy var orderPhysicalCardUseCase: RainOrderPhysicalCardUseCaseProtocol = {
    RainOrderPhysicalCardUseCase(repository: rainCardRepository)
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
extension RainOrderPhysicalCardViewModel {
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
    guard let shippingAddress, !shippingAddress.line1.isEmpty else {
      return
    }
    
    isOrderingCard = true
    
    Task {
      do {
        let parameters = generateOrderPhysicalCardParameter(with: shippingAddress)
        let response = try await orderPhysicalCardUseCase.execute(parameters: parameters)
        
        self.onOrderSuccess?(
          mapToCardModel(card: response)
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
extension RainOrderPhysicalCardViewModel {
  func onClickedEditAddressButton(shippingAddress: Binding<ShippingAddress?>) {
    let destinationView = RainShippingAddressView(
      viewModel: RainShippingAddressViewModel(shippingAddress: shippingAddress)
    )
    navigation = .shippingAddress(AnyView(destinationView))
  }
  
  func primaryOrderSuccessAction() {
    isShowOrderSuccessPopup = false
  }
}

// MARK: - Private Functions
private extension RainOrderPhysicalCardViewModel {
  func mapToCardModel(card: RainCardEntity) -> CardModel {
    CardModel(
      id: card.cardId ?? card.rainCardId,
      cardType: CardType(rawValue: card.cardType) ?? .virtual,
      cardholderName: nil,
      expiryMonth: Int(card.expMonth ?? .empty) ?? 0,
      expiryYear: Int(card.expYear ?? .empty) ?? 0,
      last4: card.last4 ?? .empty,
      cardStatus: CardStatus(rawValue: card.cardStatus) ?? .unactivated
    )
  }
  
  func generateOrderPhysicalCardParameter(with shippingAddress: ShippingAddress) -> APIRainOrderCardParameters {
    let address = APIRainShippingAddressParameters(
      line1: shippingAddress.line1,
      line2: shippingAddress.line2,
      city: shippingAddress.city,
      region: shippingAddress.state,
      postalCode: shippingAddress.postalCode,
      countryCode: Constants.Default.regionCode.rawValue,
      country: shippingAddress.country ?? .empty
    )
    
    return APIRainOrderCardParameters(shippingAddress: address)
  }
}

// MARK: - Types
extension RainOrderPhysicalCardViewModel {
  enum Navigation {
    case shippingAddress(AnyView)
  }
}
