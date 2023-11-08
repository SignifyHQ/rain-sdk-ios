import Foundation
import Factory
import SolidData
import SolidDomain
import LFUtilities
import LFLocalizable

@MainActor
final class AccountLimitsViewModel: ObservableObject {
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isFetchingTransferLimit = false
  @Published var isFetchTransferLimitFail = false
  @Published var isRequesting = false
  @Published var model = AccountLimitsUIModel()
  @Published var toastMessage: String?
  @Published var popup: Popup?

  lazy var getAccountLimitUseCase: SolidGetAccountLimitsUseCaseProtocol = {
    SolidGetAccountLimitsUseCase(repository: solidAccountRepository)
  }()
  
  init() {
    getAccountLimits()
  }
}

// MARK: - API
extension AccountLimitsViewModel {
  func getAccountLimits() {
    Task {
      defer { isFetchingTransferLimit = false }
      isFetchingTransferLimit = true
      do {
        if let accountLimits = try await getAccountLimitUseCase.execute() {
          let model = AccountLimitsUIModel(accountLimitsEntity: accountLimits)
          self.model = model
        } else {
          isFetchTransferLimitFail = true
        }
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
