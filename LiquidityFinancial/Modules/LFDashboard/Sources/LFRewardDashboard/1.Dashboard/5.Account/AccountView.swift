import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFServices
import LFBank

struct AccountsView: View {
  @StateObject private var viewModel = AccountViewModel()
  
  var body: some View {
    content
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
        case .connectedAccounts:
          ConnectedAccountsView(linkedAccount: viewModel.linkedAccount)
        case .bankStatement:
          BankStatementView()
        case let .disputeTransaction(netspendAccountID, passcode):
          NetspendDisputeTransactionViewController(netspendAccountID: netspendAccountID, passcode: passcode) {
            viewModel.navigation = nil
          }
          .navigationBarHidden(true)
        }
      }
      .sheet(isPresented: $viewModel.openLegal) {
        if let url = URL(string: LFUtility.termsURL) {
          WebView(url: url)
            .ignoresSafeArea()
        }

      }
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .background(Colors.background.swiftUIColor)
      .onAppear {
        viewModel.onAppear()
      }
  }
}

// MARK: - View Components
private extension AccountsView {
  var content: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        connectedAccountsSection
        section(title: LFLocalizable.AccountView.connectNewAccounts) {
          AddFundsView(
            achInformation: $viewModel.achInformation,
            isDisableView: $viewModel.isDisableView
          )
        }
        section(title: LFLocalizable.AccountView.limits) {
          depositLimits
        }
        section(title: LFLocalizable.AccountView.cardAccountDetails(LFUtility.appName)) {
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
        value: viewModel.achInformation.accountNumber
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
            .foregroundColor(Colors.primary.swiftUIColor)
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
        image: GenImages.CommonImages.Accounts.atm.swiftUIImage,
        title: LFLocalizable.AccountView.atm,
        value: nil,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.getATMAuthorizationCode()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
        title: LFLocalizable.AccountView.bankStatements,
        value: nil
      ) {
        viewModel.bankStatementTapped()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.help.swiftUIImage,
        title: LFLocalizable.AccountView.helpSupport,
        value: nil
      ) {
        viewModel.openIntercomService()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.legal.swiftUIImage,
        title: LFLocalizable.AccountView.legal,
        value: nil
      ) {
        viewModel.openLegal.toggle()
      }
      ArrowButton(
        image: GenImages.CommonImages.personAndBackgroundDotted.swiftUIImage,
        title: "ADMIN MENU",
        value: nil
      ) {
        viewModel.navigation = .debugMenu
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
  }

  var depositLimits: some View {
    ArrowButton(
      image: GenImages.CommonImages.Accounts.limits.swiftUIImage,
      title: LFLocalizable.AccountView.depositLimits,
      value: nil
    ) {
      // TODO: Will do later
    }
  }
}
