import LFRewards
import LFUtilities
import SwiftUI
import RewardData
import RewardDomain

//swiftlint:disable all
var fundraiserDeatailModel: FundraiserDetailModel {
  let objects = FileHelpers.readJSONFile(forName: "FundraiserDetailData", type: APIFundraisersDetail.self)
  return FundraiserDetailModel(enity: objects!)
}

#Preview {
  FundraiserDetailView(
    viewModel: FundraiserDetailViewModel(fundraiserDetail: fundraiserDeatailModel, whereStart: .dashboard)
    )
  .embedInNavigation()
}
