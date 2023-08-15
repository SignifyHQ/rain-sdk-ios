import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import NetspendSdk

struct AddFundsView: View {
  @StateObject private var viewModel: AddFundsViewModel
  @Binding private var isDisableView: Bool
  @Binding private var achInformation: ACHModel

  init(achInformation: Binding<ACHModel>, isDisableView: Binding<Bool>) {
    _achInformation = achInformation
    _isDisableView = isDisableView
    _viewModel = StateObject(wrappedValue: AddFundsViewModel())
  }
  
  var body: some View {
    ZStack {
      content
        .onChange(of: viewModel.isDisableView) { _ in
          isDisableView = viewModel.isDisableView
        }
        .navigationLink(item: $viewModel.navigation) { item in
          switch item {
          case .bankTransfers:
            BankTransfersView(achInformation: $achInformation)
          case .addBankDebit:
            AddBankWithDebitView()
          case .addMoney:
            MoveMoneyAccountView(kind: .receive)
          case .directDeposit:
            DirectDepositView(achInformation: $achInformation)
          }
        }
        .popup(item: $viewModel.toastMessage, style: .toast) {
          ToastView(toastMessage: $0)
        }
        .popup(item: $viewModel.popup) { item in
          switch item {
          case .plaidLinkingError:
            plaidLinkingErrorPopup
          }
        }
      externalLinkBank(controller: viewModel.netspendController)
    }
  }
}

// MARK: - View Components
private extension AddFundsView {
  @ViewBuilder func externalLinkBank(controller: NetspendSdkViewController?) -> some View {
    if let controller {
      ExternalLinkBankViewController(
        controller: controller,
        onSuccess: viewModel.onLinkExternalBankSuccess,
        onFailure: viewModel.onLinkExternalBankFailure,
        onCancelled: viewModel.onPlaidUIDisappear
      )
    }
  }
  
  var content: some View {
    VStack(spacing: 8) {
      ArrowButton(
        image: GenImages.CommonImages.Accounts.directDeposit,
        title: LFLocalizable.AccountView.DirectDeposit.title,
        value: LFLocalizable.AccountView.DirectDeposit.subtitle
      ) {
        viewModel.selectedAddOption(navigation: .directDeposit)
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.bankTransfers,
        title: LFLocalizable.AccountView.BankTransfers.title,
        value: LFLocalizable.AccountView.BankTransfers.subtitle
      ) {
        viewModel.selectedAddOption(navigation: .bankTransfers)
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.debitDeposit,
        title: LFLocalizable.AccountView.DebitDeposits.title,
        value: LFLocalizable.AccountView.DebitDeposits.subtitle
      ) {
        viewModel.selectedAddOption(navigation: .addBankDebit)
      }
      ArrowButton(
        image: GenImages.CommonImages.Accounts.oneTime,
        title: LFLocalizable.AccountView.OneTimeTransfers.title,
        value: LFLocalizable.AccountView.OneTimeTransfers.subtitle,
        isLoading: $viewModel.isOpeningPlaidView
      ) {
        viewModel.linkExternalBank()
      }
    }
  }
  
  var plaidLinkingErrorPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.PlaidLink.Popup.title,
      message: LFLocalizable.PlaidLink.Popup.description,
      primary: .init(
        text: LFLocalizable.PlaidLink.ConnectViaDebitCard.title,
        action: {
          viewModel.plaidLinkingErrorPrimaryAction()
        }
      ),
      secondary: .init(
        text: LFLocalizable.PlaidLink.ContactSupport.title,
        action: {
          viewModel.plaidLinkingErrorSecondaryAction()
        }
      )
    )
  }
}
