import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFServices
import NetspendSdk
import LFBank
import BaseDashboard
import LFAccountOnboarding
import AccountData
import AccountDomain
import LFTransaction
import Factory

struct AccountsView: View {
  @Injected(\.analyticsService) var analyticsService
  
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
          .navigationTitle(LFLocalizable.AccountView.atmLocationTitle)
          .foregroundColor(Colors.label.swiftUIColor)
        case .depositLimits:
          TransferLimitsView()
        case .connectedAccounts:
          ConnectedAccountsView(linkedAccount: viewModel.linkedAccount)
        case .bankStatement:
          BankStatementView()
        case let .disputeTransaction(netspendAccountID, passcode):
          NetspendDisputeTransactionViewController(netspendAccountID: netspendAccountID, passcode: passcode) {
            viewModel.navigation = nil
          }
          .navigationBarHidden(true)
        case .taxes:
          TaxesView()
        case .rewards:
          CurrentRewardView()
        case .wallet(asset: let asset):
          ReceiveCryptoView(assetModel: asset)
        case .agreement(let data):
          AgreementView(
            viewModel: AgreementViewModel(fundingAgreement: data),
            onNext: {
              //self.viewModel.addFundsViewModel.fundingAgreementData.send(nil)
            }, onDisappear: { isAcceptAgreement in
              self.viewModel.handleFundingAcceptAgreement(isAccept: isAcceptAgreement)
            }, shouldFetchCurrentState: false)
        }
      }
      .sheet(item: $viewModel.sheet, content: { sheet in
        switch sheet {
        case .legal:
          if let url = URL(string: LFUtility.termsURL) {
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
        section(title: LFLocalizable.AccountView.connectNewAccounts) {
          AddFundsView(
            viewModel: viewModel.addFundsViewModel,
            achInformation: $viewModel.achInformation,
            isDisableView: $viewModel.isDisableView
          )
        }
        section(title: LFLocalizable.AccountView.limits) {
          depositLimits
        }
        section(title: LFLocalizable.AccountView.cardAccountDetails) {
          accountDetailView
        }
        if viewModel.assets.isNotEmpty {
          section(title: LFLocalizable.AccountView.wallets) {
            ForEach(viewModel.assets, id: \.externalAccountId) { asset in
              assetCell(asset: asset)
            }
          }
        }
        section(title: LFLocalizable.AccountView.shortcuts) {
          shortcutSection
        }
        bottomDisclosure
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 12)
      .padding(.horizontal, 30.0)
    }
  }
  
  var bottomDisclosure: some View {
    Text(LFLocalizable.AccountView.Disclosure.message)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
  }
  
  var accountDetailView: some View {
    VStack(spacing: 10) {
      accountDetailCell(
        image: GenImages.CommonImages.icRoutingNumber.swiftUIImage,
        title: LFLocalizable.AccountView.RoutingNumber.title,
        value: viewModel.achInformation.routingNumber
      ) {
        UIPasteboard.general.string = viewModel.achInformation.routingNumber
        viewModel.toastMessage = LFLocalizable.Toast.Copy.message
      }
      accountDetailCell(
        image: GenImages.CommonImages.icAccountNumber.swiftUIImage,
        title: LFLocalizable.AccountView.AccountNumber.title,
        value: viewModel.achInformation.accountNumber
      ) {
        analyticsService.track(event: AnalyticsEvent(name: .viewsAccountAndRouting))
        UIPasteboard.general.string = viewModel.achInformation.accountNumber
        viewModel.toastMessage = LFLocalizable.Toast.Copy.message
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
        section(title: LFLocalizable.AccountView.connectedAccounts) {
          ArrowButton(
            image: GenImages.CommonImages.Accounts.connectedAccounts.swiftUIImage,
            title: LFLocalizable.AccountView.connectedAccounts,
            value: nil
          ) {
            viewModel.connectedAccountsTapped()
          }
        }
      }
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
  
  var shortcutSection: some View {
    VStack {
      ArrowButton(
        image: GenImages.CommonImages.icRewards.swiftUIImage,
        title: LFLocalizable.AccountView.rewards,
        value: nil
      ) {
        viewModel.openReward()
      }
      /* TODO: Remove for MVP
      ArrowButton(
        image: GenImages.CommonImages.Accounts.atm.swiftUIImage,
        title: LFLocalizable.AccountView.atm,
        value: nil,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.getATMAuthorizationCode()
      }
       */
      ArrowButton(
        image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
        title: LFLocalizable.AccountView.bankStatements,
        value: nil
      ) {
        viewModel.bankStatementTapped()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.tax.swiftUIImage,
        title: LFLocalizable.AccountView.taxes,
        value: nil
      ) {
        viewModel.openTaxes()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.help.swiftUIImage,
        title: LFLocalizable.AccountView.helpSupport,
        value: nil
      ) {
        viewModel.openIntercomService()
      }
      if !viewModel.notificationsEnabled {
        ArrowButton(
          image: GenImages.CommonImages.Accounts.notifications.swiftUIImage,
          title: LFLocalizable.AccountView.notifications,
          value: nil
        ) {
          viewModel.notificationTapped()
        }
      }
      /* TODO: Remove for MVP
      ArrowButton(
        image: GenImages.CommonImages.Accounts.legal.swiftUIImage,
        title: LFLocalizable.AccountView.legal,
        value: nil
      ) {
        viewModel.openLegal()
      }
       */
      if viewModel.showAdminMenu {
        ArrowButton(
          image: GenImages.CommonImages.personAndBackgroundDotted.swiftUIImage,
          title: "ADMIN MENU",
          value: nil
        ) {
          viewModel.navigation = .debugMenu
        }
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.icDispute.swiftUIImage,
        title: LFLocalizable.Button.DisputeTransaction.title,
        value: nil,
        isLoading: $viewModel.isLoadingDisputeTransaction
      ) {
        viewModel.getDisputeAuthorizationCode()
      }
    }
    .onChange(of: scenePhase, perform: { newValue in
      if newValue == .active {
        viewModel.checkNotificationsStatus()
      }
    })
  }
  
  var depositLimits: some View {
    ArrowButton(
      image: GenImages.CommonImages.Accounts.limits.swiftUIImage,
      title: LFLocalizable.AccountView.depositLimits,
      value: nil
    ) {
      viewModel.onClickedDepositLimitsButton()
    }
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
          Text(LFLocalizable.AccountView.Wallet.title(assetType.title))
            .foregroundColor(Colors.label.swiftUIColor)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
          Spacer()
          HStack(spacing: 0) {
            Text("****\(viewModel.getSubWalletAddress(asset: asset))")
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
