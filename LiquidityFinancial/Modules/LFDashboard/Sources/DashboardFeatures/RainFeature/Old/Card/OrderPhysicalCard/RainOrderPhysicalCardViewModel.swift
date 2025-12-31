import BaseOnboarding
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
  
  lazy var orderPhysicalCardWithApprovalUseCase: RainOrderPhysicalCardWithApprovalUseCaseProtocol = {
    RainOrderPhysicalCardWithApprovalUseCase(repository: rainCardRepository)
  }()
  
  @Published var isOrderingCard: Bool = false
  @Published var isShowOrderSuccessPopup: Bool = false
  @Published var toastMessage: String?
  @Published var fees: Double = 0
  
  @Published var shippingAddress: ShippingAddress?
  @Published var navigation: Navigation?
  
  let onOrderSuccess: ((CardModel) -> Void)?
  
  var walletAddress: String {
    accountDataManager.collateralContract?.address ?? .empty
  }
  
  init(onOrderSuccess: ((CardModel) -> Void)?) {
    self.onOrderSuccess = onOrderSuccess
    //getUser(from: accountDataManager.userInfomationData)
  }
}

// MARK: - API
extension RainOrderPhysicalCardViewModel {
  func getUser(from userEntity: UserInfomationDataProtocol) {
    shippingAddress = ShippingAddress(
      line1: userEntity.addressLine1 ?? .empty,
      line2: userEntity.addressLine2 ?? .empty,
      city: userEntity.city ?? .empty,
      state: userEntity.state ?? .empty,
      postalCode: userEntity.postalCode ?? .empty,
      country: Country(rawValue: userEntity.country ?? "") ?? Country(title: userEntity.country ?? "") ?? .US
    )
  }
  
  func orderPhysicalCard() {
    guard let shippingAddress,
          !shippingAddress.line1.isEmpty
    else {
      return
    }
    
    isOrderingCard = true
    
    Task {
      do {
        let parameters = generateOrderPhysicalCardParameter(with: shippingAddress)
        var card: CardModel = .physicalDefault
        
        // If the user uses freeform address input, we are creating an order which will be verified by the support team
        if shippingAddress.requiresVerification {
          let response = try await orderPhysicalCardWithApprovalUseCase.execute(parameters: parameters)
          card = CardModel(order: response)
          
          // If the user fills the address using Google autocomplete, we order the card right away
        } else {
          let response = try await orderPhysicalCardUseCase.execute(parameters: parameters)
          card = CardModel(card: response)
        }
        
        self.onOrderSuccess?(
          card
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
  func generateOrderPhysicalCardParameter(with shippingAddress: ShippingAddress) -> APIRainOrderCardParameters {
    let address = APIRainShippingAddressParameters(
      line1: shippingAddress.line1,
      line2: shippingAddress.line2,
      city: shippingAddress.city,
      region: shippingAddress.state,
      postalCode: shippingAddress.postalCode,
      countryCode: shippingAddress.country.rawValue,
      country: shippingAddress.country.title
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
