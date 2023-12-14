import SwiftUI
import LFTransaction
import LFLocalizable
import LFAccessibility
import LFStyleGuide
import LFUtilities
import Combine
import BaseDashboard
import NetspendOnboarding
import LFNetspendBank
import Factory
import LFNetSpendCard

public struct HomeView: View {
  @Injected(\.dashboardRepository) var dashboardRepository
  
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
        if #available(iOS 17.0, *) {
          loadTabView(option: option)
            .toolbar(.visible, for: .tabBar)
            .toolbarBackground(Colors.secondaryBackground.swiftUIColor, for: .tabBar)
        } else {
          loadTabView(option: option)
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .tint(Colors.tabbarSelected.swiftUIColor)
    .onAppear {
      UITabBar.appearance().backgroundColor = Colors.secondaryBackground.swiftUIColor.uiColor
      UITabBar.appearance().unselectedItemTintColor = Colors.tabbarUnselected.swiftUIColor.uiColor
      UITabBarItem.appearance().setTitleTextAttributes(
        [
          NSAttributedString.Key.font: Fonts.orbitronMedium.font(size: 10),
          NSAttributedString.Key.foregroundColor: Colors.label.swiftUIColor.opacity(0.75).uiColor
        ],
        for: .normal
      )
      UITabBarItem.appearance().setTitleTextAttributes(
        [
          NSAttributedString.Key.font: Fonts.orbitronMedium.font(size: 10),
          NSAttributedString.Key.foregroundColor: Colors.label.swiftUIColor.uiColor
        ],
        for: .selected
      )
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
    .onAppear {
      viewModel.onAppear()
      dashboardRepository.apiFetchOnboardingState { route in
        onChangeRoute?(route)
      }
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkGoTransactionDetail()
        dashboardRepository.fetchNetspendLinkedSources()
      }
    })
  }
}

// MARK: - View Components
private extension HomeView {
  func loadTabView(option: TabOption) -> some View {
    DashboardView(option: option).tabItem {
      tabItem(option: option)
    }
    .tag(option)
  }
  
  var leadingNavigationBarView: some View {
    Text(viewModel.tabSelected.title)
      .font(Fonts.orbitronBold.swiftUIFont(size: Constants.FontSize.navigationBar.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.leading, 12)
  }
  
  func tabItem(option: TabOption) -> some View {
    VStack(spacing: 2) {
      option.imageAsset
        .foregroundColor(
          option == viewModel.tabSelected ? Colors.primary.swiftUIColor : Colors.label.swiftUIColor
        )
        .tint(Colors.primary.swiftUIColor)
      Text(option.title)
        .foregroundColor(
          option == viewModel.tabSelected ? Colors.label.swiftUIColor : Colors.label.swiftUIColor.opacity(0.75)
        )
        .font(Fonts.orbitronMedium.swiftUIFont(size: 10))
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
      .accessibilityIdentifier(LFAccessibility.HomeScreen.profileButton)
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
