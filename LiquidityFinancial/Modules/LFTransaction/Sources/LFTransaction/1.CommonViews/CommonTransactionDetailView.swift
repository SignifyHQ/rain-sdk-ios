import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CommonTransactionDetailView<Content: View>: View {
  @ViewBuilder let content: Content?
  @StateObject private var viewModel: CommonTransactionDetailViewModel
  @Environment(\.openURL) var openURL
  
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
      disclosureView
    }
    .frame(maxWidth: .infinity)
    .scrollOnOverflow()
    .defaultToolBar(
      icon: .support,
      navigationTitle: viewModel.navigationTitle,
      openSupportScreen: {
        viewModel.openSupportScreen()
      }
    )
    .navigationBarTitleDisplayMode(.inline)
    .padding([.top, .horizontal], 30)
    .padding(.bottom, 20)
    .background(Colors.background.swiftUIColor)
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
  
  var amountView: some View {
    VStack(spacing: 14) {
      HStack(spacing: 4) {
        Text(viewModel.amountValue)
          .font(Fonts.medium.swiftUIFont(size: 40))
          .foregroundColor(viewModel.colorForType)
        if let icon = viewModel.cryptoIconImage {
          icon
        }
      }
      if viewModel.currentBalance != nil {
        Text(LFLocalizable.TransactionDetail.BalanceCash.title(viewModel.balanceValue))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
      }
    }
  }
  
  @ViewBuilder
  var disclosureView: some View {
    if viewModel.isDonationsCard {
      TextTappable(
        text: viewModel.disclosureString,
        fontSize: Constants.FontSize.ultraSmall.value,
        links: [viewModel.termsLink]
      ) { tappedString in
        guard let url = viewModel.getUrl(for: tappedString) else { return }
        openURL(url)
      }
      .frame(height: 200)
    }
  }
}
