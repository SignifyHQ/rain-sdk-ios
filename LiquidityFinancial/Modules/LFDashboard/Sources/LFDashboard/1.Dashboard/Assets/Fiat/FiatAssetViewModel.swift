import Foundation
import AccountDomain
import AccountData
import NetSpendData
import LFUtilities
import Factory
import LFBank
import LFTransaction

@MainActor
class FiatAssetViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  @Published var account: LFAccount?
  @Published var isLoadingACH: Bool = false
  @Published var showTransferSheet: Bool = false
  @Published var cryptoPrice: String = "0.00"
  @Published var changePercent: Double = 0
  @Published var showCryptoDetail: Bool = false
  @Published var toastMessage: String = ""
  @Published var navigation: Navigation?
  @Published var activity = Activity.loading
  @Published var transactions: [TransactionModel] = []
  @Published var achInformation: ACHModel = .default
  @Published var linkedAccount: [APILinkedSourceData] = []

  let asset: AssetModel
  let currencyType = Constants.CurrencyType.fiat.rawValue
  private let guestHandler: () -> Void
  private let isGuest = false // TODO: - Will be remove after handle guest feature

  var usdBalance: String {
    account?.availableBalance.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.rawValue,
      minFractionDigits: 3,
      maxFractionDigits: 3
    ) ?? asset.availableBalanceFormatted
  }
  
  init(asset: AssetModel, guestHandler: @escaping () -> Void) {
    self.asset = asset
    self.guestHandler = guestHandler
    getACHInfo()
    getListConnectedAccount()
  }
}

// MARK: - Private Functions
private extension FiatAssetViewModel {
  func getFiatAccount() async {
    do {
      let accounts = try await accountRepository.getAccount(currencyType: currencyType)
      guard let account = accounts.first else {
        return
      }
      self.account = account
      self.accountDataManager.fiatAccountID = account.id
      await loadTransactions(accountId: account.id)
    } catch {
      toastMessage = error.localizedDescription
    }
  }
  
  func loadTransactions(accountId: String) async {
    do {
      let transactions = try await accountRepository.getTransactions(
        accountId: accountId,
        currencyType: currencyType,
        transactionTypes: Constants.TransactionTypesRequest.fiat.types,
        limit: 50,
        offset: 0
      )
      self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
      activity = .transactions
    } catch {
      toastMessage = error.localizedDescription
      activity = .failure
    }
  }
  
  func getACHInfo() {
    isLoadingACH = true
    Task {
      do {
        let achResponse = try await externalFundingRepository.getACHInfo(sessionID: accountDataManager.sessionID)
        achInformation = ACHModel(
          accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
          routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
          accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
        )
        isLoadingACH = false
      } catch {
        isLoadingACH = false
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func getListConnectedAccount() {
    Task {
      do {
        let sessionID = self.accountDataManager.sessionID
        let response = try await self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        let linkedAccount = response.linkedSources.compactMap({
          APILinkedSourceData(
            name: $0.name,
            last4: $0.last4,
            sourceType: APILinkSourceType(rawValue: $0.sourceType.rawString),
            sourceId: $0.sourceId,
            requiredFlow: $0.requiredFlow
          )
        })
        self.linkedAccount = linkedAccount
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - View Helpers
extension FiatAssetViewModel {
  func refreshData() {
    Task {
      await getFiatAccount()
    }
  }
  
  func addMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      // fullScreen = .fundCard
      // TODO: Will implement later
    } else {
      navigation = .addMoney
    }
  }
  
  func sendMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      // fullScreen = .fundCard
      // TODO: Will implement later
    } else {
      navigation = .sendMoney
    }
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    if isGuest {
      guestHandler()
    } else {
      Haptic.impact(.light).generate()
      navigation = .transactionDetail(transaction)
    }
  }
}

// MARK: - Types
extension FiatAssetViewModel {
  enum Activity {
    case loading
    case failure
    case transactions
  }
  
  enum Navigation {
    case addMoney
    case sendMoney
    case transactions
    case transactionDetail(TransactionModel)
  }
}
