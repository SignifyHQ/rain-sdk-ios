import Foundation
import Factory
import LFServices

class DonationTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.intercomService) var intercomService
  
  @Published var navigation: Navigation?
  
  init() {
  }
  
  func goToReceiptScreen(receipt: DonationReceipt) {
    navigation = .receipt(receipt)
  }
  
  func openIntercom() {
    intercomService.openIntercom()
  }
}

// MARK: - Types
extension DonationTransactionDetailViewModel {
  enum Navigation {
    case receipt(DonationReceipt)
  }
}
