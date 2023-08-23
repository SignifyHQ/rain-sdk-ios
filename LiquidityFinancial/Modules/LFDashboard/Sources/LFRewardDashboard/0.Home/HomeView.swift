import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities

public struct HomeView: View {
  
  @StateObject private var viewModel: HomeViewModel
  
  public init(tabOptions: [TabOption]) {
    _viewModel = .init(wrappedValue: HomeViewModel(tabOptions: tabOptions))
  }
  
  public var body: some View {
    TabView(selection: $viewModel.tabSelected) {
      ForEach(viewModel.tabOptions, id: \.self) { option in
        loadTabView(option: option)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .tint(ModuleColors.tabarHighlight.swiftUIColor)
    .onAppear {
      UITabBar.appearance().backgroundColor = Colors.secondaryBackground.swiftUIColor.uiColor
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        trailingNavigationBarView
      }
      ToolbarItem(placement: .navigationBarLeading) {
        leadingNavigationBarView
      }
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .searchCauses:
        EmptyView() // TODO: - Will be implemented later
      case .editRewards:
        EditRewardsView(viewModel: EditRewardsViewModel())
      case .profile:
        ProfileView()
      }
    }
  }
}

// MARK: - View Components
private extension HomeView {
  func loadTabView(option: TabOption) -> some View {
    DashboardView(option: option) { option in
      viewModel.tabSelected = option
    }.tabItem {
      tabItem(option: option)
    }
    .tag(option)
  }
  
  var leadingNavigationBarView: some View {
    Text(viewModel.tabSelected.title.uppercased())
      .font(Fonts.Montserrat.black.swiftUIFont(size: Constants.FontSize.navigationBar.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.leading, 12)
  }
  
  func tabItem(option: TabOption) -> some View {
    VStack(spacing: 4) {
      option.imageAsset
        .foregroundColor(
          option == viewModel.tabSelected ? ModuleColors.tabarHighlight.swiftUIColor : ModuleColors.tabarUnhighlight.swiftUIColor
        )
      Text(option.title)
        .foregroundColor(
          option == viewModel.tabSelected ? ModuleColors.tabarHighlight.swiftUIColor : ModuleColors.tabarUnhighlight.swiftUIColor
        )
        .font(Fonts.Montserrat.medium.swiftUIFont(size: 10))
    }
    .onTapGesture {
      viewModel.onSelectedTab(tab: option)
    }
  }
  
  var trailingNavigationBarView: some View {
    HStack(spacing: 12) {
      if viewModel.showGearButton {
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
