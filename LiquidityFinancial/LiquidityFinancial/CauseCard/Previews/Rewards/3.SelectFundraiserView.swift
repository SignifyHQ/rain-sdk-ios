import LFRewards
import LFUtilities
import SwiftUI
import RewardData
import RewardDomain

//swiftlint:disable all
var fundraiserModel: [FundraiserModel] {
  let objects = FileHelpers.readJSONFile(forName: "FundraiserData", type: [APICategoriesFundraisers].self)
  return objects?.compactMap({ FundraiserModel(fundraiserData: $0) }) ?? []
}

#Preview {
  SelectFundraiserView(
    viewModel: SelectFundraiserViewModel(
      causeModel: causeModel.first!,
      fundraisers: fundraiserModel,
      showSkipButton: true)
  )
  .embedInNavigation()
}
