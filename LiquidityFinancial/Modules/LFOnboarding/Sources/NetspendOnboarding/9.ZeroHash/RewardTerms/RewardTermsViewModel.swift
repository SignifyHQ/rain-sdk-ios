import LFLocalizable
import Combine
import Factory
import Services

@MainActor
final class RewardTermsViewModel: ObservableObject {
  @LazyInjected(\.nsOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  var disclaimerText: String {
    L10N.Common.RewardTerms.disclosuresFirst + "\n\n" +
    L10N.Common.RewardTerms.disclosuresSecond + "\n\n" +
    L10N.Common.RewardTerms.disclosuresThird + "\n\n" +
    L10N.Common.RewardTerms.disclosuresFourth + "\n\n" +
    L10N.Common.RewardTerms.disclosuresFifth
  }
  
  func onClickedContinueButton() {
    onboardingFlowCoordinator.set(route: .dashboard)
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}
