import Foundation
import Factory
import Services
import LFLocalizable
import LFUtilities

class DonationTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  var isDonationsCard: Bool {
    LFUtilities.charityEnabled
  }
  
  let disclosureString = LFLocalizable.TransactionDetail.RewardDisclosure.description
  let termsLink = LFLocalizable.TransactionDetail.RewardDisclosure.Links.terms
  
  @Published var navigation: Navigation?
  
  init() {
  }
  
  func goToReceiptScreen(receipt: DonationReceipt) {
    navigation = .receipt(receipt)
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func getUrl(for link: String) -> URL? {
    switch link {
    case termsLink:
      return URL(string: LFUtilities.termsURL)
    default:
      return nil
    }
  }
}

// MARK: - Types
extension DonationTransactionDetailViewModel {
  enum Navigation {
    case receipt(DonationReceipt)
  }
}
