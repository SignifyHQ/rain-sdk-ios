import Combine
import Foundation
import SwiftUI
import LFUtilities
import LFLocalizable
import LFStyleGuide
import AccountData
import AccountDomain
import Factory

@MainActor
final class TransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager

  @Published var transaction: TransactionModel = .default
  @Published var isFetchingData = false

  init(transactionId: String) {
    maybeShowRatingAlert()
    getTransactionDetail(transactionId: transactionId)
  }
}

// MARK: - API
extension TransactionDetailViewModel {
  private func getTransactionDetail(transactionId: String) {
    guard let accountID = accountDataManager.accountID else {
      return
    }
    Task {
      defer { isFetchingData = false }
      isFetchingData = true
      do {
        let transactionEntity = try await accountRepository.getTransactionDetail(
          accountId: accountID, transactionId: transactionId
        )
        transaction = TransactionModel(from: transactionEntity)
      } catch {
      }
    }
  }
}

// MARK: - Rating
private extension TransactionDetailViewModel {
   func maybeShowRatingAlert() {
    #if DEBUG
    return
    #else
    if showRatingAlert {
      // analyticsService.track(event: Event(name: .conditionalReviewPrompt)) TODO: Will be implemented later
      LFUtility.showRatingAlert()
    }
    #endif
  }

  var showRatingAlert: Bool {
    switch transaction.type {
    case .rewardCryptoBack, .rewardCryptoDosh, .rewardCryptoBackReverse:
      if transaction.amount > 1 {
        return true // Show if user has earned more than 1 reward
      }
    case .rewardCashBackReverse, .rewardCashBack:
      if transaction.amount > 0.5 {
        return true // Show if user has earned more than $0.5 of cash back.
      }
    case .cryptoSell, .cryptoBuy, .deposit, .donation:
      return true
    default:
      break
    }
    return false
  }
}

// MARK: - Data
extension TransactionDetailViewModel {
  var cryptoTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: LFLocalizable.TransactionDetail.Balance.title,
        value: LFUtility.cryptoCurrency,
        markValue: transaction.currentBalance?.formattedAmount(minFractionDigits: 2)
      )
    ]
  }
  
  var refundCryptoTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: LFLocalizable.TransactionDetail.Rewards.title,
        value: LFUtility.cryptoCurrency,
        markValue: transaction.rewards?.amount?.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
      )
    ]
  }
  
  var refundTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: LFLocalizable.TransactionDetail.Donation.title,
        value: transaction.rewards?.amount?.formattedAmount(
          prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2
        ) ?? .empty
      )
    ]
  }
  
  var rewardTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: LFLocalizable.TransactionDetail.Balance.title,
        value: LFUtility.cryptoCurrency,
        markValue: transaction.currentBalance?.formattedAmount(minFractionDigits: 2)
      )
    ]
  }
}
