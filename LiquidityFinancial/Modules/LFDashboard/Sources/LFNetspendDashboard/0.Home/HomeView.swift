import SwiftUI
import LFLocalizable
import LFAccessibility
import LFStyleGuide
import LFUtilities
import Combine
import GeneralFeature
import NetspendOnboarding
import Factory
import NetspendFeature
import LFAuthentication

public struct HomeView: View {
  
  @Environment(\.scenePhase)
  var scenePhase
  
  @StateObject
  private var viewModel: HomeViewModel
  
  // Ensure each TabOptionView is initialized only once
  let cashView: CashView
  let rewardsTabView: RewardTabView
  let assetsView: AssetsView
  let accountsView: AccountsView
  
  var onChangeRoute: ((NSOnboardingFlowCoordinator.Route) -> Void)?
  
  public init(onChangeRoute: ((NSOnboardingFlowCoordinator.Route) -> Void)? = nil) {
    let dashboardRepository = DashboardRepository()
    
    cashView = CashView(
      viewModel: CashViewModel(dashboardRepository: dashboardRepository),
      listCardViewModel: NSListCardsViewModel(
        coordinator: Container().baseCardDestinationObservable.callAsFunction()
      )
    )
    rewardsTabView = RewardTabView(viewModel: RewardTabViewModel(dashboardRepo: dashboardRepository))
    assetsView = AssetsView(viewModel: AssetsViewModel(dashboardRepository: dashboardRepository))
    accountsView = AccountsView(viewModel: AccountViewModel(dashboardRepository: dashboardRepository))
    
    _viewModel = .init(
      wrappedValue: HomeViewModel(
        dashboardRepository: dashboardRepository,
        tabOptions: TabOption.allCases
      )
    )
    self.onChangeRoute = onChangeRoute
  }
  
  public var body: some View {
    ZStack(alignment: .bottom) {
      dashboardView
      tabBarItems
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
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkGoTransactionDetail()
        viewModel.dashboardRepository.fetchNetspendLinkedSources()
      }
    })
  }
}

// MARK: - View Components
private extension HomeView {
  var dashboardView: some View {
    Group {
      switch viewModel.tabSelected {
      case .cash:
        cashView
      case .rewards:
        rewardsTabView
      case .assets:
        assetsView
      case .account:
        accountsView
      }
    }
    .padding(.bottom, 50)
  }
  
  var tabBarItems: some View {
    HStack(spacing: 0) {
      ForEach(viewModel.tabOptions, id: \.self) { option in
        tabItem(option: option)
        if option != viewModel.tabOptions.last {
          Spacer()
        }
      }
    }
    .padding(.horizontal, 32)
    .padding(.bottom, 2)
    .padding(.top, 4)
    .background(Colors.secondaryBackground.swiftUIColor)
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
