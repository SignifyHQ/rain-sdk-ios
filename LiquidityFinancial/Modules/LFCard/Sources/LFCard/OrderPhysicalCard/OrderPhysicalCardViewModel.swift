import Combine
import Foundation
import UIKit
import LFStyleGuide
import LFUtilities

@MainActor
final class OrderPhysicalCardViewModel: ObservableObject {
  @Published var isOrderingCard: Bool = false
  @Published var isShowOrderSuccessPopup: Bool = false
  @Published var fees: Double = 0
  @Published var shippingAddress: ShippingAddress = .default // Change to cardholder address
  @Published var navigation: Navigation?
  
  init() {
  }
}

// MARK: - API Handle
extension OrderPhysicalCardViewModel {
  func orderPhysicalCard() {
    isOrderingCard = true
    // FAKE CALL API
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.isOrderingCard = false
      self.isShowOrderSuccessPopup = true
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
}

// MARK: - Types
extension OrderPhysicalCardViewModel {
  enum Navigation {
    case shippingAddress
  }
}
