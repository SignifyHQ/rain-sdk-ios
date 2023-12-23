import SwiftUI
import LFTransaction
import LFLocalizable
import LFAccessibility
import LFStyleGuide
import LFUtilities
import LFRewards
import BaseDashboard
import SolidOnboarding
import LFSolidBank
import Factory
import Services
import LFAuthentication

public struct HomeView: View {
  @Injected(\.analyticsService) var analyticsService
  
  @Environment(\.scenePhase) var scenePhase
  
  @StateObject private var viewModel: HomeViewModel
  
  var onChangeRoute: ((SolidOnboardingFlowCoordinator.Route) -> Void)?

  public init(viewModel: HomeViewModel, onChangeRoute: ((SolidOnboardingFlowCoordinator.Route) -> Void)? = nil) {
    _viewModel = .init(wrappedValue: viewModel)
    self.onChangeRoute = onChangeRoute
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
      }
    ) {
      BiometricsBackupView()
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkGoTransactionDetail()
        viewModel.refreshLinkedSources()
      }
    })
    .blur(radius: viewModel.blurRadius)
    .onChange(of: viewModel.isVerifyingBiometrics) { isVerifying in
      withAnimation(.easeInOut(duration: 0.2)) {
        viewModel.blurRadius = viewModel.isVerifyingBiometrics ? 8 : 0
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
  
  var passwordEnhancedSecurityPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Authentication.SetupEnhancedSecurity.title,
      message: LFLocalizable.Authentication.SetupEnhancedSecurity.fullStep,
      primary: .init(
        text: LFLocalizable.Button.Continue.title,
        action: viewModel.enhancedSecurityPopupAction
      )
    )
  }
  
  var setupBiometricsPopup: some View {
    SetupBiometricPopup(
      biometricType: viewModel.biometricType,
      primaryAction: {
        viewModel.allowBiometricAuthentication()
      },
      secondaryAction: {
        viewModel.clearPopup()
      }
    )
  }
  
  var biometricLockoutPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Authentication.BiometricsLockoutError.title(viewModel.biometricType.title),
      message: LFLocalizable.Authentication.BiometricsLockoutError.message(viewModel.biometricType.title),
      primary: .init(text: LFLocalizable.Button.Ok.title) {
        viewModel.clearPopup()
      }
    )
  }
}
