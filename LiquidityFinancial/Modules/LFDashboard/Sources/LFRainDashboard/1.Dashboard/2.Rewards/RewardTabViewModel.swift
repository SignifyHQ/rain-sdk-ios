import Foundation
import SwiftUI
import AccountDomain
import AccountData
import LFUtilities
import Factory
import Combine
import AccountService
import GeneralFeature
import Services
import LFLocalizable
import LFStyleGuide
import RainData
import RainDomain

@MainActor
class RewardTabViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.portalService) var portalService
  @LazyInjected(\.rainRewardRepository) var rainRewardRepository
  
  @Published var showWithdrawalBalanceSheet: Bool = false
  @Published var balances: [RewardBalance: Double] = [:]
  @Published var toastMessage: String?
  
  @Published var selectedRewardCurrency: AssetType = .usdc // For now, we will only support USDC rewards
  @Published var navigation: Navigation?
  @Published var collateralAsset: AssetModel?
  @Published var activity = Activity.loading
  @Published var accounts: [AccountModel] = []
  @Published var transactions: [TransactionModel] = []
  @Published var availableRewardCurrencies: [AssetType] = [.usdc] // For now, we will only support USDC rewards
  
  private lazy var getTransactionsListUseCase: GetTransactionsListUseCaseProtocol = {
    GetTransactionsListUseCase(repository: accountRepository)
  }()
  
  private lazy var getRewardBalanceUseCase: RainGetRewardBalanceUseCaseProtocol = {
    RainGetRewardBalanceUseCase(repository: rainRewardRepository)
  }()
  
  var currencyType = Constants.CurrencyType.crypto.rawValue
  var transactionTypes = Constants.TransactionTypesRequest.reward.types
  private var cancellable: Set<AnyCancellable> = []
  
  init() {
    fetchAllTransactions()
    getCollateralAsset()
    getRewardBalance()
  }
}

// MARK: - API Handle
extension RewardTabViewModel {
  func fetchAllTransactions() {
    Task { @MainActor in
      currencyType = Constants.CurrencyType.crypto.rawValue
      transactionTypes = Constants.TransactionTypesRequest.reward.types
      
      await apiLoadTransactions(with: nil) // TODO: MinhNguyen - Will update it in the ENG-4319 ticket
    }
  }
  
  func apiLoadTransactions(with contractAddress: String?) async {
    do {
      let parameters = APITransactionsParameters(
        currencyType: currencyType,
        transactionTypes: transactionTypes,
        limit: Constants.shortTransactionLimit,
        offset: Constants.transactionOffset,
        contractAddress: contractAddress
      )
      let transactions = try await getTransactionsListUseCase.execute(parameters: parameters)
      self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
      activity = .transactions
    } catch {
      toastMessage = error.userFriendlyMessage
      if transactions.isEmpty {
        activity = .failure
      }
    }
  }
  
  func getRewardBalance() {
    Task {
      do {
        let response = try await getRewardBalanceUseCase.execute()
        
        balances[.available] = response.data.first?.rewardedAmount ?? 0
        balances[.unprocessed] = response.data.first?.unprocessedAmount ?? 0
        balances[.locked] = response.data.first?.lockedAmount ?? 0
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func getCollateralAsset() {
    portalStorage
      .cryptoAsset(with: AssetType.usdc.symbol ?? "N/A")
      .receive(on: DispatchQueue.main)
      .map { asset in
        guard let asset else { return nil }
        return AssetModel(portalAsset: asset)
      }
      .assign(to: &$collateralAsset)
  }
}

// MARK: - View Helpers
extension RewardTabViewModel {
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
  }
  
  func withdrawBalanceButtonTapped() {
    showWithdrawalBalanceSheet = true
  }
  
  func handleRewardWithdrawalSuccessfully() {
    navigation = nil
    getRewardBalance()
  }
  
  func walletTypeButtonTapped(type: WalletType) {
    let availableBalance = balances[.available] ?? 0.0
    
    Task {
      showWithdrawalBalanceSheet = false
      guard let collateralAsset else {
        toastMessage = L10N.Common.MoveCryptoInput.SendCollateral.errorMessage
        return
      }
      
      switch type {
      case .internalWallet:
        guard let myUSDCWalletAddress = await portalService.getWalletAddress(), !myUSDCWalletAddress.isEmpty else {
          return
        }
        navigation = .enterWithdrawalAmount(
          address: myUSDCWalletAddress,
          assetCollateral: collateralAsset,
          balance: availableBalance
        )
      case .externalWallet:
        navigation = .enterWalletAddress(assetCollateral: collateralAsset, balance: availableBalance)
      }
    }
  }
}

extension RewardTabViewModel {
  enum Activity {
    case loading
    case failure
    case transactions
  }
  
  enum Navigation {
    case transactions
    case transactionDetail(TransactionModel)
    case enterWithdrawalAmount(address: String, assetCollateral: AssetModel, balance: Double)
    case enterWalletAddress(assetCollateral: AssetModel, balance: Double)
  }
}

extension RewardTabViewModel {
  enum RewardBalance: CaseIterable {
    case available
    case unprocessed
    case locked
    
    var title: String {
      switch self {
      case .available:
        L10N.Common.RewardTabView.CurrentRewardsBalance.title
      case .unprocessed:
        L10N.Common.RewardTabView.PendingRewardsBalance.title
      case .locked:
        L10N.Common.RewardTabView.LockedRewardsBalance.title
      }
    }
    
    var fontSize: CGFloat {
      switch self {
      case .available:
        Constants.FontSize.small.value
      case .unprocessed, .locked:
        Constants.FontSize.ultraSmall.value
      }
    }
    
    var foregroundColor: Color {
      switch self {
      case .available:
        Colors.label.swiftUIColor
      case .unprocessed, .locked:
        Colors.label.swiftUIColor.opacity(0.75)
      }
    }
  }
}

