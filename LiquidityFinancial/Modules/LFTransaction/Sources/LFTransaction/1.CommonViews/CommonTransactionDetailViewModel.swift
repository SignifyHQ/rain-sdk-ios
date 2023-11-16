import SwiftUI
import Factory
import LFUtilities
import LFLocalizable

@MainActor
public final class CommonTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  let disclosureString = LFLocalizable.TransactionDetail.RewardDisclosure.description
  let termsLink = LFLocalizable.TransactionDetail.RewardDisclosure.Links.terms
  
  public init() {}
  
  var isDonationsCard: Bool {
    LFUtilities.charityEnabled
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
