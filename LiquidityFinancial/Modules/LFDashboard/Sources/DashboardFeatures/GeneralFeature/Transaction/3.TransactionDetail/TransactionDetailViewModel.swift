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
public final class TransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.rewardRepository) var rewardRepository

  @Published var transaction: TransactionModel = .default
  @Published var donation: DonationModel = .default
  @Published var isFetchingData = false
  @Published var toastMessage: String?
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  private lazy var getTransactionDetailUseCase: GetTransactionDetailUseCaseProtocol = {
    GetTransactionDetailUseCase(repository: accountRepository)
  }()

  public init(method: Method, fundraisersId: String, kind: TransactionDetailType?) {
    maybeShowRatingAlert()
    
    switch kind {
    case .donation:
      switch method {
      case .transactionID(let id):
        getFundraisersDetail(fundraisersID: fundraisersId, transactionId: id)
      default: break
      }
    default:
      getTransactionDetail(by: method)
    }
  }
}

// MARK: - API
private extension TransactionDetailViewModel {
  func getTransactionDetail(by method: Method) {
    Task {
      defer { isFetchingData = false }
      isFetchingData = true
      
      do {
        switch method {
        case .transactionID(let id):
          let transactionEntity = try await getTransactionDetailUseCase.execute(transactionID: id)
          transaction = TransactionModel(from: transactionEntity)
        case .transactionHash(let txnHash):
          let transactionEntity = try await getTransactionDetailUseCase.execute(transactionHash: txnHash)
          transaction = TransactionModel(from: transactionEntity)
        }
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
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
          title: L10N.Common.TransactionCard.Donation.header(fundraisers.fundraiser?.name ?? .empty),
          message: L10N.Common.TransactionCard.Donation.message(
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
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
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
        title: L10N.Common.TransactionDetail.OrderType.title,
        value: transaction.type.title
      )
    ]
  }
  
  var refundCryptoTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: L10N.Common.TransactionDetail.Rewards.title,
        value: LFUtilities.cryptoCurrency,
        markValue: transaction.rewards?.amount?.formattedAmount(minFractionDigits: 2, maxFractionDigits: 2)
      )
    ]
  }
  
  var refundTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: L10N.Common.TransactionDetail.Donation.title,
        value: transaction.rewards?.amount?.formattedAmount(
          prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2
        ) ?? .empty
      )
    ]
  }
  
  var rewardTransactions: [TransactionInformation] {
    [
      TransactionInformation(
        title: L10N.Common.TransactionDetail.Balance.title,
        value: LFUtilities.cryptoCurrency,
        markValue: transaction.balanceFormatted
      )
    ]
  }
}

// MARK: - Types
extension TransactionDetailViewModel {
  public enum Method {
    case transactionID(String)
    case transactionHash(String)
  }
}
