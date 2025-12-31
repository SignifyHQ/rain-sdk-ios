import SwiftUI
import LFLocalizable
import LFStyleGuide
import LFUtilities
import Services
import GeneralFeature

struct WithdrawalConfirmationView: View {
  @StateObject private var viewModel: WithdrawalConfirmationViewModel
  private let completeAction: (() -> Void)?
  
  init(
    viewModel: WithdrawalConfirmationViewModel,
    completeAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(wrappedValue: viewModel)
    self.completeAction = completeAction
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 40) {
      headerView
      informationView
      Spacer()
      footerView
    }
    .padding(.horizontal, 24)
    .padding(.top, 4)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .appNavBar(navigationTitle: L10N.Common.WithdrawalConfirmation.Screen.title)
    .navigationBarTitleDisplayMode(.inline)
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case let .transactionDetail(transaction):
        TransactionDetailsView(
          method: .localTransaction(transaction),
          kind: .crypto,
          isNewAddress: viewModel.isNewAddress,
          walletAddress: viewModel.address,
          transactionInfo: viewModel.cryptoTransactions,
          popAction: {
            completeAction?()
          }
        )
      }
    }
    .toast(data: $viewModel.toastData)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension WithdrawalConfirmationView {
  var headerView: some View {
    Text(L10N.Common.WithdrawalConfirmation.Header.title)
      .foregroundColor(Colors.textPrimary.swiftUIColor)
      .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
      .multilineTextAlignment(.leading)
  }
  
  var informationView: some View {
    VStack(spacing: 16) {
      informationCell(
        title: L10N.Common.WithdrawalConfirmation.Info.amount,
        value: viewModel.amountInput,
        additionalValue: viewModel.assetModel.type?.symbol ?? .empty,
        icon: viewModel.assetModel.type?.icon
      )
      
      informationCell(
        title: L10N.Common.WithdrawalConfirmation.Info.nickname,
        value: viewModel.nickname
      )
      
      informationCell(
        title: L10N.Common.WithdrawalConfirmation.Info.address,
        value: viewModel.address
      )
      
      informationCell(
        title: L10N.Common.WithdrawalConfirmation.Info.fee,
        value: viewModel.fee.formattedAmount(minFractionDigits: 2, maxFractionDigits: 18),
        additionalValue: L10N.Common.WithdrawalConfirmation.Info.free,
        isFeeLine: true,
        isLastItem: true
      )
    }
  }
  
  @ViewBuilder func informationCell(
    title: String,
    value: String,
    additionalValue: String? = nil,
    icon: Image? = nil,
    isFeeLine: Bool = false,
    isLastItem: Bool = false
  ) -> some View {
    if !value.isEmpty {
      VStack(alignment: .leading, spacing: 16) {
        HStack(alignment: icon != nil ? .center : .top, spacing: 8) {
          Text(title)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.textSecondary.swiftUIColor)
          
          Spacer()
          
          Text(value)
            .font(Fonts.semiBold.swiftUIFont(size: Constants.FontSize.medium.value))
            .foregroundColor(Colors.textPrimary.swiftUIColor)
            .strikethrough(isFeeLine, color: Colors.textPrimary.swiftUIColor)
            .multilineTextAlignment(.trailing)
          
          if let additionalValue {
            Text(additionalValue)
              .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(isFeeLine ? Colors.successDefault.swiftUIColor : Colors.textPrimary.swiftUIColor)
          }
          
          if let icon {
            icon
              .resizable()
              .frame(width: 24, height: 24)
          }
        }
        
        if !isLastItem {
          Divider()
            .frame(height: 1)
            .background(Colors.greyDefault.swiftUIColor)
            .frame(maxWidth: .infinity)
        }
      }
    }
  }
  
  var footerView: some View {
    FullWidthButton(
      type: .primary,
      title: L10N.Common.Common.Confirm.Button.title,
      isLoading: $viewModel.showIndicator
    ) {
      viewModel.onConfirmButtonTap()
    }
    .padding(.bottom, 16)
  }
}
