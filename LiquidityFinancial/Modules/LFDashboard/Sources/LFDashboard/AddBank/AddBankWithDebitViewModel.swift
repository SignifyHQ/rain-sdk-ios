import Foundation
import LFNetwork
import Factory
import LFUtilities
import Combine
import CardDomain
import UIKit
import LFStyleGuide
import LFServices
import SwiftUI
import OnboardingData
import AccountData
import ExternalFundingData
import ExternalFundingDomain

@MainActor
class AddBankWithDebitViewModel: ObservableObject {
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  
  lazy var externalFundingUseCase: ExternalFundingUseCaseProtocol = {
    ExternalFundingUseCase(repository: externalFundingRepository)
  }()
  
  init() {
    
  }
  
  @Published var loading: Bool = false
  @Published var actionEnabled: Bool = false
  @Published var dateError: String?
  @Published var toastMessage: String?
  
  @Published var cardNumber: String = "" {
    didSet {
      checkAction()
    }
  }

  @Published var cardExpiryDate: String = "" {
    didSet {
      checkAction()
      dateError = nil
    }
  }

  @Published var cardCVV: String = "" {
    didSet {
      checkAction()
    }
  }

  func performAction() {
    loading = true
    Task {
      do {
        guard let session = netspendDataManager.sdkSession else { return }
        let encryptedData = try session.encryptWithJWKSet(
          value: [
            Constants.NetSpendKey.cvv2.rawValue: cardCVV,
            Constants.NetSpendKey.pan.rawValue: cardNumber.removeWhitespace()
          ]
        )
        guard let date = self.dateFormatter.date(from: self.cardExpiryDate.removeWhitespace()) else {
          log.error("Incomplete state")
          throw LiquidityError.invalidData
        }
        let user = try await self.accountRepository.getUser(
          deviceId: UIDevice.current.identifierForVendor?.uuidString ?? ""
        )
        let fullName = "\(user.firstName ?? "") \(user.lastName ?? "")"
        let month = self.monthFormatter.string(from: date)
        let year = self.yearFormatter.string(from: date)
        let postalCode = user.addressEntity?.postalCode ?? ""
        
        let request = ExternalCardParameters(
          month: month,
          year: year,
          nameOnCard: fullName,
          nickname: fullName,
          postalCode: postalCode,
          encryptedData: encryptedData
        )
        _ = try await externalFundingUseCase.set(
          request: request,
          sessionID: accountDataManager.sessionID
        )
        self.loading = false
        // TODO: Will need to navigation the move money screen after successful
      } catch {
        self.loading = false
        log.error(error.localizedDescription)
        self.toastMessage = error.localizedDescription
      }
    }
  }

  func dismissPopup() {
  }

  func handleCardExpiryDate(dateComponents: DateComponents) -> Bool {
    guard let date = Calendar.current.date(from: dateComponents) else { return false }
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/yy"
    self.cardExpiryDate = formatter.string(from: date)
    return true
  }

  private lazy var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/yy"
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  private lazy var monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM"
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()

  private lazy var yearFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "YYYY"
    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()

  private var validDate: Bool {
    guard !cardExpiryDate.isEmpty, let date = dateFormatter.date(from: cardExpiryDate) else {
      return false
    }

    if date < Date() {
      dateError = "Invalid Date"
    }

    return date > Date()
  }

  private var validCard: Bool {
    guard cardNumber.removeWhitespace().count == 16 else {
      return false
    }
    return true
  }

  private var validCVV: Bool {
    guard cardCVV.removeWhitespace().count >= 3 else {
      return false
    }
    return true
  }

  private func checkAction() {
    actionEnabled = validCard && validCVV && validDate
  }
}
