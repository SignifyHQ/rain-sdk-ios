import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Factory

struct DepositTransactionDetailView: View {
  @StateObject private var viewModel = DepositTransactionDetailViewModel()
  @Injected(\.transactionNavigation) var transactionNavigation
  
  let transaction: TransactionModel

  init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
  }
}

// MARK: - View Components
private extension DepositTransactionDetailView {
  var content: some View {
    VStack(spacing: 16) {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.bottom, 16)
      if transaction.status != nil {
        StatusDiagramView(
          transaction: transaction,
          startTitle: L10N.Common.TransferView.Status.Deposit.started,
          completedTitle: L10N.Common.TransferView.Status.Deposit.completed
        )
      }
      
      if let status = transaction.status {
        footerView(status: status)
      }
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .addBank:
        transactionNavigation.resolveAddBankDebit()
      }
    }
  }
  
  func footerView(status: TransactionStatus) -> some View {
    let hasExternalCardLinked = viewModel.linkedAccount.contains(where: { $0.sourceType == .externalCard })
    let shouldShowFasterDepositCard = transaction.isACHTransaction && !hasExternalCardLinked
  
    return VStack(spacing: 16) {
      if shouldShowFasterDepositCard {
        fasterDepositCard
      } else {
        Spacer()
      }
      StatusView(transactionStatus: status)
        .padding(.bottom, status == .pending ? 0 : 16)
      if status == .pending {
        FullSizeButton(
          title: L10N.Common.TransactionDetail.CancelDeposit.button,
          isDisable: false,
          isLoading: $viewModel.isCancelingDeposit,
          type: .secondary
        ) {
          viewModel.cancelDepositTransaction(id: transaction.id)
        }
      }
    }
  }
  
  var fasterDepositCard: some View {
    ZStack(alignment: .top) {
      GenImages.Images.fasterDeposit.swiftUIImage
        .alignmentGuide(VerticalAlignment.top) {
          $0[VerticalAlignment.top] + 16
        }
        .zIndex(1)
      fasterDepositInformation
    }
    .padding(.vertical, 20)
  }
  
  var fasterDepositInformation: some View {
    VStack(alignment: .center, spacing: 12) {
      Text(L10N.Common.TransferDebitSuggestion.title)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.background.swiftUIColor)
      Text(L10N.Common.TransferDebitSuggestion.Body.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.background.swiftUIColor)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.bottom, 4)
      FullSizeButton(
        title: L10N.Common.TransferDebitSuggestion.Connect.title,
        isDisable: false,
        type: .white,
        fontSize: Constants.FontSize.ultraSmall.value,
        height: 34,
        cornerRadius: 17
      ) {
        viewModel.connectDebitCard()
      }
      .frame(width: 188)
    }
    .padding(.top, 120)
    .padding(.bottom, 24)
    .background(
      LinearGradient(
        gradient: Gradient(colors: gradientColor),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
    )
    .cornerRadius(32)
  }
}

// MARK: View Helpers
private extension DepositTransactionDetailView {
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
