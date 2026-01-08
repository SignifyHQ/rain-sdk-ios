import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import Services
import NetspendSdk
import RainOnboarding
import AccountData
import AccountDomain
import Factory
import GeneralFeature
import RainFeature

struct MyAccountView: View {
  @Environment(\.scenePhase) var scenePhase
  
  @StateObject private var viewModel: MyAccountViewModel
  @State private var sheetHeight: CGFloat = 380
  
  init(viewModel: MyAccountViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .profile:
          MyProfileView()
        case .backup:
          WalletBackupView()
        case .savedWalletAddresses:
          SavedWalletAddressListView()
        }
      }
      .withLoadingIndicator(
        isShowing: $viewModel.isLoading,
        isOpaque: false
      )
      .sheet(
        isPresented: $viewModel.isFidesmoFlowPresented
      ) {
        BottomSheetView(
          isPresented: $viewModel.isFidesmoFlowPresented,
          sheetHeight: $sheetHeight
        )
        .onAppear(
          perform: {
            sheetHeight = 380
          }
        )
        .presentationDetents([.height(sheetHeight)])
        .interactiveDismissDisabled(true)
      }
      .sheetWithContentHeight(
        isPresented: $viewModel.isShowingLogoutPopup,
        content: {
          logoutPopup
        }
      )
      .sheetWithContentHeight(
        isPresented: $viewModel.isShowingDeleteAccountPopup,
        content: {
          deleteAccountPopup
        }
      )
      .sheetWithContentHeight(item: $viewModel.popup, content: { popup in
        switch popup {
        case .openSettings:
          openSettingsPopup
        }
      })
      .toast(data: $viewModel.toastData)
      .background(Colors.baseAppBackground2.swiftUIColor)
      .onChange(
        of: scenePhase,
        perform: { newValue in
          if newValue == .active {
            viewModel.checkNotificationsStatus()
          }
        }
      )
  }
}

// MARK: - View Components
private extension MyAccountView {
  @ViewBuilder
  var content: some View {
    VStack(alignment: .leading, spacing: 0) {
      ForEach(MyAccountViewModel.MyAccountItem.allCases, id: \.id) { item in
        switch item.type {
        case .actionCell:
          MyAccountCell(item: item) {
            viewModel.onCellTap(item: item)
          }
          
        case .switchCell:
          switch item {
          case .enableNotifications:
            MyAccountSwitchCell(item: item, isOn: $viewModel.notificationsEnabled)
            
          default:
            EmptyView()
          }
        }
      }
      
      Spacer()
      
      bottomView
    }
    .padding(.bottom, 16)
    .padding(.horizontal, 24)
  }
  
  var bottomView: some View {
    VStack(spacing: 12) {
      FullWidthButton(
        type: .primary,
        title: L10N.Common.MyAccount.Logout.Button.title
      ) {
        viewModel.isShowingLogoutPopup = true
      }
      
      FullWidthButton(
        type: .secondary,
        tintColor: Colors.red400.swiftUIColor,
        backgroundColor: Colors.buttonSurfaceSecondary.swiftUIColor,
        borderColor: Colors.greyDefault.swiftUIColor,
        title: L10N.Common.MyAccount.DeleteAccount.Button.title
      ) {
        viewModel.isShowingDeleteAccountPopup = true
      }
      
      Text(L10N.Common.MyAccount.Version.title(LFUtilities.marketingVersion))
        .foregroundColor(Colors.textSecondary.swiftUIColor)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
    .padding(.bottom, 16)
  }
  
  var logoutPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.LogoutPopup.Confirmation.title,
      subtitle: L10N.Common.LogoutPopup.Confirmation.subtitle,
      primaryButtonTitle: L10N.Common.LogoutPopup.Confirmation.Button.title,
      secondaryButtonTitle: L10N.Common.Common.Cancel.Button.title
    ) {
      viewModel.logout()
    }
  }
  
  var deleteAccountPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.DeleteAccountPopup.Confirmation.title,
      subtitle: L10N.Common.DeleteAccountPopup.Confirmation.subtitle,
      primaryButtonTitle: L10N.Common.DeleteAccountPopup.Confirmation.Button.title,
      secondaryButtonTitle: L10N.Common.Common.Cancel.Button.title
    ) {
      viewModel.deleteAccount()
    }
  }
  
  var openSettingsPopup: some View {
    CommonBottomSheet(
      title: L10N.Common.NotificationSetting.Popup.title,
      subtitle: L10N.Common.NotificationSetting.Popup.subtitle,
      primaryButtonTitle: L10N.Common.Common.Open.Button.title,
      secondaryButtonTitle: L10N.Common.Common.Close.Button.title
    ) {
      viewModel.popup = nil
      viewModel.isWaitingEnableNotification = true
      viewModel.openSettings()
    }
  }
}
