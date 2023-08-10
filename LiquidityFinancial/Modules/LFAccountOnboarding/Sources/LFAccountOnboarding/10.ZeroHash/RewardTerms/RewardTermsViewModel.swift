import LFLocalizable
import Combine
import Factory

@MainActor
final class RewardTermsViewModel: ObservableObject {
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator

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
}
