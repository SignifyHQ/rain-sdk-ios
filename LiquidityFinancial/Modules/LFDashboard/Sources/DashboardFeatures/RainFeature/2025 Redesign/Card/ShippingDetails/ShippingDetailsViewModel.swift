import BaseOnboarding
import Factory
import Foundation

final class ShippingDetailsViewModel: ObservableObject {
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
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
  
  var isShowingShippingDetailPost30Days: Bool {
    guard
      let createdAt = cardDetail.shippingAddress?.createdAtDate
    else { return false }
    
    return Date().timeIntervalSince(createdAt) > 30 * 24 * 60 * 60 // 30 days
  }
  
  let cardDetail: CardDetail
  
  init(cardDetail: CardDetail) {
    self.cardDetail = cardDetail
  }
}

// MARK: Enums
extension ShippingDetailsViewModel {
  enum Navigation {
    case activatePhysicalCard
  }
  
  enum Popup: Identifiable {
    var id: Self {
      self
    }
    
    case delayedCardOrder
  }
}
