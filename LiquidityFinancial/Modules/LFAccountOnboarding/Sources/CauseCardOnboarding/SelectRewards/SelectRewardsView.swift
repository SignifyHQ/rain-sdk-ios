//import SwiftUI
//import LFStyleGuide
//import LFUtilities
//
//struct SelectRewardsView: View {
//  @StateObject private var viewModel: SelectRewardsViewModel
//  
//  init(viewModel: SelectRewardsViewModel) {
//    _viewModel = .init(wrappedValue: viewModel)
//  }
//  
//  var body: some View {
//    content
//      .background(Color.background)
//      .navigationBarHidden(true)
//      .popup(isPresented: $viewModel.showError, style: .toast) {
//        ToastView(toastMessage: "generic_ErrorMessage".localizedString)
//      }
//      .navigationLink(item: $viewModel.navigation) { item in
////        switch item {
////        case let .causeFilter(viewModel):
////          CauseFilterView(viewModel: viewModel)
////        case .personalInformation:
////          PersonalInformationView(isAppView: false)
////        }
//      }
//  }
//  
//  private var content: some View {
//    VStack {
//      asset
//      
//      VStack(alignment: .leading, spacing: 0) {
//        Image(GenImages.CommonImages.dash.swiftUIImage)
//          .foregroundColor(.label)
//        
//        titles
//          .padding(.top, 32)
//        
//        options
//          .padding(.top, 16)
//        
//        Spacer(minLength: 12)
//        
//        DonationsDisclosureView()
//          .padding(.bottom, 12)
//        
//        cta
//      }
//      .padding(.horizontal, 30)
//      .padding(.bottom, 10)
//    }
//  }
//  
//  private var asset: some View {
//    Image(Imagename.selectRewards)
//      .resizable()
//      .aspectRatio(contentMode: .fit)
//      .layoutPriority(1)
//  }
//  
//  private var titles: some View {
//    VStack(alignment: .leading, spacing: 4) {
//      Text("select_rewards.title".localizedString.uppercased())
//        .font(.fontLato_Regular(withSize: 18))
//        .foregroundColor(.label)
//      
//      Text(String(format: "select_rewards.subtitle".localizedString, Utility.appName))
//        .font(.fontLato_Regular(withSize: 12))
//        .foregroundColor(.label.opacity(0.75))
//    }
//    .fixedSize(horizontal: false, vertical: true)
//  }
//  
//  private var options: some View {
//    func option(_ item: ViewModel.Option) -> some View {
//      UserRewardRowView(type: .full, reward: item.userRewardType, selection: viewModel.selection(item))
//        .onTapGesture {
//          viewModel.optionSelected(item)
//        }
//    }
//    
//    return VStack(spacing: 10) {
//      option(.cashback)
//      option(.donation)
//    }
//  }
//  
//  private var cta: some View {
//    FullSizeButton(title: "select_rewards.continue".localizedString, isActionAllowed: viewModel.isContinueEnabled, isBtnEnable: viewModel.isContinueEnabled, isLoading: $viewModel.isLoading, addPading: false) {
//      viewModel.continueTapped()
//    }
//  }
//}
//
//#if DEBUG
//
//  // MARK: - SelectRewardsView_Previews
//
//struct SelectRewardsView_Previews: PreviewProvider {
//  static var previews: some View {
//    SelectRewardsView(viewModel: .init())
//  }
//}
//
//#endif
