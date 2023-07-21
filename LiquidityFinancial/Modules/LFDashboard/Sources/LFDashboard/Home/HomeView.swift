import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

public struct HomeView: View {
  @StateObject private var viewModel: HomeViewModel
  let tabOptions: [TabOption]
  
  public init(viewModel: HomeViewModel, tabOptions: [TabOption]) {
    _viewModel = .init(wrappedValue: viewModel)
    self.tabOptions = tabOptions
  }
  
  public var body: some View {
    VStack(spacing: 0) {
      ZStack {
        ForEach(tabOptions, id: \.self) { option in
          DashboardView(option: option) { option in
            viewModel.tabSelected = option
          }
          .opacity(viewModel.tabSelected == option ? 1 : 0)
        }
      }
      tabBar
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        trailingNavigationBarView
      }
      ToolbarItem(placement: .navigationBarLeading) {
        leadingNavigationBarView
      }
    }
    //    .navigationLink(item: $viewModel.navigation) { item in
    //      switch item {
    //        case let .searchCauses(vm):
    //          SearchCausesView(viewModel: vm)
    //        case let .editRewards(vm):
    //          EditRewardsView(viewModel: vm)
    //        case .profile:
    //          ProfileView()
    //      }
    //    }
    //    .fullScreenCover(item: $viewModel.fullScreen) { item in
    //      switch item {
    //        case let .newUser(viewModel):
    //          NewUserView(viewModel: viewModel)
    //      }
    //    }
  }
}

// MARK: - View Components
private extension HomeView {
  var leadingNavigationBarView: some View {
    Text(viewModel.tabSelected.title)
      .font(Fonts.Inter.bold.swiftUIFont(size: Constants.FontSize.navigationBar.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.leading, 12)
  }
  
  var tabBar: some View {
    HStack(spacing: 0) {
      ForEach(tabOptions, id: \.self) { option in
        tabItem(option: option)
        if option != tabOptions.last {
          Spacer()
        }
      }
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 2)
    .padding(.top, 4)
    .background(Colors.secondaryBackground.swiftUIColor)
  }
  
  func tabItem(option: TabOption) -> some View {
    VStack(spacing: 2) {
      option.imageAsset.swiftUIImage
        .foregroundColor(
          option == viewModel.tabSelected ? Colors.primary.swiftUIColor : Colors.label.swiftUIColor
        )
      Text(option.title)
        .foregroundColor(
          option == viewModel.tabSelected ? Colors.label.swiftUIColor : Colors.label.swiftUIColor.opacity(0.75)
        )
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.small.value))
    }
    .onTapGesture {
      viewModel.onSelectedTab(tab: option)
    }
  }
  
  var trailingNavigationBarView: some View {
    HStack(spacing: 12) {
      if viewModel.isShowGearButton {
        Button {
          viewModel.onClickedGearButton()
        } label: {
          GenImages.CommonImages.icGear.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
      Button {
        viewModel.onClickedProfileButton()
      } label: {
        GenImages.CommonImages.icProfile.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
      }
      .padding(.trailing, 12)
    }
  }
}
