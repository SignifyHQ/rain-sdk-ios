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
final class ShippingAddressConfirmationViewModel: ObservableObject {
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
  @Published var toastMessage: String?
  @Published var fees: Double = 0
  
  var fullName: String {
    if let firstName = accountDataManager.userInfomationData.firstName,
       let lastName = accountDataManager.userInfomationData.lastName {
      return firstName + " " + lastName
    }
    
    return accountDataManager.userInfomationData.fullName ?? accountDataManager.userNameDisplay
  }
  
  var phoneNumber: String {
    var phoneCode = ""
    var localNumber = (accountDataManager.userInfomationData.phone ?? accountDataManager.phoneNumber)
    // Attempt to match the country by phone's number country code
    if let matchedCountry = Country.allCases
      .sorted(
        by: {
          $0.phoneCode.count > $1.phoneCode.count
        }
      )
        .first(
          where: {
            localNumber.hasPrefix($0.phoneCode)
          }
        ) {
      // Store phone code separately
      phoneCode = matchedCountry.phoneCode
      // Strip the phone number removing code
      localNumber = String(localNumber.dropFirst(phoneCode.count))
    }
    // Format the number without code
    let formattedLocal = localNumber.formatInput(of: .phoneNumber)
    // Return formated phone number with code if detected
    return [phoneCode, formattedLocal]
      .filter {
        !$0.isEmpty
      }
      .joined(
        separator: " "
      )
  }
  
  let shippingAddress: ShippingAddress
  let onOrderSuccess: ((CardModel) -> Void)?
  
  init(
    shippingAddress: ShippingAddress,
    onOrderSuccess: ((CardModel) -> Void)?
  ) {
    self.onOrderSuccess = onOrderSuccess
    self.shippingAddress = shippingAddress
  }
}

// MARK: - Handle Interactions
extension ShippingAddressConfirmationViewModel {
  func orderPhysicalCard() {
    guard !shippingAddress.line1.isEmpty
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
        
        self.isOrderingCard = false
        
        self.onOrderSuccess?(
          card
        )
      } catch {
        self.isOrderingCard = false
        log.error(error.userFriendlyMessage)
        self.toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - Helpers
private extension ShippingAddressConfirmationViewModel {
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
