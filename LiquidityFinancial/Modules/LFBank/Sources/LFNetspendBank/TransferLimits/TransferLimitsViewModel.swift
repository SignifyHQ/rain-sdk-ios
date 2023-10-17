import Foundation
import Factory
import AccountDomain
import LFUtilities

@MainActor
final class TransferLimitsViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isFetchingTransferLimit = false
  @Published var isFetchTransferLimitFail = false
  @Published var isRequesting = false
  @Published var depositTransferLimitConfigs = TransferLimits.default
  @Published var withdrawTransferLimitConfigs = TransferLimits.default
  @Published var spendingTransferLimitConfigs = TransferLimits.default
  @Published var toastMessage: String?
  @Published var popup: Popup?

  init() {
    getTransferLimitConfigs()
  }
}

// MARK: - API
extension TransferLimitsViewModel {
  func getTransferLimitConfigs() {
    Task {
      defer { isFetchingTransferLimit = false }
      isFetchingTransferLimit = true
      do {
        let user = try await accountRepository.getUser()
        let transferLimitConfigs = user.transferLimitConfigsEntity.map {
          TransferLimitConfig(from: $0)
        }
        depositTransferLimitConfigs = TransferLimits(
          transferLimitConfigs: transferLimitConfigs.filter({ $0.type == .deposit })
        )
        withdrawTransferLimitConfigs = TransferLimits(
          transferLimitConfigs: transferLimitConfigs.filter({ $0.type == .withdraw })
        )
        spendingTransferLimitConfigs = TransferLimits(
          transferLimitConfigs: transferLimitConfigs.filter({ $0.type == .spending })
        )
      } catch {
        isFetchTransferLimitFail = true
        guard let errorObject = error.asErrorObject else {
          toastMessage = error.localizedDescription
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
          toastMessage = error.localizedDescription
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
extension TransferLimitsViewModel {
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Types
extension TransferLimitsViewModel {
  enum Popup {
    case createTicketSuccess
    case ticketExisted
  }
}
