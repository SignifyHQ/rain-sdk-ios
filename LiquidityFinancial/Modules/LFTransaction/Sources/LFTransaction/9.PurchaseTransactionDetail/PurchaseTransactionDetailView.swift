import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFServices
import Factory

public struct PurchaseTransactionDetailView: View {
  @StateObject private var viewModel: PurchaseTransactionDetailViewModel
  
  @Injected(\.transactionNavigation) var transactionNavigation
  
  public init(transaction: TransactionModel) {
    _viewModel = .init(wrappedValue: PurchaseTransactionDetailViewModel(transaction: transaction))
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: viewModel.transaction, content: content)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case let .cryptoReceipt(receipt):
          CryptoTransactionReceiptView(accountID: viewModel.transaction.id, receipt: receipt)
        case let .donationReceipt(receipt):
          DonationTransactionReceiptView(accountID: viewModel.transaction.id, receipt: receipt)
        case let .disputeTransaction(netspendAccountID, passcode):
          transactionNavigation.resolveDisputeTransactionView(
            id: netspendAccountID,
            passcode: passcode
          ) {
            viewModel.navigation = nil
          }?.navigationBarHidden(true)
        case .rewardCampaigns:
          transactionNavigation.resolveCurrentReward()
        }
      }
  }
}

  // MARK: - View Components
private extension PurchaseTransactionDetailView {
  var content: some View {
    VStack {
      
      if viewModel.transaction.rewards != nil {
        TransactionCardView(information: viewModel.cardInformation)
          .padding(.bottom, 12)
      } else {
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
          .padding(.bottom, 16)
        
        VStack(spacing: 12) {
          HStack {
            Text(LFLocalizable.rewards)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.regular.swiftUIFont(size: 16))
            
            Spacer()
            
            Text("0")
              .foregroundColor(Colors.primary.swiftUIColor)
              .font(Fonts.semiBold.swiftUIFont(size: 16))
            Text(Constants.CurrencyUnit.usd.description)
              .foregroundColor(Colors.label.swiftUIColor)
              .font(Fonts.semiBold.swiftUIFont(size: 16))
          }
          .padding(.bottom, 16)
          
          if let note = viewModel.transaction.note {
            VStack(spacing: 12) {
              Text((note.title ?? "").uppercased())
                .foregroundColor(Colors.label.swiftUIColor)
                .font(Fonts.regular.swiftUIFont(size: 16))
              
              Text(note.message ?? "")
                .multilineTextAlignment(.center)
                .font(Fonts.regular.swiftUIFont(size: 12))
                .foregroundColor(Colors.label.swiftUIColor)
            }
            .padding(20)
            .fixedSize(horizontal: false, vertical: true)
            .background(Colors.secondaryBackground.swiftUIColor)
            .cornerRadius(10)
          }
        }
      }
      
      VStack(spacing: 10) {
        if viewModel.transaction.rewards == nil {
          Spacer()
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
            .padding(.bottom, 16)
          
          FullSizeButton(
            title: LFLocalizable.Button.ContactSupport.title,
            isDisable: false,
            type: .tertiary
          ) {
            viewModel.openContactSupport()
          }
        }
        
        FullSizeButton(
          title: LFLocalizable.TransactionDetail.CurrentReward.title,
          isDisable: false,
          type: .tertiary
        ) {
          viewModel.onClickedCurrentRewardButton()
        }
        
        FullSizeButton(
          title: LFLocalizable.Button.DisputeTransaction.title,
          isDisable: false,
          isLoading: $viewModel.isLoadingDisputeTransaction,
          type: .tertiary
        ) {
          viewModel.getDisputeAuthorizationCode()
        }
        
        if let receiptType = viewModel.transaction.receipt?.type {
          FullSizeButton(
            title: LFLocalizable.TransactionDetail.Receipt.button,
            isDisable: false,
            type: .secondary
          ) {
            viewModel.goToReceiptScreen(receiptType: receiptType)
          }
        }
      }
    }
  }
}
