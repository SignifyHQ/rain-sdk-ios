import Foundation
import Factory
import NetspendDomain
import NetSpendData
import LFUtilities
import LFLocalizable

@MainActor
final class AccountLimitsViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.nsAccountRepository) var nsAccountRepository
  
  @Published var isFetchingTransferLimit = false
  @Published var isFetchTransferLimitFail = false
  @Published var isRequesting = false
  @Published var depositLimits = APINetspendAccountLimits.DepositLimits()
  @Published var withdrawalLimits = APINetspendAccountLimits.WithdrawalLimits()
  @Published var spendingLimits = APINetspendAccountLimits.SpendingLimits()
  @Published var toastMessage: String?
  @Published var popup: Popup?

  lazy var accountLimitsUseCase: NSGetAccountLimitsUseCaseProtocol = {
    NSGetAccountLimitsUseCase(repository: nsAccountRepository)
  }()
  
  init() {
    getTransferLimitConfigs()
  }
}

// MARK: - API
extension AccountLimitsViewModel {
  func getTransferLimitConfigs() {
    Task {
      defer { isFetchingTransferLimit = false }
      isFetchingTransferLimit = true
      do {
        if let limits = try await accountLimitsUseCase.execute() as? APINetspendAccountLimits {
          depositLimits = limits.depositLimits
          withdrawalLimits = limits.withdrawalLimits
          spendingLimits = limits.spendingLimits
        } else {
          isFetchTransferLimitFail = true
        }
      } catch {
        isFetchTransferLimitFail = true
        guard let errorObject = error.asErrorObject else {
          toastMessage = error.userFriendlyMessage
          return
        }
        toastMessage = errorObject.message
      }
    }
  }
  
  func requestLimitIncrease() {
    Task {
      defer { isRequesting = false }
      isRequesting = true
      do {
        _ = try await accountRepository.createSupportTicket(
          title: .empty,
          description: .empty,
          type: Constants.SupportTicket.increaseLimit.value
        )
        popup = .createTicketSuccess
      } catch {
        guard let errorObject = error.asErrorObject else {
          toastMessage = error.userFriendlyMessage
          return
        }
        switch errorObject.code {
        case Constants.ErrorCode.ticketExisted.value:
          popup = .ticketExisted
        default:
          toastMessage = errorObject.message
        }
      }
    }
  }
}

// MARK: - View Helpers
extension AccountLimitsViewModel {
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Types
extension AccountLimitsViewModel {
  enum Popup {
    case createTicketSuccess
    case ticketExisted
  }
}
