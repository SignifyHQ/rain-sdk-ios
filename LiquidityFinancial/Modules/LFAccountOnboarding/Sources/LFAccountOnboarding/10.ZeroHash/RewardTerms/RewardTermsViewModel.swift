import LFLocalizable
import Combine

@MainActor
final class RewardTermsViewModel: ObservableObject {
  
  var disclaimerText: String {
    LFLocalizable.RewardTerms.disclosuresFirst + "\n\n" +
    LFLocalizable.RewardTerms.disclosuresSecond + "\n\n" +
    LFLocalizable.RewardTerms.disclosuresThird + "\n\n" +
    LFLocalizable.RewardTerms.disclosuresFourth
  }
  
}
