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

struct AccountsView: View {
  @Injected(\.analyticsService) var analyticsService
  @Injected(\.bankServiceConfig) var bankServiceConfig
  @Injected(\.dashboardNavigation) var dashboardNavigation
  
  @Environment(\.scenePhase) var scenePhase
  
  @StateObject private var viewModel: AccountViewModel
  
  init(viewModel: AccountViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .disabled(viewModel.isDisableView)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .debugMenu:
          DBAdminMenuView(environment: viewModel.networkEnvironment.title)
        case .atmLocation(let authorizationCode):
          NetspendLocationViewController(withPasscode: authorizationCode, onClose: {
            viewModel.navigation = nil
          })
          .navigationTitle(L10N.Common.AccountView.atmLocationTitle)
          .foregroundColor(Colors.label.swiftUIColor)
        case .depositLimits:
          AccountLimitsView()
        case .connectedAccounts:
          ConnectedAccountsView(linkedAccount: viewModel.linkedAccount)
        case .bankStatement:
          BankStatementView()
        case let .disputeTransaction(netspendAccountID, passcode):
          dashboardNavigation.resolveDisputeTransactionView(
            id: netspendAccountID,
            passcode: passcode
          ) {
            viewModel.navigation = nil
          }?
            .navigationBarHidden(true)
        case .taxes:
          TaxesView()
        case .rewards:
          CurrentRewardView()
        case .wallet(asset: let asset):
          ReceiveCryptoView(
            assetTitle: asset.type?.title ?? .empty,
            walletAddress: asset.externalAccountId ?? .empty
          )
        case .backup:
          BackupWalletView()
        }
      }
      .sheet(item: $viewModel.sheet, content: { sheet in
        switch sheet {
        case .legal:
          if let url = URL(string: LFUtilities.termsURL) {
            WebView(url: url)
              .ignoresSafeArea()
          }
        }
      })
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .background(Colors.background.swiftUIColor)
  }
}

// MARK: - View Components
private extension AccountsView {
  @ViewBuilder
  var content: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        
        connectedAccountsSection
        
//        section(title: L10N.Common.AccountView.connectNewAccounts) {
//          AddFundsView(
//            viewModel: viewModel.addFundsViewModel,
//            achInformation: $viewModel.achInformation,
//            isDisableView: $viewModel.isDisableView
//          )
//        }
        
//        section(title: L10N.Common.AccountView.cardAccountDetails) {
//          accountDetailView
//        }
//        
//        if viewModel.assets.isNotEmpty {
//          section(title: L10N.Common.AccountView.wallets) {
//            ForEach(viewModel.assets, id: \.externalAccountId) { asset in
//              assetCell(asset: asset)
//            }
//          }
//        }
        
        walletBackupSection
        
//        section(title: L10N.Common.AccountView.shortcuts) {
//          shortcutSection
//        }
        
        //bottomDisclosure
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 12)
      .padding(.horizontal, 30.0)
    }
  }
  
