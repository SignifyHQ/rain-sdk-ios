import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable
import LFServices

struct AccountsView: View {
  @StateObject private var viewModel = AccountViewModel()
  
  var body: some View {
    content
      .background(Colors.background.swiftUIColor)
  }
}

extension AccountsView {
  private var content: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        connectedAccountsSection
        section(title: LFLocalizable.AccountView.connectNewAccounts) {
          addFunds
        }
        section(title: LFLocalizable.AccountView.limits) {
          depositLimits
        }
        section(title: LFLocalizable.AccountView.cardAccountDetails(LFUtility.appName)) {
         // TODO: Will implementation later
        }
        section(title: LFLocalizable.AccountView.shortcuts) {
          shortcutSection
        }
        Spacer()
      }
      .padding(.top, 20)
      .padding(.bottom, 12)
      .padding(.horizontal, 30.0)
      .navigationLink(item: $viewModel.navigation, destination: { navigation in
        switch navigation {
        case .debugMenu:
          DBAdminMenuView(environment: viewModel.networkEnvironment.title)
        case .atmLocation(let authorizationCode):
          NetspendLocationViewController(withPasscode: authorizationCode, onClose: {
            viewModel.navigation = nil
          })
          .navigationTitle(LFLocalizable.AccountView.atmLocationTitle)
        }
      })
    }
  }

  private var connectedAccountsSection: some View {
    Group {
      // TODO: Will implementation later, display when have account
      if true {
        section(title: LFLocalizable.AccountView.connectedAccounts) {
          ArrowButton(
            image: GenImages.CommonImages.Accounts.connectedAccounts,
            title: LFLocalizable.AccountView.connectedAccounts,
            value: nil
          ) {
            // TODO: Will do later
          }
        }
      }
    }
  }

  private func section<V: View>(title: String, @ViewBuilder content: () -> V) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      content()
    }
  }

  private var addFunds: some View {
    Group {
      ArrowButton(
        image: GenImages.CommonImages.Accounts.directDeposit,
        title: LFLocalizable.AccountView.DirectDeposit.title,
        value: LFLocalizable.AccountView.DirectDeposit.subtitle
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.bankTransfers,
        title: LFLocalizable.AccountView.BankTransfers.title,
        value: LFLocalizable.AccountView.BankTransfers.subtitle
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.debitDeposit,
        title: LFLocalizable.AccountView.DebitDeposits.title,
        value: LFLocalizable.AccountView.DebitDeposits.subtitle
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.oneTime,
        title: LFLocalizable.AccountView.OneTimeTransfers.title,
        value: LFLocalizable.AccountView.OneTimeTransfers.subtitle
      ) {
        // TODO: Will do later
      }
    }
  }

  private var shortcutSection: some View {
    VStack {
      ArrowButton(
        image: GenImages.CommonImages.icRewards,
        title: LFLocalizable.AccountView.rewards,
        value: nil
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.atm,
        title: LFLocalizable.AccountView.atm,
        value: nil,
        isLoading: $viewModel.isLoading
      ) {
        viewModel.getATMAuthorizationCode()
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.bankStatements,
        title: LFLocalizable.AccountView.bankStatements,
        value: nil
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.tax,
        title: LFLocalizable.AccountView.taxes,
        value: nil
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.help,
        title: LFLocalizable.AccountView.helpSupport,
        value: nil
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.legal,
        title: LFLocalizable.AccountView.legal,
        value: nil
      ) {
        // TODO: Will do later
      }
      ArrowButton(
        image: GenImages.CommonImages.personAndBackgroundDotted,
        title: "ADMIN MENU",
        value: nil
      ) {
        viewModel.navigation = .debugMenu
      }
    }
  }

  private var depositLimits: some View {
    ArrowButton(
      image: GenImages.CommonImages.Accounts.limits,
      title: LFLocalizable.AccountView.depositLimits,
      value: nil
    ) {
      // TODO: Will do later
    }
  }
}
