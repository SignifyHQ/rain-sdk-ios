import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFServices
import LFSolidBank
import LFTransaction
import Factory

struct AccountsView: View {
  @StateObject private var viewModel: AccountViewModel
  @Environment(\.scenePhase) var scenePhase
  
  @Injected(\.transactionNavigation) var transactionNavigation
  @Injected(\.dashboardNavigation) var dashboardNavigation
  @Injected(\.bankConfig) var bankConfig
  
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
          NetspendLocationViewController(
            withPasscode: authorizationCode,
            onClose: {
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
          dashboardNavigation.resolveDisputeTransactionView(
            id: netspendAccountID,
            passcode: passcode
          ) {
            viewModel.navigation = nil
          }?
            .navigationBarHidden(true)
        case .rewards:
          transactionNavigation.resolveCurrentReward()
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
      .onChange(of: scenePhase, perform: { newValue in
        if newValue == .active {
          viewModel.checkNotificationsStatus()
        }
      })
  }
}

// MARK: - View Components
private extension AccountsView {
  var content: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        connectedAccountsSection
        section(title: LFLocalizable.AccountView.connectNewAccounts) {
          //TODO: Luan Tran
          EmptyView()
        }
        section(title: LFLocalizable.AccountView.cardAccountDetails) {
          accountDetailView
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
        value: LFLocalizable.AccountView.HiddenValue.title(
          viewModel.getLastFourDigits(from: viewModel.achInformation.accountNumber)
        )
      ) {
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
            .foregroundStyle(
              LinearGradient(
                colors: gradientColor,
                startPoint: .leading,
                endPoint: .trailing
              )
            )
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
        Text(LFLocalizable.AccountView.connectedAccounts)
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
  
  var shortcutSection: some View {
    VStack {
      ArrowButton(
        image: GenImages.CommonImages.Accounts.limits.swiftUIImage,
        title: LFLocalizable.AccountView.depositLimits,
        value: nil
      ) {
        viewModel.onClickedDepositLimitsButton()
      }
      ArrowButton(
        image: GenImages.CommonImages.icRewards.swiftUIImage,
        title: LFLocalizable.AccountView.rewards,
        value: nil
      ) {
        viewModel.openReward()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
        title: LFLocalizable.AccountView.bankStatements,
        value: nil
      ) {
        viewModel.bankStatementTapped()
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
       viewModel.openLegal.toggle()
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
      if bankConfig.supportDisputeTransaction {
        ArrowButton(
          image: GenImages.CommonImages.Accounts.icDispute.swiftUIImage,
          title: LFLocalizable.Button.DisputeTransaction.title,
          value: nil,
          isLoading: $viewModel.isLoadingDisputeTransaction
        ) {
          viewModel.getDisputeAuthorizationCode()
        }
      }
    }
  }
}

// MARK: - View Helpers
private extension AccountsView {
  var gradientColor: [Color] {
    switch LFStyleGuide.target {
    case .CauseCard:
      return [
        Colors.Gradients.Button.gradientButton0.swiftUIColor,
        Colors.Gradients.Button.gradientButton1.swiftUIColor
      ]
    default:
      return [Colors.primary.swiftUIColor]
    }
  }
}
