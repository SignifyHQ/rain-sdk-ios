import SwiftUI
import LFLocalizable
import LFAccessibility
import LFStyleGuide
import LFUtilities
import LFRewards
import Factory
import Services
import LFAuthentication
import GeneralFeature
import SolidFeature
import SolidOnboarding
import LFFeatureFlags

public struct HomeView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.scenePhase) var scenePhase
  @StateObject private var viewModel: HomeViewModel
  @Injected(\.analyticsService) var analyticsService
  
  // Ensure each TabOptionView is initialized only once
  let cardsView = CardsTabView()
  let cashView = CashView(
    listCardViewModel: SolidListCardsViewModel()
  )
  let rewardsView = RewardsView(viewModel: .init())
  let unspecifiedRewardsView = UnspecifiedRewardsView(
    destination: AnyView(
      EditRewardsView(viewModel: EditRewardsViewModel())
    )
  )
  let donationsView = DonationsView(viewModel: .init())
  let causesView = CausesView(viewModel: CausesViewModel())
  let prideView = PrideCardCauseView(viewModel: PrideCardCauseViewModel())
  let accountView = AccountsView(viewModel: AccountViewModel())
  let cashAssetView = CashAssetView()
  
  var onChangeRoute: ((SolidOnboardingFlowCoordinator.Route) -> Void)?

  public init(viewModel: HomeViewModel, onChangeRoute: ((SolidOnboardingFlowCoordinator.Route) -> Void)? = nil) {
    _viewModel = .init(wrappedValue: viewModel)
    self.onChangeRoute = onChangeRoute
  }
  
  public var body: some View {
    ZStack(alignment: .bottom) {
      dashboardView
      tabBarItems
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      analyticsService.track(event: AnalyticsEvent(name: .viewedHome))
      viewModel.onAppear()
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        trailingNavigationBarView
          .blur(radius: viewModel.blurRadius)
      }
      ToolbarItem(placement: .navigationBarLeading) {
        leadingNavigationBarView
          .blur(radius: viewModel.blurRadius)
      }
    }
    .onChange(of: viewModel.isVirtualCardEnabled) { _ in
      viewModel.configureTabOption(with: viewModel.tabOptions)
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
      case .createPassword:
        CreatePasswordView(purpose: .createExistingUser) {}
      }
    }
    .popup(item: $viewModel.popup) { popup in
      switch popup {
      case .notifications:
        notificationsPopup
      case .biometricSetup:
        setupBiometricsPopup
      case .biometricsLockout:
        biometricLockoutPopup
      case .biometricNotEnrolled:
        biometricNotEnrolledPopup
      }
    }
    .popup(item: $viewModel.blockingPopup, dismissMethods: []) { popup in
      switch popup {
      case .passwordEnhancedSecurity:
        passwordEnhancedSecurityPopup
      }
    }
    .fullScreenCover(
      isPresented: $viewModel.shouldShowBiometricsFallback,
      onDismiss: {
        viewModel.isVerifyingBiometrics = false
      },
      content: {
        BiometricsBackupView()
      }
    )
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.onChangeScenePhaseIsActive()
      }
    })
    .blur(radius: viewModel.blurRadius)
    .onChange(of: viewModel.isVerifyingBiometrics) { isVerifying in
      withAnimation(.easeInOut(duration: 0.2)) {
        viewModel.blurRadius = isVerifying ? 8 : 0
      }
    }
  }
}

// MARK: - View Components
private extension HomeView {
  var dashboardView: some View {
    Group {
      switch viewModel.tabSelected {
      case .cards:
        cardsView
      case .cash:
        cashView
      case .cashAsset:
        cashAssetView
      case .rewards:
        rewardsView
      case .noneReward:
        unspecifiedRewardsView
      case .donation:
        donationsView
      case .causes:
        switch LFUtilities.target {
        case .CauseCard: causesView
        case .PrideCard, .PawsCard: prideView
        default: causesView
        }
      case .account:
        accountView
      }
    }
    .padding(.bottom, 50)
  }
  
  var leadingNavigationBarView: some View {
    Text(viewModel.tabSelected.title.uppercased())
      .font(Fonts.Montserrat.black.swiftUIFont(size: Constants.FontSize.navigationBar.value))
      .foregroundColor(Colors.label.swiftUIColor)
      .padding(.leading, 12)
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
  
  func tabItem(option: TabOption) -> some View {
    VStack(spacing: 4) {
      option.imageAsset
        .foregroundColor(
          option == viewModel.tabSelected ? Colors.label.swiftUIColor : Colors.label.swiftUIColor.opacity(0.5)
        )
      Text(option.title)
        .foregroundColor(
          option == viewModel.tabSelected ? Colors.label.swiftUIColor : Colors.label.swiftUIColor.opacity(0.5)
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
      .accessibilityIdentifier(LFAccessibility.HomeScreen.profileButton)
      .padding(.trailing, 12)
    }
  }
  
  var notificationsPopup: some View {
    LiquidityAlert(
      title: L10N.Common.NotificationPopup.title,
      message: L10N.Common.NotificationPopup.subtitle,
      primary: .init(
        text: L10N.Common.NotificationPopup.action,
        action: viewModel.notificationsPopupAction
      ),
      secondary: .init(
        text: L10N.Common.NotificationPopup.dismiss,
        action: viewModel.clearPopup
      )
    )
  }
  
  var passwordEnhancedSecurityPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Authentication.SetupEnhancedSecurity.title,
      message: L10N.Common.Authentication.SetupEnhancedSecurity.fullStep,
      primary: .init(
        text: L10N.Common.Button.Continue.title,
        action: viewModel.enhancedSecurityPopupAction
      )
    )
  }
  
  var setupBiometricsPopup: some View {
    SetupBiometricPopup(
      biometricType: viewModel.biometricType,
      primaryAction: {
        viewModel.onClickedSetupBiometricPrimaryButton()
      },
      secondaryAction: {
        viewModel.clearPopup()
      }
    )
  }
  
  var biometricLockoutPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Authentication.BiometricsLockoutError.title(viewModel.biometricType.title),
      message: L10N.Common.Authentication.BiometricsLockoutError.message(viewModel.biometricType.title),
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.clearPopup()
      }
    )
  }
  
  var biometricNotEnrolledPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Authentication.BiometricsNotEnrolled.title(viewModel.biometricType.title).uppercased(),
      message: L10N.Common.Authentication.BiometricsNotEnrolled.message(viewModel.biometricType.title),
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.clearPopup()
      }
    )
  }
}
