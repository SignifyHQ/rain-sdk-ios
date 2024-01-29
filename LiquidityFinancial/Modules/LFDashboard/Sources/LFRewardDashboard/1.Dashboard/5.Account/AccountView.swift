import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import Services
import Factory
import GeneralFeature
import SolidFeature

public struct AccountsView: View {
  @StateObject private var viewModel: AccountViewModel
  @Environment(\.scenePhase) var scenePhase
  @State var openSafariType: AccountViewModel.OpenSafariType?
  
  @Injected(\.transactionNavigation) var transactionNavigation
  @Injected(\.bankServiceConfig) var bankServiceConfig
  
  public init(viewModel: AccountViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    content
      .track(name: String(describing: type(of: self)))
      .disabled(viewModel.isDisableView)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case .debugMenu:
          DBAdminMenuView(environment: viewModel.networkEnvironment.title)
        case .depositLimits:
          AccountLimitsView()
        case .connectedAccounts:
          ConnectedAccountsView(linkedContacts: viewModel.linkedContacts)
        case .bankStatement:
          BankStatementView()
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
      .fullScreenCover(item: $openSafariType, content: { type in
        switch type {
        case .legal(let url):
          SFSafariViewWrapper(url: url)
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
        section(title: L10N.Common.AccountView.connectNewAccounts) {
          AddFundsView(
            viewModel: viewModel.addFundsViewModel,
            achInformation: $viewModel.achInformation,
            isDisableView: $viewModel.isDisableView
          )
        }
        section(title: L10N.Common.AccountView.cardAccountDetails) {
          accountDetailView
        }
        section(title: L10N.Common.AccountView.shortcuts) {
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
    Text(L10N.Custom.AccountView.Disclosure.message)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
  }
  
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
        value: viewModel.achInformation.accountNumber
      ) {
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
      if !viewModel.linkedContacts.isEmpty {
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
            Text("\(viewModel.linkedContacts.count)")
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
        title: L10N.Common.AccountView.depositLimits,
        value: nil
      ) {
        viewModel.onClickedDepositLimitsButton()
      }
      ArrowButton(
        image: GenImages.CommonImages.icRewards.swiftUIImage,
        title: L10N.Common.AccountView.rewards,
        value: nil
      ) {
        viewModel.openReward()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
        title: L10N.Common.AccountView.bankStatements,
        value: nil
      ) {
        viewModel.bankStatementTapped()
      }
      if !viewModel.notificationsEnabled {
        ArrowButton(
          image: GenImages.CommonImages.Accounts.notifications.swiftUIImage,
          title: L10N.Common.AccountView.notifications,
          value: nil
        ) {
          viewModel.notificationTapped()
        }
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.legal.swiftUIImage,
        title: L10N.Common.AccountView.legal,
        value: nil
      ) {
        guard let url = viewModel.getUrl() else { return }
        openSafariType = .legal(url)
      }
      if viewModel.showAdminMenu {
        ArrowButton(
          image: GenImages.CommonImages.personAndBackgroundDotted.swiftUIImage,
          title: "ADMIN MENU",
          value: nil
        ) {
          viewModel.navigation = .debugMenu
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