//  var bottomDisclosure: some View {
//    Text(L10N.Custom.AccountView.Disclosure.message)
//      .font(Fonts.regular.swiftUIFont(size: 10))
//      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
//  }
  
  var accountDetailView: some View {
    VStack(spacing: 10) {
      accountDetailCell(
        image: GenImages.CommonImages.icRoutingNumber.swiftUIImage,
        title: L10N.Common.AccountView.RoutingNumber.title,
        value: viewModel.achInformation.routingNumber
      ) {
        UIPasteboard.general.string = viewModel.achInformation.routingNumber
        viewModel.toastMessage = L10N.Common.Toast.Copy.message
      }
      accountDetailCell(
        image: GenImages.CommonImages.icAccountNumber.swiftUIImage,
        title: L10N.Common.AccountView.AccountNumber.title,
        value: L10N.Common.AccountView.HiddenValue.title(
          viewModel.getLastFourDigits(from: viewModel.achInformation.accountNumber)
        )
      ) {
        analyticsService.track(event: AnalyticsEvent(name: .viewsAccountAndRouting))
        UIPasteboard.general.string = viewModel.achInformation.accountNumber
        viewModel.toastMessage = L10N.Common.Toast.Copy.message
      }
    }
    .foregroundColor(Colors.label.swiftUIColor)
  }
  
  func accountDetailCell(image: Image, title: String, value: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      HStack(spacing: 12) {
        image
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: 13))
        Spacer()
        if viewModel.isLoadingACH {
          LottieView(loading: .primary)
            .frame(width: 28, height: 16)
            .padding(.leading, 4)
        } else {
          Text(value)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(textColor)
        }
      }
    }
    .padding(.leading, 16)
    .padding(.trailing, 12)
    .frame(height: 56)
    .background(Colors.secondaryBackground.swiftUIColor)
    .cornerRadius(10)
  }
  
  var connectedAccountsSection: some View {
    Group {
      if !viewModel.linkedAccount.isEmpty {
        section(title: L10N.Common.AccountView.connectedAccounts) {
          connectedAccountButton
        }
      }
    }
  }
  
  var connectedAccountButton: some View {
    Button {
      viewModel.connectedAccountsTapped()
    } label: {
      HStack(spacing: 4) {
        GenImages.CommonImages.Accounts.connectedAccounts.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        Text(L10N.Common.AccountView.connectedAccounts)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.leading, 8)
        Spacer()
        Circle()
          .fill(Colors.buttons.swiftUIColor)
          .frame(32.0)
          .overlay {
            Text("\(viewModel.linkedAccount.count)")
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          }
        CircleButton(style: .right)
      }
      .padding(.leading, 16)
      .padding(.trailing, 12)
      .frame(height: 56)
      .background(Colors.secondaryBackground.swiftUIColor)
      .cornerRadius(10)
    }
  }
  
  func section<V: View>(title: String, @ViewBuilder content: () -> V) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      content()
    }
  }
  
  var walletBackupSection: some View {
    section(title: L10N.Common.AccountView.WalletBackup.section) {
      ArrowButton(
        image: GenImages.CommonImages.Accounts.legal.swiftUIImage,
        title: L10N.Common.AccountView.WalletBackup.title,
        value: nil
      ) {
        viewModel.backupSectionTapped()
      }
    }
  }
  
  var shortcutSection: some View {
    VStack {
//      ArrowButton(
//        image: GenImages.CommonImages.Accounts.limits.swiftUIImage,
//        title: L10N.Common.AccountView.depositLimits,
//        value: nil
//      ) {
//        viewModel.onClickedDepositLimitsButton()
//      }
      ArrowButton(
        image: GenImages.CommonImages.icRewards.swiftUIImage,
        title: L10N.Common.AccountView.rewards,
        value: nil
      ) {
        viewModel.openReward()
      }
//       ArrowButton(
//       image: GenImages.CommonImages.Accounts.atm.swiftUIImage,
//       title: L10N.Common.AccountView.atm,
//       value: nil,
//       isLoading: $viewModel.isLoading
//       ) {
//       viewModel.getATMAuthorizationCode()
//       }
//      ArrowButton(
//        image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
//        title: L10N.Common.AccountView.bankStatements,
//        value: nil
//      ) {
//        viewModel.bankStatementTapped()
//      }
//      ArrowButton(
//        image: GenImages.CommonImages.Accounts.tax.swiftUIImage,
//        title: L10N.Common.AccountView.taxes,
//        value: nil
//      ) {
//        viewModel.openTaxes()
//      }
      if !viewModel.notificationsEnabled {
        ArrowButton(
          image: GenImages.CommonImages.Accounts.notifications.swiftUIImage,
          title: L10N.Common.AccountView.notifications,
          value: nil
        ) {
          viewModel.notificationTapped()
        }
      }
//       ArrowButton(
//       image: GenImages.CommonImages.Accounts.legal.swiftUIImage,
//       title: L10N.Common.AccountView.legal,
//       value: nil
//       ) {
//       viewModel.openLegal()
//       }
      if viewModel.showAdminMenu {
        ArrowButton(
          image: GenImages.CommonImages.personAndBackgroundDotted.swiftUIImage,
          title: "ADMIN MENU",
          value: nil
        ) {
          viewModel.navigation = .debugMenu
        }
      }
//      if bankServiceConfig.supportDisputeTransaction {
//        ArrowButton(
//          image: GenImages.CommonImages.Accounts.icDispute.swiftUIImage,
//          title: L10N.Common.Button.DisputeTransaction.title,
//          value: nil,
//          isLoading: $viewModel.isLoadingDisputeTransaction
//        ) {
//          viewModel.getDisputeAuthorizationCode()
//        }
//      }
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkNotificationsStatus()
      }
    })
  }
}

// MARK: - View Components
private extension AccountsView {
  @ViewBuilder func assetCell(asset: AssetModel) -> some View {
    if let assetType = asset.type {
      Button {
        viewModel.openWalletAddress(asset: asset)
      } label: {
        HStack(spacing: 8) {
          assetType.image
          Text(L10N.Common.AccountView.Wallet.title(assetType.title))
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          Spacer()
          HStack(spacing: 0) {
            Text(
              L10N.Common.AccountView.HiddenValue.title(
                viewModel.getLastFourDigits(from: asset.externalAccountId ?? .empty)
              )
            )
            .foregroundColor(textColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(Colors.secondaryBackground.swiftUIColor.cornerRadius(9))
      }
    }
  }
}

// MARK: - View Helpers
private extension AccountsView {
  var textColor: Color {
    switch LFStyleGuide.target {
    case .Cardano:
      return Colors.whiteText.swiftUIColor
    default:
      return Colors.primary.swiftUIColor
    }
  }
}
