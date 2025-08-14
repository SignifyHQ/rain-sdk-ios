import SwiftUI
import LFLocalizable
import LFAccessibility
import LFStyleGuide
import LFUtilities
import Combine
import GeneralFeature
import RainOnboarding
import Factory
import RainFeature
import LFAuthentication

public struct HomeView: View {
  
  @Environment(\.scenePhase)
  var scenePhase
  
  @StateObject
  private var viewModel: HomeViewModel
  
  // Ensure each TabOptionView is initialized only once
  let cashView: CashView
  let rewardsTabView: RewardTabView
  let assetsView: CreditLimitBreakdownView
  let accountsView: AccountsView
  
  var onChangeRoute: ((RainOnboardingFlowCoordinator.Route) -> Void)?
  
  public init(onChangeRoute: ((RainOnboardingFlowCoordinator.Route) -> Void)? = nil) {
    let dashboardRepository = DashboardRepository()
    
    cashView = CashView(
      viewModel: CashViewModel(),
      listCardViewModel: RainListCardsViewModel()
    )
    rewardsTabView = RewardTabView(viewModel: RewardTabViewModel())
    assetsView = CreditLimitBreakdownView(viewModel: CreditLimitBreakdownViewModel())
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
      case .transactionDetail(let id):
        TransactionDetailView(
          method: .transactionID(id)
        )
      }
    }
    .popup(
      item: $viewModel.popup,
      dismissMethods: []
    ) { popup in
      switch popup {
      case .notifications:
        notificationsPopup
      case .specialExperience:
        specialExperiencePopup
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkGoTransactionDetail()
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
//      case .rewards:
//        rewardsTabView
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
    .padding(.top, 10)
    .background(Colors.secondaryBackground.swiftUIColor)
  }
  
  var leadingNavigationBarView: some View {
    Text(viewModel.tabSelected.title)
      .font(Fonts.orbitronBold.swiftUIFont(size: Constants.FontSize.navigationBar.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.leading, 12)
  }
  
  func tabItem(option: TabOption) -> some View {
    VStack(spacing: 4) {
      ZStack {
        RoundedRectangle(cornerRadius: 16)
          .fill(option == viewModel.tabSelected ? Colors.primary.swiftUIColor : .clear)
          .frame(width: 58, height: 32)
        option.imageAsset
      }
      .tint(Colors.primary.swiftUIColor)
      
      Text(option.title)
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
      title: L10N.Common.NotificationPopup.title,
      message: L10N.Common.NotificationPopup.subtitle,
      primary: .init(
        text: L10N.Common.NotificationPopup.action,
        action: viewModel.notificationsPopupAction
      ),
      secondary: .init(
        text: L10N.Common.NotificationPopup.dismiss,
        action: {
          viewModel.clearPopup()
          viewModel.presentNextPopupInQueue(removing: .notifications)
        }
      )
    )
  }
  
  private var specialExperiencePopup: some View {
    LiquidityAlert(
      title: "10 FRNT Tokens Added\nto Your Account".uppercased(),
      message: "You’ve just received 10 Frontier Stable Tokens (FRNT) as part of the Wyoming event experience.",
      primary: .init(
        text: "Go to My Account",
        action: {
          viewModel.onSpecialExperiencePopupDismiss()
          viewModel.goToAssets()
        }
      ),
      secondary: .init(
        text: "Got it",
        action: {
          viewModel.onSpecialExperiencePopupDismiss()
        }
      )
    )
  }
}
