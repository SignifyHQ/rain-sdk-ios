import Combine
import Foundation
import SwiftUI
import LFUtilities
import LFLocalizable
import LFStyleGuide
import AccountData
import AccountDomain
import Factory
import RewardData
import RewardDomain

@MainActor
final class TransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.rewardRepository) var rewardRepository

  @Published var transaction: TransactionModel = .default
  @Published var donation: DonationModel = .default
  @Published var isFetchingData = false
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()

  init(accountID: String, transactionId: String, fundraisersId: String, kind: TransactionDetailType?) {
    maybeShowRatingAlert()
    switch kind {
    case .donation:
      getFundraisersDetail(fundraisersID: fundraisersId, transactionId: transactionId)
    default:
      getTransactionDetail(accountID: accountID, transactionId: transactionId)
    }
  }
}

// MARK: - API
private extension TransactionDetailViewModel {
  func getTransactionDetail(accountID: String, transactionId: String) {
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
  
  func getFundraisersDetail(fundraisersID: String, transactionId: String) {
    Task {
      defer { isFetchingData = false }
      isFetchingData = true
      do {
        let fundraisers = try await self.rewardUseCase.getFundraisersDetail(fundraiserID: fundraisersID)
        let donationDetail = fundraisers.latestDonations?.first { $0.id == transactionId }
        donation = DonationModel(
          id: transactionId,
          title: LFLocalizable.TransactionCard.Donation.header(fundraisers.fundraiser?.name ?? .empty),
          message: LFLocalizable.TransactionCard.Donation.message(
            fundraisers.fundraiser?.name ?? .empty,
            fundraisers.charity?.name ?? .empty
          ),
          fundraiserId: fundraisersID,
          amount: donationDetail?.amount ?? 0,
          totalDonation: fundraisers.currentDonatedAmount ?? 0,
          stickerURL: fundraisers.fundraiser?.stickerUrl,
          backgroundColor: fundraisers.fundraiser?.backgroundColor ?? .empty,
          status: DonationStatus(rawValue: donationDetail?.status ?? .empty) ?? .unknown,
          createdAt: donationDetail?.createdAt ?? .empty
        )
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
      LFUtilities.showRatingAlert()
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
        title: LFLocalizable.TransactionDetail.OrderType.title,
        value: transaction.type.title
      )
    ]
  }
  
  var refundCryptoTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: LFLocalizable.TransactionDetail.Rewards.title,
        value: LFUtilities.cryptoCurrency,
        markValue: transaction.rewards?.amount?.formattedAmount(minFractionDigits: 2, maxFractionDigits: 2)
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
        value: LFUtilities.cryptoCurrency,
        markValue: transaction.balanceFormatted
      )
    ]
  }
}
