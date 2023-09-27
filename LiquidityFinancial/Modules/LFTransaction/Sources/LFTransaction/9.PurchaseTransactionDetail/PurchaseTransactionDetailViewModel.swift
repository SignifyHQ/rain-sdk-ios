import Foundation
import LFServices
import LFLocalizable
import LFUtilities
import LFStyleGuide
import NetSpendData
import NetSpendDomain
import NetspendSdk
import Factory

final class PurchaseTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.intercomService) var intercomService

  @Published var navigation: Navigation?
  @Published var isLoadingDisputeTransaction: Bool = false
  @Published var toastMessage: String?

  let transaction: TransactionModel
  
  init(transaction: TransactionModel) {
    self.transaction = transaction
  }
}

// MARK: - API
extension PurchaseTransactionDetailViewModel {
  func getDisputeAuthorizationCode() {
    Task { @MainActor in
      defer {
        isLoadingDisputeTransaction = false
      }
      isLoadingDisputeTransaction = true
      do {
        guard let session = netspendDataManager.sdkSession else { return }
        let code = try await nsPersionRepository.getAuthorizationCode(sessionId: session.sessionId)
        guard let id = accountDataManager.externalAccountID else { return }
        navigation = .disputeTransaction(id, code.authorizationCode)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }

}

// MARK: - View Helpers
extension PurchaseTransactionDetailViewModel {
  func goToReceiptScreen(receiptType: ReceiptType) {
    if let donationReceipt = transaction.donationReceipt, receiptType == .donation {
      navigation = .donationReceipt(donationReceipt)
    } else if let cryptoReceipt = transaction.cryptoReceipt, receiptType == .crypto {
      navigation = .cryptoReceipt(cryptoReceipt)
    }
  }
  
  func onClickedCurrentRewardButton() {
    navigation = .rewardCampaigns
  }
  
  var cardInformation: TransactionCardInformation {
    TransactionCardInformation(
      cardType: transaction.rewards?.type.transactionCardType ?? .unknow,
      amount: amountValue,
      message: transaction.rewards?.description ?? LFLocalizable.TransactionCard.Purchase.message(
        rewardAmount,
        amountValue,
        LFUtility.appName
      ),
      activityItem: LFLocalizable.TransactionCard.ShareCrypto.title(rewardAmount, LFUtility.appName, LFUtility.shareAppUrl),
      stickerUrl: transaction.rewards?.stickerUrl,
      color: transaction.rewards?.backgroundColor
    )
  }
  
  var rewardAmount: String {
    transaction.rewards?.amount?.formattedAmount(minFractionDigits: 2) ?? .empty
  }
  
  var amountValue: String {
    transaction.amount.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2)
  }
  
  func openContactSupport() {
    intercomService.openIntercom()
  }
}

// MARK: - Types
extension PurchaseTransactionDetailViewModel {
  enum Navigation {
    case cryptoReceipt(CryptoReceipt)
    case donationReceipt(DonationReceipt)
    case disputeTransaction(String, String)
    case rewardCampaigns
  }
}
