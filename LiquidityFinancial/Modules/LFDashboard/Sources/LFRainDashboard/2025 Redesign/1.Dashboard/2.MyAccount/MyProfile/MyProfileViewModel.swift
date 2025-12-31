import BaseOnboarding
import Foundation
import UIKit
import Factory
import AuthorizationManager

@MainActor
final class MyProfileViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  var name: String {
    if let firstName = accountDataManager.userInfomationData.firstName,
       let lastName = accountDataManager.userInfomationData.lastName {
      return firstName + " " + lastName
    }
    return accountDataManager.userInfomationData.fullName ?? ""
  }

  var email: String {
    accountDataManager.userInfomationData.email ?? ""
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

  var address: String {
    accountDataManager.addressDetail
  }
}
