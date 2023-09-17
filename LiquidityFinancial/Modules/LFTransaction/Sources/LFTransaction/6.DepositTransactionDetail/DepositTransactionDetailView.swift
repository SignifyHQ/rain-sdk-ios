import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct DepositTransactionDetailView: View {
  @StateObject private var viewModel = DepositTransactionDetailViewModel()
  let transaction: TransactionModel
  
  init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
  }
}

// MARK: - View Components
private extension DepositTransactionDetailView {
  var content: some View {
    VStack(spacing: 16) {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
        .padding(.bottom, 16)
      if let status = transaction.status {
        StatusDiagramView(
          transaction: transaction,
          startTitle: LFLocalizable.TransferView.Status.Deposit.started,
          completedTitle: LFLocalizable.TransferView.Status.Deposit.completed
        )
        footerView(status: status)
      }
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .addBank:
        EmptyView()
        // TODO: - Will be implemented later
        // AddBankWithDebitView()
      }
    }
  }
  
  @ViewBuilder func footerView(status: TransactionStatus) -> some View {
    if transaction.isACHTransaction && !viewModel.linkedAccount.contains(where: { $0.sourceType == .externalCard }) {
      Group {
        fasterDepositCard
        StatusView(transactionStatus: status)
          .padding(.top, -24)
      }
      .padding(.bottom, 16)
    } else {
      Group {
        Spacer()
        StatusView(transactionStatus: status)
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
      Text(LFLocalizable.TransferDebitSuggestion.title)
        .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.background.swiftUIColor)
      Text(LFLocalizable.TransferDebitSuggestion.Body.title)
        .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.background.swiftUIColor)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
        .padding(.bottom, 4)
      FullSizeButton(
        title: LFLocalizable.TransferDebitSuggestion.Connect.title,
        isDisable: false,
        type: .white,
        fontSize: Constants.FontSize.ultraSmall.value,
        height: 34,
        cornerRadius: 17
      ) {
        // TODO: Will be implemented later
        // viewModel.connectDebitCard()
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
