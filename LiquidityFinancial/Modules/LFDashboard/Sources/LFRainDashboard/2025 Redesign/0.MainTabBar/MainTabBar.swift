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

public struct MainTabBar: View {
  @Environment(\.scenePhase) var scenePhase
  @StateObject private var viewModel: MainTabBarModel
  
  let cardDetailsListViewModel: CardDetailsListViewModel = CardDetailsListViewModel()
  
  // Ensure each TabOptionView is initialized only once
  let dashboardCardView: DashboardView
  let assetsView: AssetsBreakdownView
  let accountsView: MyAccountView
  let onChangeRoute: ((RainOnboardingFlowCoordinator.Route) -> Void)?
  
  public init(onChangeRoute: ((RainOnboardingFlowCoordinator.Route) -> Void)? = nil) {
    let viewModel = MainTabBarModel(tabItems: TabItem.allCases)
    
    dashboardCardView = DashboardView(
      viewModel: DashboardViewModel(),
      cardDetailsListViewModel: cardDetailsListViewModel
    )
    assetsView = AssetsBreakdownView(viewModel: AssetsBreakdownViewModel())
    accountsView = MyAccountView(viewModel: viewModel.accountViewModel)
    
    _viewModel = .init(wrappedValue: viewModel)
    self.onChangeRoute = onChangeRoute
  }
  
  public var body: some View {
    ZStack(alignment: .bottom) {
      mainView
      tabBarItems
    }
    .navigationBarTitleDisplayMode(.inline)
    .tabNavBar(
      leadingTitle: viewModel.tabSelected.title,
      onRightButtonTap: {
        viewModel.onSupportButtonTap()
      }
    )
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .transactionDetail(let id):
        TransactionDetailsView(method: .transactionID(id))
      case .cardList:
        CardDetailsListView(viewModel: cardDetailsListViewModel)
      }
    }
    .sheetWithContentHeight(
      item: $viewModel.popup,
      interactiveDismissDisabled: true,
    ) { popup in
      switch popup {
      case .notifications:
        notificationsPopup
      case .specialExperience:
        specialExperiencePopup
      case .applePay:
        applePayPopup
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
    .onChange(
      of: scenePhase,
      perform: { newValue in
        if newValue == .active {
          viewModel.checkGoTransactionDetail()
        }
      }
    )
    .scrollIndicators(.hidden)
  }
}

// MARK: - View Components
extension MainTabBar {
  var mainView: some View {
    Group {
      switch viewModel.tabSelected {
      case .cash:
        dashboardCardView
      case .assets:
        assetsView
      case .account:
        accountsView
      }
    }
    .padding(.bottom, 50)
  }
  
  var tabBarItems: some View {
    VStack(spacing: 0) {
      lineView
      HStack(spacing: 0) {
        ForEach(viewModel.tabItems, id: \.self) { item in
          tabItem(item: item)
          if item != viewModel.tabItems.last {
            Spacer()
          }
        }
      }
      .padding(.horizontal, 32)
      .padding(.bottom, 2)
      .padding(.top, 16)
    }
    .background(Colors.baseAppBackground2.swiftUIColor)
  }
  
  func tabItem(item: TabItem) -> some View {
    let isSelected = item == viewModel.tabSelected
    
    return VStack(spacing: 4) {
      if isSelected {
        item.selectedImageAsset
      } else {
        item.imageAsset
      }
      
      Text(item.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundStyle(isSelected ? Colors.textPrimary.swiftUIColor : Colors.iconHover.swiftUIColor)
    }
    .onTapGesture {
      viewModel.onSelectedTab(tab: item)
    }
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(.white.opacity(0.05))
      .frame(maxWidth: .infinity)
  }
  
  var notificationsPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.NotificationRequest.Popup.title,
      subtitle: L10N.Common.NotificationRequest.Popup.subtitle,
      primaryButtonTitle: L10N.Common.Common.Yes.Button.title,
      secondaryButtonTitle: L10N.Common.Common.NotNow.Button.title,
      primaryAction: viewModel.notificationsPopupAction,
      secondaryAction: {
        viewModel.clearPopup()
        viewModel.presentNextPopupInQueue(removing: .notifications)
      }
    )
  }
  
  var applePayPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.ApplePay.Popup.title,
      subtitle: L10N.Common.ApplePay.Popup.subtitle,
      primaryButtonTitle: L10N.Common.ApplePay.Popup.action,
      secondaryButtonTitle: L10N.Common.ApplePay.Popup.dismiss,
      imageView: {
        GenImages.Images.icoApplePay.swiftUIImage
          .resizable()
          .frame(width: 100, height: 64, alignment: .center)
      },
      primaryAction: {
        viewModel.onApplePayButtonTap()
      },
      secondaryAction: {
        viewModel.clearPopup()
        viewModel.presentNextPopupInQueue(removing: .applePay)
      }
    )
  }
  
  var specialExperiencePopup: some View {
    CommonBottomSheet(
      title: "10 FRNT Tokens Added\nto Your Account",
      subtitle: "You’ve just received 10 Frontier Stable Tokens (FRNT) as part of the Wyoming event experience.",
      primaryButtonTitle: "Go to My Account",
      secondaryButtonTitle: "Got it",
      primaryAction: {
        viewModel.onSpecialExperiencePopupDismiss()
        viewModel.goToAssets()
      },
      secondaryAction: {
        viewModel.onSpecialExperiencePopupDismiss()
      }
    )
  }
}
