import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide

public struct AddFundsView: View {
  
  @StateObject private var viewModel: AddFundsViewModel
  @Binding private var isDisableView: Bool
  @Binding private var achInformation: ACHModel
  
  private var options: [FundOption] = [.oneTime]

  public init(
    viewModel: AddFundsViewModel,
    achInformation: Binding<ACHModel>,
    isDisableView: Binding<Bool>,
    options: [FundOption] = [.oneTime]
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
          isLoading: option == .oneTime ? $viewModel.isLoadingLinkExternalBank : .constant(false)
        ) {
          viewModel.selectedAddOption(navigation: option.navigation)
        }
      }
    }
  }
  
  var plaidLinkingErrorPopup: some View {
    LiquidityAlert(
      title: L10N.Common.PlaidLink.Popup.title,
      message: L10N.Common.PlaidLink.Popup.description,
      primary: .init(
        text: L10N.Common.PlaidLink.ContactSupport.title,
        action: {
          viewModel.plaidLinkingErrorPrimaryAction()
        }
      )
    )
  }
}
