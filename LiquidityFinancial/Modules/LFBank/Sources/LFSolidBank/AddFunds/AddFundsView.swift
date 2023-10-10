import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import LFBaseBank

public struct AddFundsView: View {
  
  @StateObject private var viewModel: AddFundsViewModel
  @Binding private var isDisableView: Bool
  @Binding private var achInformation: ACHModel
  
  private var options: [FundOption] = [.directDeposit, .debitDeposit, .oneTime]

  public init(
    viewModel: AddFundsViewModel,
    achInformation: Binding<ACHModel>,
    isDisableView: Binding<Bool>,
    options: [FundOption] = [.directDeposit, .debitDeposit, .oneTime]
  ) {
    _achInformation = achInformation
    _isDisableView = isDisableView
    _viewModel = StateObject(wrappedValue: viewModel)
    self.options = options
  }
  
  public var body: some View {
    ZStack {
      content
        .onChange(of: viewModel.isDisableView) { _ in
          isDisableView = viewModel.isDisableView
        }
        .sheet(item: $viewModel.plaidConfig) { item in
          PlaidLinkView(configuration: item.config)
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
          case .linkExternalBank:
            EmptyView()
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
      
    }
  }
}

// MARK: - View Components
private extension AddFundsView {
  var content: some View {
    VStack(spacing: 8) {
      ForEach(options, id: \.self) { option in
        ArrowButton(
          image: option.image,
          title: option.title,
          value: option.subtitle,
          isLoading: option == .debitDeposit ?
          $viewModel.isLoadingLinkExternalCard :
            (option == .oneTime ?
             $viewModel.isLoadingLinkExternalBank : .constant(false)
            )
        ) {
          viewModel.selectedAddOption(navigation: option.navigation)
        }
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
