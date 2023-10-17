import SwiftUI
import LFTransaction
import LFLocalizable
import LFStyleGuide
import LFUtilities
import LFRewards
import BaseDashboard
import NetspendOnboarding
import LFBank
import Factory
import LFServices

public struct HomeView: View {
  
  @Injected(\.dashboardRepository) var dashboardRepository
  @Injected(\.analyticsService) var analyticsService
  
  @Environment(\.scenePhase) var scenePhase
  
  @StateObject private var viewModel: HomeViewModel
  
  var onChangeRoute: ((NSOnboardingFlowCoordinator.Route) -> Void)?

  public init(viewModel: HomeViewModel, onChangeRoute: ((NSOnboardingFlowCoordinator.Route) -> Void)? = nil) {
    _viewModel = .init(wrappedValue: viewModel)
    self.onChangeRoute = onChangeRoute
    dashboardRepository.load { toastMessage in
      viewModel.toastMessage = toastMessage
    }
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
      analyticsService.track(event: AnalyticsEvent(name: .viewedHome))
      UITabBar.appearance().backgroundColor = Color.white.uiColor
      viewModel.onAppear()
      dashboardRepository.apiFetchOnboardingState { route in
        onChangeRoute?(route)
      }
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
        SearchCausesView(viewModel: SearchFundraiserViewModel(onSelect: {
          
        }))
      case .editRewards:
        EditRewardsView(viewModel: EditRewardsViewModel())
      case .profile:
        ProfileView()
      case .transactionDetail(let id, let accountId):
        TransactionDetailView(
          accountID: accountId,
          transactionId: id
        )
      }
    }
    .popup(item: $viewModel.popup) { popup in
      switch popup {
      case .notifications:
        notificationsPopup
      }
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkGoTransactionDetail()
        viewModel.getListConnectedAccount()
      }
    })
  }
}

// MARK: - View Components
private extension HomeView {
  func loadTabView(option: TabOption) -> some View {
    DashboardView(dataStorages: dashboardRepository, option: option) { option in
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
      if viewModel.showSearchButton {
        Button {
          viewModel.onClickedSearchButton()
        } label: {
          GenImages.CommonImages.icSearch.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
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
  
  private var notificationsPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.NotificationPopup.title,
      message: LFLocalizable.NotificationPopup.subtitle,
      primary: .init(
        text: LFLocalizable.NotificationPopup.action,
        action: viewModel.notificationsPopupAction
      ),
      secondary: .init(
        text: LFLocalizable.NotificationPopup.dismiss,
        action: viewModel.clearPopup
      )
    )
  }

}
