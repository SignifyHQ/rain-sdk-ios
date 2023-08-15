import SwiftUI
import LFUtilities
import LFLocalizable
import LFStyleGuide
import LFCard

struct TransactionDetailView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: TransactionDetailViewModel
  
  private let popToRoot: Bool
  
  init(
    type: TransactionRowView.Kind? = nil,
    transactionId: String,
    walletAddress: String? = nil,
    isNewWalletAddress: Bool = false,
    popToRoot: Bool = false
  ) {
    self.popToRoot = popToRoot
    _viewModel = .init(
      wrappedValue: .init(
        transactionId: transactionId,
        walletAddress: walletAddress ?? .empty,
        rowType: type,
        isNewWaletAddress: isNewWalletAddress
      )
    )
  }
  
  var body: some View {
    ZStack {
      Colors.background.swiftUIColor.edgesIgnoringSafeArea(.all)
      if viewModel.isFetchingData {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      } else {
        content
      }
    }
    // .track(name: String(describing: type(of: self))) TODO: - Will be updated later
    .navigationBarTitleDisplayMode(.inline)
    .defaultToolBar(icon: .intercom, navigationTitle: viewModel.navigationTitle, openIntercom: {})
    .popup(isPresented: $viewModel.showSaveWalletAddressPopup) {
      saveWalletAddressPopup
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .rewardTypes:
        EmptyView() // TODO: - Will be implemented later
        // RewardTypesView()
      case .receipt:
        EmptyView() // TODO: - Will be implemented later
        // TransactionReceiptView(transaction: transaction)
      case .saveAddress:
        EmptyView() // TODO: - Will be implemented later
        // EnterNicknameOfWalletView(walletAddress: address)
      }
    }
  }
}

// MARK: - View Components
extension TransactionDetailView {
  var content: some View {
    GeometryReader { geometry in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
          description
          Spacer()
            .frame(height: 8)
          timestamp
          Spacer()
            .frame(height: 24)
          amount
          Spacer()
            .frame(height: 32)
          mainContent
          Spacer()
          VStack(spacing: 20) {
            TransferDebitSuggestionView(data: .build(from: viewModel.transaction))
            badge
            navigationButtons
          }
        }
        .padding([.horizontal, .top], 30)
        .padding(.bottom, 20)
        .frame(minHeight: geometry.size.height)
      }
      .frame(width: geometry.size.width)
    }
  }
  
  @ViewBuilder var description: some View {
    if let description = viewModel.description {
      Text(description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
        .multilineTextAlignment(.center)
    }
  }
  
  private var timestamp: some View {
    Text(viewModel.timestamp)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
      .frame(maxWidth: .infinity, alignment: .center)
  }
  
  private var amount: some View {
    VStack(spacing: 4) {
      HStack(alignment: .firstTextBaseline, spacing: 16) {
        if let formattedAmmount = viewModel.transaction.formattedAmmount {
          Text(formattedAmmount)
            .font(Fonts.bold.swiftUIFont(size: 50))
            .foregroundColor(viewModel.amountColor)
            .minimumScaleFactor(0.6)
            .allowsTightening(true)
        }
        if !viewModel.transaction.isCashTransaction, LFUtility.cryptoEnabled {
          GenImages.Images.icCrypto.swiftUIImage
            .resizable()
            .frame(20)
            .foregroundColor(Colors.primary.swiftUIColor)
            .padding(.leading, 4)
        }
      }
      
      switch viewModel.amountBottom {
      case .balance:
        balance
      case .totalDonations:
        totalDonations
      }
    }
  }
  
  @ViewBuilder var balance: some View {
    if let balance = viewModel.transaction.currentBalance {
      if viewModel.transaction.isCashTransaction {
        Text(
          LFLocalizable.TransactionDetail.BalanceCash.title(balance.formattedAmount(prefix: "$", minFractionDigits: 2))
        )
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
      } else {
        Text(
          LFLocalizable.TransactionDetail.BalanceCrypto.title(balance.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3))
        )
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
      }
    }
  }
  
  @ViewBuilder var totalDonations: some View {
    if let value = viewModel.transaction.donationsBalance {
      Text(LFLocalizable.TransactionDetail.TotalDonated.title(value.formattedAmount(prefix: "$", minFractionDigits: 2)))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.6))
    }
  }
  
  @ViewBuilder var mainContent: some View {
    switch viewModel.content {
    case let .sections(sections):
      ForEach(sections, id: \.self) { item in
        TransactionDetailRow(data: item)
      }
    case let .card(type):
      TransactionCardView(type: type)
    case let .transfer(data):
      transfer(data: data)
    case .none:
      EmptyView()
    }
  }
  
  func transfer(data: TransferStatusView.Data) -> some View {
    VStack(spacing: 32) {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      TransferStatusView(data: data)
    }
  }
  
  @ViewBuilder var badge: some View {
    if let badge = viewModel.badge {
      HStack(spacing: 8) {
        badge.image
          .foregroundColor(Colors.label.swiftUIColor)
        Text(badge.text)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
  }
  
  var navigationButtons: some View {
    VStack(spacing: 10) {
      if viewModel.showRewardTypesButton {
        FullSizeButton(title: LFLocalizable.TransactionDetail.CurrentRewards.title, isDisable: false, type: .tertiary) {
          viewModel.rewardTypesTapped()
        }
      }
      if viewModel.showReceiptButton {
        FullSizeButton(title: LFLocalizable.TransactionDetail.Receipt.button, isDisable: false, type: .secondary) {
          viewModel.receiptTapped()
        }
      }
    }
  }
  
  private var saveWalletAddressPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.TransactionDetail.SaveWalletPopup.title,
      message: LFLocalizable.TransactionDetail.SaveWalletPopup.description,
      primary: .init(text: LFLocalizable.TransactionDetail.SaveWalletPopup.button) {
        // viewModel.navigatedToEnterWalletNicknameScreen()
      },
      secondary: .init(text: LFLocalizable.Button.NotNow.title) {
        viewModel.dismissPopup()
      }
    )
  }
}

// MARK: UI Helpers
extension TransactionDetailView {
  private func dismissAction() {
    if !popToRoot {
      dismiss()
    } else {
      LFUtility.popToRootView()
    }
  }
}
