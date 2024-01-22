import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CommonTransactionDetailView<Content: View>: View {
  @ViewBuilder let content: Content?
  @StateObject private var viewModel: CommonTransactionDetailViewModel
  @State var openSafariType: CommonTransactionDetailViewModel.OpenSafariType?
  
  init(transaction: TransactionModel, content: Content? = EmptyView(), isCryptoBalance: Bool = false) {
    _viewModel = .init(
      wrappedValue: CommonTransactionDetailViewModel(
        transaction: transaction,
        isCryptoBalance: isCryptoBalance
      )
    )
    self.content = content
  }
  
  var body: some View {
    VStack(spacing: 24) {
      headerTitle
      amountView
      if let content = content {
        content
      } else {
        Spacer()
      }
      disclosureView()
    }
    .frame(maxWidth: .infinity)
    .scrollOnOverflow()
    .defaultToolBar(
      icon: .support,
      navigationTitle: viewModel.navigationTitle,
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .navigationBarTitleDisplayMode(.inline)
    .padding([.top, .horizontal], 30)
    .padding(.bottom, 20)
    .background(Colors.background.swiftUIColor)
    .fullScreenCover(item: $openSafariType, content: { type in
      switch type {
      case .disclosure(let url):
        SFSafariViewWrapper(url: url)
      }
    })
  }
}

// MARK: View Components
private extension CommonTransactionDetailView {
  var headerTitle: some View {
    VStack(spacing: 8) {
      Text(viewModel.descriptionDisplay)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
      Text(viewModel.transactionDate)
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
        .font(Fonts.regular.swiftUIFont(size: 10))
    }
  }
  
  var cryptoImageText: Text {
    if let image = viewModel.cryptoIconImage {
      return Text(image)
    }
    return Text("")
  }
  
  var amountView: some View {
    VStack(spacing: 14) {
      HStack(alignment: .bottom, spacing: 4) {
        Text(viewModel.amountValue)
          .font(viewModel.fontForType)
          .foregroundColor(viewModel.colorForType)
        + Text(" ")
        + cryptoImageText
      }
      if viewModel.currentBalance != nil {
        Text(LFLocalizable.TransactionDetail.BalanceCash.title(viewModel.balanceValue))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
      }
    }
  }
  
  @ViewBuilder
  func disclosureView() -> some View {
    let isTransferBalanceTransaction = viewModel.transaction.type == .deposit || viewModel.transaction.type == .withdraw
    if viewModel.isDonationsCard && !isTransferBalanceTransaction {
      TextTappable(
        text: viewModel.disclosureString,
        textColor: Colors.label.color.withAlphaComponent(0.6),
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [viewModel.termsLink],
        style: .fillColor(Colors.darkText.color)
      ) { tappedString in
        guard let url = viewModel.getUrl(for: tappedString) else { return }
        openSafariType = .disclosure(url)
      }
      .frame(height: 200)
      .padding(.top, -20)
    }
  }
}
