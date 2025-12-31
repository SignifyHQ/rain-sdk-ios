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
public final class TransactionDetailsViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.rewardRepository) var rewardRepository

  @Published var transaction: TransactionModel = .default
  @Published var donation: DonationModel = .default
  @Published var isFetchingData = false
  @Published var toastData: ToastData?
  
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
  
  var cryptoTransactions: [TransactionInformation] {
    var info = [
      TransactionInformation(
        title: L10N.Common.TransactionDetails.Info.orderType,
        value: transaction.type.displayTitle
      ),
      TransactionInformation(
        title: L10N.Common.TransactionDetails.Info.address,
        value: transaction.contractAddress ?? .empty
      )
    ]
    
    if transaction.type.isTransferOrder {
      info.append(
        TransactionInformation(
          title: L10N.Common.TransactionDetails.Info.fee,
          value: .empty
        )
      )
      
      if let hash = transaction.transactionHash {
        info.append(
          TransactionInformation(
            title: L10N.Common.TransactionDetails.Info.hash,
            value: hash
          )
        )
      }
    }
    
    return info
  }
}

// MARK: - APIs Handler
private extension TransactionDetailsViewModel {
  func getTransactionDetail(by method: Method) {
    Task {
      defer { isFetchingData = false }
      isFetchingData = true
      
      do {
        switch method {
        case .transactionID(let id):
          let transactionEntity = try await getTransactionDetailUseCase.execute(transactionID: id)
          transaction = TransactionModel(from: transactionEntity)
        case let .localTransaction(transaction):
          self.transaction = transaction
        }
      } catch {
        log.error(error.userFriendlyMessage)
        toastData = ToastData(type: .error, title: error.userFriendlyMessage)
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
        toastData = ToastData(type: .error, title: error.userFriendlyMessage)
      }
    }
  }
}

// MARK: - Handle UI/UX
private extension TransactionDetailsViewModel {
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

// MARK: - Enums
extension TransactionDetailsViewModel {
  public enum Method {
    case transactionID(String)
    case localTransaction(TransactionModel)
  }
}
