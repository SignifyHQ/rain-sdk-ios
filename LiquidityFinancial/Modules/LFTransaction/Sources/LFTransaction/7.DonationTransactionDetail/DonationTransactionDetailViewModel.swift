import Foundation
import Factory
import LFServices

class DonationTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.customSupportService) var customSupportService
  
  @Published var navigation: Navigation?
  
  init() {
  }
  
  func goToReceiptScreen(receipt: DonationReceipt) {
    navigation = .receipt(receipt)
  }
  
  func openSupportScreen() {
    customSupportService.openSupportScreen()
  }
}

// MARK: - Types
extension DonationTransactionDetailViewModel {
  enum Navigation {
    case receipt(DonationReceipt)
  }
}
