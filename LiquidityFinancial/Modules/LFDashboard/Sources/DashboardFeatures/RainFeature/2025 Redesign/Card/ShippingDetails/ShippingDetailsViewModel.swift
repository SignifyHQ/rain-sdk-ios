import BaseOnboarding
import Factory
import Foundation
import LFStyleGuide
import LFUtilities
import RainDomain

@MainActor
final class ShippingDetailsViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.rainCardRepository) var rainCardRepository
  
  @Published var navigation: Navigation?
  
  @Published var isLoading: Bool = false
  @Published var popup: Popup?
  @Published var toastData: ToastData?
  
  lazy var cancelCardOrderUseCase: RainCancelCardOrderUseCaseProtocol = {
    RainCancelCardOrderUseCase(repository: rainCardRepository)
  }()
  
  var isShowingShippingDetailPost30Days: Bool {
    guard
      let createdAt = cardDetail.shippingAddress?.createdAtDate
    else { return false }
    
    return Date().timeIntervalSince(createdAt) > 30 * 24 * 60 * 60 // 30 days
  }
  
  var isShowingCancelCardOrderButton: Bool {
    return cardDetail.cardStatus == CardStatus.pending.rawValue
  }
  
  var fullName: String {
    if let firstName = accountDataManager.userInfomationData.firstName,
       let lastName = accountDataManager.userInfomationData.lastName {
      return firstName + " " + lastName
    }
    
    return accountDataManager.userInfomationData.fullName ?? accountDataManager.userNameDisplay
  }
  
  var phoneNumber: String {
    var phoneCode = ""
    var localNumber = (accountDataManager.userInfomationData.phone ?? accountDataManager.phoneNumber)
    // Attempt to match the country by phone's number country code
    if let matchedCountry = Country.allCases
      .sorted(
        by: {
          $0.phoneCode.count > $1.phoneCode.count
        }
      )
        .first(
          where: {
            localNumber.hasPrefix($0.phoneCode)
          }
        ) {
      // Store phone code separately
      phoneCode = matchedCountry.phoneCode
      // Strip the phone number removing code
      localNumber = String(localNumber.dropFirst(phoneCode.count))
    }
    // Format the number without code
    let formattedLocal = localNumber.formatInput(of: .phoneNumber)
    // Return formated phone number with code if detected
    return [phoneCode, formattedLocal]
      .filter {
        !$0.isEmpty
      }
      .joined(
        separator: " "
      )
  }
  
  let cardDetail: CardDetail
  private let onCardOrderCancelSuccess: ((Bool) -> Void)
  
  init(
    cardDetail: CardDetail,
    onCardOrderCancelSuccess: @escaping ((Bool) -> Void)
  ) {
    self.cardDetail = cardDetail
    self.onCardOrderCancelSuccess = onCardOrderCancelSuccess
  }
}

// MARK: - Handling Interations
extension ShippingDetailsViewModel {
  // Present bottom sheet with 2 options:
  // cancel and order now / cancel and order later
  func onCancelCardOrderTap(
  ) {
    popup = .confirmCardOrderCancel
  }
  // Call the API to cancel the card order after user chooses one of the options
  func onConfirmCancelCardOrderTap(
    shouldTakeToNewCardOrder: Bool = false
  ) {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      hidePopup()
      
      do {
        try await cancelCardOrder()
        
        // Call the callback if the user chose to order new card now
        if shouldTakeToNewCardOrder {
          onCardOrderCancelSuccess(true)
        } else {
          // Present a success popup only if the user chose to order new card later
          popup = .cardOrderCanceledSuccessfully
        }
      } catch {
        toastData = .init(
          type: .error,
          title: error.userFriendlyMessage
        )
      }
    }
  }
  // Call the success callback when the user taps Close button in the close success sheet
  func onCardOrderCancelSuccessCloseTap(
  ) {
    hidePopup()
    onCardOrderCancelSuccess(false)
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - API Calls
extension ShippingDetailsViewModel {
  private func cancelCardOrder(
  ) async throws {
    _ = try await cancelCardOrderUseCase.execute(cardID: cardDetail.cardId ?? .empty)
  }
}

// MARK: - Enums
extension ShippingDetailsViewModel {
  enum Navigation {
    case activatePhysicalCard
  }
  
  enum Popup: Identifiable {
    var id: Self {
      self
    }
    
    case delayedCardOrder
    case confirmCardOrderCancel
    case cardOrderCanceledSuccessfully
  }
}
