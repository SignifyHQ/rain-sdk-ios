import Combine
import CardDomain
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities
import Factory
import LFServices
import SwiftUI
import OnboardingData
import AccountData

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
  
  lazy var cardUseCase: CardUseCaseProtocol = {
    CardUseCase(repository: cardRepository)
  }()
  
  init() {
    getUser()
  }
}

// MARK: - API Handle
extension OrderPhysicalCardViewModel {
  
  func getUser() {
    Task {
      do {
        let user = try await accountRepository.getUser(
          deviceId: UIDevice.current.identifierForVendor?.uuidString ?? ""
        )
        if let addressEntity = user.addressEntity {
          shippingAddress = ShippingAddress(line1: addressEntity.line1 ?? "", line2: addressEntity.line2, city: addressEntity.city ?? "", state: addressEntity.state ?? "", postalCode: addressEntity.postalCode ?? "", country: addressEntity.country)
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func orderPhysicalCard() {
    guard let shippingAddress = shippingAddress else {
      return
    }
    isOrderingCard = true
    Task {
      do {
        let address = PhysicalCardAddressEntity(
          line1: shippingAddress.line1,
          line2: shippingAddress.line2,
          city: shippingAddress.city,
          state: shippingAddress.state,
          country: shippingAddress.country,
          postalCode: shippingAddress.postalCode
        )
        _ = try await cardUseCase.orderPhysicalCard(
          address: address,
          sessionID: accountDataManager.sessionID
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

// MARK: - Types
extension OrderPhysicalCardViewModel {
  enum Navigation {
    case shippingAddress
  }
}
