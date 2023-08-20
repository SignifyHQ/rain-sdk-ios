import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFServices
import NetspendSdk
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
        }
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
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 12)
      .padding(.horizontal, 30.0)
    }
  }
  
  var accountDetailView: some View {
    VStack(spacing: 10) {
      accountDetailCell(
        image: GenImages.CommonImages.icRoutingNumber.swiftUIImage,
        title: LFLocalizable.AccountView.RoutingNumber.title,
        value: viewModel.achInformation.routingNumber
      )
      accountDetailCell(
        image: GenImages.CommonImages.icAccountNumber.swiftUIImage,
        title: LFLocalizable.AccountView.AccountNumber.title,
        value: viewModel.achInformation.accountNumber
      )
    }
    .foregroundColor(Colors.label.swiftUIColor)
  }
  
  func accountDetailCell(image: Image, title: String, value: String) -> some View {
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
        // TODO: Will do later
      }
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
        image: GenImages.CommonImages.Accounts.tax.swiftUIImage,
        title: LFLocalizable.AccountView.taxes,
        value: nil
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.help.swiftUIImage,
        title: LFLocalizable.AccountView.helpSupport,
        value: nil
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.legal.swiftUIImage,
        title: LFLocalizable.AccountView.legal,
        value: nil
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.personAndBackgroundDotted.swiftUIImage,
        title: "ADMIN MENU",
        value: nil
      ) {
        viewModel.navigation = .debugMenu
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
