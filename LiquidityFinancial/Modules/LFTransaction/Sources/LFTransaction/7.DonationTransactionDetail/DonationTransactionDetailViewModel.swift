import Foundation
import Factory
import LFServices

class DonationTransactionDetailViewModel: ObservableObject {
  @Published var navigation: Navigation?
  
  init() {
  }
  
  func goToReceiptScreen(receipt: DonationReceipt) {
    navigation = .receipt(receipt)
  }
}

// MARK: - Types
extension DonationTransactionDetailViewModel {
  enum Navigation {
    case receipt(DonationReceipt)
  }
}
