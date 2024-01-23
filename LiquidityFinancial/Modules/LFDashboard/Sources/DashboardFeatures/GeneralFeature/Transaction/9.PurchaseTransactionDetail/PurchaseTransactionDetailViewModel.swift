import Foundation
import Services
import LFLocalizable
import LFUtilities
import LFStyleGuide
import NetSpendData
import NetspendDomain
import NetspendSdk
import Factory

final class PurchaseTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.nsPersonRepository) var nsPersonRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var navigation: Navigation?
  @Published var isLoadingDisputeTransaction: Bool = false
  @Published var toastMessage: String?

  lazy var getAuthorizationUseCase: NSGetAuthorizationCodeUseCaseProtocol = {
    NSGetAuthorizationCodeUseCase(repository: nsPersonRepository)
  }()
  
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
        let code = try await getAuthorizationUseCase.execute(sessionId: session.sessionId)
        guard let id = accountDataManager.externalAccountID else { return }
        navigation = .disputeTransaction(id, code.authorizationCode)
      } catch {
        toastMessage = error.userFriendlyMessage
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
      rewardAmount: rewardValue,
      message: transaction.rewards?.description ?? L10N.Common.TransactionCard.Purchase.message(
        rewardAmount,
        amountValue,
        LFUtilities.appName
      ),
      activityItem: L10N.Common.TransactionCard.ShareCrypto.title(rewardAmount, LFUtilities.appName, LFUtilities.shareAppUrl),
      stickerUrl: transaction.rewards?.stickerUrl,
      color: transaction.rewards?.backgroundColor
    )
  }
  
  var rewardAmount: String {
    transaction.rewards?.amount?.formattedAmount(minFractionDigits: 2) ?? .empty
  }
  
  var amountValue: String {
    transaction.amount.formattedUSDAmount()
  }

  var rewardValue: String {
    transaction.rewards?.amount?.formattedUSDAmount() ?? "N/A"
  }
  
  func openContactSupport() {
    customerSupportService.openSupportScreen()
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
