import LFLocalizable
import Combine
import Factory
import Services

@MainActor
final class RewardTermsViewModel: ObservableObject {
  @LazyInjected(\.nsOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  var disclaimerText: String {
    LFLocalizable.RewardTerms.disclosuresFirst + "\n\n" +
    LFLocalizable.RewardTerms.disclosuresSecond + "\n\n" +
    LFLocalizable.RewardTerms.disclosuresThird + "\n\n" +
    LFLocalizable.RewardTerms.disclosuresFourth + "\n\n" +
    LFLocalizable.RewardTerms.disclosuresFifth
  }
  
  func onClickedContinueButton() {
    onboardingFlowCoordinator.set(route: .dashboard)
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}
