import Combine
import Foundation
import SwiftUI
import LFUtilities
import LFLocalizable
import LFStyleGuide
import AccountData
import AccountDomain
import Factory
import LFCard

@MainActor
final class TransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var transaction: TransactionModel = TransactionModel()
  @Published var navigation: Navigation?
  @Published var showSaveWalletAddressPopup = false
  @Published var isFetchingData = false
  
  let walletAddress: String
  let transactionId: String
  let rowType: TransactionRowView.Kind?
  var content: Content?
  
  init(transactionId: String, walletAddress: String, rowType: TransactionRowView.Kind?, isNewWaletAddress: Bool) {
    self.transactionId = transactionId
    self.walletAddress = walletAddress
    self.rowType = rowType
    buildContent()
    maybeShowRatingAlert()
    getTransactionDetail()
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      // Show popup after view init
      self.showSaveWalletAddressPopup = isNewWaletAddress
    }
  }
}

// MARK: - API
extension TransactionDetailViewModel {
  private func getTransactionDetail() {
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

// MARK: - Actions
extension TransactionDetailViewModel {
  func rewardTypesTapped() {
    navigation = .rewardTypes
  }
  
  func receiptTapped() {
    navigation = .receipt
  }
  
  func dismissPopup() {
    showSaveWalletAddressPopup = false
  }
  
  func navigatedToEnterWalletNicknameScreen() {
    showSaveWalletAddressPopup = false
    navigation = .saveAddress(walletAddress)
  }
}

// MARK: - View Helpers
extension TransactionDetailViewModel {
  var isCrypto: Bool {
    switch transaction.transferType {
    case .buy, .sell, .send, .receive:
      return true
    default:
      return false
    }
  }
  
  var navigationTitle: String {
    transaction.title?.capitalized ?? ""
  }
  
  var description: String? {
    transaction.description?.uppercased()
  }
  
  var timestamp: String {
    transaction.transactionDateInLocalZone(includeYear: true)
  }
  
  var amountBottom: AmountBottom {
    transaction.txnType == .donation ? .totalDonations : .balance
  }
  
  var badge: Badge? {
    switch transaction.txnType {
    case .cashback:
      guard let status = transaction.rewards?.status else {
        return nil
      }
      return .init(image: status.image, text: status.display)
    case .donation, .reward:
      return nil
    default:
      break
    }
    
    let showBadge: Bool
    if isCrypto {
      showBadge = true
    } else {
      let types: [TransferType] = [.debitCard, .ach, .check]
      showBadge = types.contains(transaction.transferType)
    }
    guard showBadge, let status = transaction.status else { return nil }
    return .init(
      image: status.isPending ? GenImages.Images.statusPending.swiftUIImage : GenImages.Images.statusCompleted.swiftUIImage,
      text: status.localizedDescription()
    )
  }
  
  var showRewardTypesButton: Bool {
    guard LFUtility.cryptoEnabled else {
      return false
    }
    switch content {
    case .card:
      return true
    case .none, .sections, .transfer:
      return false
    }
  }
  
  var showReceiptButton: Bool {
    switch transaction.txnType {
    case .donation:
      return true
    default:
      let allowedTypes: [TransferType] = [.buy, .sell, .send, .receive, .card]
      return allowedTypes.contains(transaction.transferType)
    }
  }
  
  var amountColor: Color {
    if LFUtility.cryptoEnabled, !transaction.isCashTransaction {
      return Colors.primary.swiftUIColor
    } else {
      let isPending: Bool
      switch transaction.txnType {
      case .cashback:
        isPending = transaction.rewards?.status == .pending
      default:
        isPending = transaction.status == .pending
    }
    if isPending {
      return Colors.pending.swiftUIColor
    }
    if rowType == .userDonation || rowType == .fundraiserDonation, transaction.donationType == .oneTime {
      return Colors.green.swiftUIColor
    }
    return transaction.isPositiveAmount ? Colors.green.swiftUIColor : Colors.error.swiftUIColor
    }
  }
}

// MARK: - Transaction data
private extension TransactionDetailViewModel {
  func buildContent() {
    if transaction.txnType == .donation {
      if let data = buildDonationCardContent() {
        content = .card(.donation(data))
      }
    } else if transaction.txnType == .reward {
      if let data = buildCryptoRewardContent() {
        content = .card(.crypto(data))
      }
    } else if transaction.txnType == .cashback {
      if let data = TransferStatusView.Data.build(from: transaction) {
        content = .transfer(data)
      }
    } else {
      switch transaction.transferType {
      case .debitCard, .ach, .check:
        if let data = TransferStatusView.Data.build(from: transaction) {
          content = .transfer(data)
        }
      case .card:
        switch transaction.txnType {
        case .credit:
          content = .sections(buildRowDataForRefund())
        case .debit:
          if let data = buildDonationCardContent() {
            content = .card(.donation(data))
          } else if let data = buildCashbackCardContent() {
            content = .card(.cashback(data))
          } else if let data = buildCryptoCardContent() {
            content = .card(.crypto(data))
          }
        default:
          break
        }
      case .buy,
          .receive,
          .sell,
          .send:
        content = .sections(buildRowDataForBuySell())
      default:
        break
      }
    }
  }

  func buildDonationCardContent() -> TransactionCardView.DonationData? {
    guard
      let fundraiser = transaction.donationCharityFundraiser,
      let rewards = transaction.rewards,
      rewards.type == .donation
    else {
      return nil
    }
    return .init(fundraiser: fundraiser, donation: rewards.amount)
  }

  func buildCashbackCardContent() -> TransactionCardView.CashbackData? {
    guard
      let rewards = transaction.rewards,
      rewards.type == .cashback
    else {
      return nil
    }

    return .init(cashback: rewards.amount)
  }

  func buildCryptoRewardContent() -> TransactionCardView.CryptoData? {
    guard
      let purchase = transaction.purchaseAmount?.asDouble,
      let rewards = transaction.rewards,
      rewards.type == .crypto
    else {
      return nil
    }
    return .init(purchase: purchase, reward: rewards.amount)
  }

  func buildCryptoCardContent() -> TransactionCardView.CryptoData? {
    guard
      let purchase = transaction.amount?.asDouble,
      let rewards = transaction.rewards,
      rewards.type == .crypto
    else {
      return nil
    }
    return .init(purchase: purchase, reward: rewards.amount)
  }

  func buildRowDataForBuySell() -> [TransactionRowData] {
    // source
    var section = [TransactionRowData]()

    // Transaction type
    if transaction.title != nil {
      section.append(.init(title: Details.transactionType.title, value: transaction.transferType.rawValue.capitalized))
    }

    // Price and fee
    if let price = transaction.trxPrice {
      section.append(.init(title: LFLocalizable.TransactionDetail.Fee.title, value: "$0"))
      section.append(.init(title: LFLocalizable.TransactionDetail.Price.title, value: price))
    }

    // Netowrk fee
    if let fee = transaction.gasFee, let numAmount = Double(fee) {
      section.append(.init(title: LFLocalizable.TransactionDetail.NetworkFee.title, value: "\(numAmount.roundTo3f())"))
    }

    return section
  }

  func buildRowDataForRefund() -> [TransactionRowData] {
    var result: [TransactionRowData] = []

    if let rewards = transaction.rewards {
      let value: String
      let currency: String?
      if rewards.currency == "USD" {
        value = rewards.amount.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue, minFractionDigits: 2)
        currency = nil
      } else {
        value = rewards.amount.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
        currency = rewards.currency
      }
      result.append(.init(title: LFLocalizable.TransactionDetail.Rewards.title, markValue: value, value: currency))
    }

    return result
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
    switch transaction.transferType {
    case .card:
      if let rewards = transaction.rewards {
        switch rewards.type {
        case .crypto:
          if rewards.amount > 1 {
            return true // Show if user has earned more than 1 DOGE reward
          }
        case .donation:
          if rewards.amount > 0.5 {
            return true // Show if user has made a donation of more than $0.5.
          }
        case .cashback:
          if rewards.amount > 0.5 {
            return true // Show if user has earned more than $0.5 of cash back.
          }
        default:
          break
        }
      }
    case .sell, .buy:
      return true // Show if user has bought or sold crypto
    default:
      break
    }
    
    switch transaction.txnType {
    case .credit:
      return true // Show if user has made a deposit
    case .donation:
      return true // Show if user has made a donation
    default:
      break
    }
    return false
  }
}

// MARK: - Types

extension TransactionDetailViewModel {
  enum AmountBottom {
    case balance
    case totalDonations
  }
  
  enum Content {
    case sections([TransactionRowData])
    case card(TransactionCardView.Kind)
    case transfer(TransferStatusView.Data)
  }
  
  struct Badge {
    let image: Image
    let text: String
  }
  
  enum Navigation {
    case rewardTypes
    case receipt
    case saveAddress(String)
  }
  
  enum Details: String {
    case title
    case source
    case merchant
    case transactionId
    case paidTo
    case description
    case receivedFrom
    case transactionType
    case transactionStatus
    case reward
    case donation
    
    fileprivate var title: String {
      "transaction_detail.\(rawValue.snakeCased() ?? "")".localizedString
    }
  }
}
