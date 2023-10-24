import Foundation
import CoreNetwork
import Factory
import LFUtilities
import Combine
import UIKit
import LFStyleGuide
import LFServices
import SwiftUI
import OnboardingData
import AccountData
import SolidData
import SolidDomain

@MainActor
class AddBankWithDebitViewModel: ObservableObject {
  @LazyInjected(\.vaultService) var vaultService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.solidLinkSourceRepository) var solidLinkSourceRepository
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  
  lazy var getAccountUsecase: SolidGetAccountsUseCaseProtocol = {
    SolidGetAccountsUseCase(repository: solidAccountRepository)
  }()
  
  lazy var solidDebitCardTokenUseCase: SolidDebitCardTokenUseCaseProtocol = {
    SolidDebitCardTokenUseCase(repository: solidLinkSourceRepository)
  }()
  
  init() {}
  
  @Published var loading: Bool = false
  @Published var actionEnabled: Bool = false
  @Published var dateError: String?
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
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
}

// MARK: - API Functions
extension AddBankWithDebitViewModel {
  func getDebitCardToken() async throws -> DebitCardToken {
    let accounts = try await self.getAccountUsecase.execute()
    let tokenResponse = try await solidDebitCardTokenUseCase.execute(accountID: accounts.first?.id ?? .empty)
    
    return DebitCardToken(
      linkToken: tokenResponse.linkToken,
      solidContactId: tokenResponse.solidContactId
    )
  }
}

// MARK: - View Helpers
extension AddBankWithDebitViewModel {
  func performAction() {
    loading = true
    Task { @MainActor in
      defer {
        self.loading = false
      }
      do {
        let debitCardToken = try await getDebitCardToken()
        let debitCardData = try generateDebitCardData()
        try await vaultService.addDebitCardToVault(
          debitCardToken: debitCardToken,
          debitCardData: debitCardData
        )
        
        analyticsService.track(event: AnalyticsEvent(name: .debitCardConnectionSuccess))
        
        // TODO: - Luan Tran will implement storeLinkedSources later
        //        let sessionID = self.accountDataManager.sessionID
        //        async let linkedAccountResponse = self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        //        let linkedSources = try await linkedAccountResponse.linkedSources
        //        self.accountDataManager.storeLinkedSources(linkedSources)
        
        // self.navigation = .verifyCard(cardId: response.cardId)
      } catch {
        analyticsService.track(event: AnalyticsEvent(name: .debitCardFail))
        log.error(error.localizedDescription)
        self.toastMessage = error.localizedDescription
      }
    }
  }

  func dismissPopup() {
  }
}

// MARK: - Private Functions
private extension AddBankWithDebitViewModel {
  func checkAction() {
    actionEnabled = validCard && validCVV && validDate
  }
  
  func generateDebitCardData() throws -> DebitCardModel {
    guard let date = self.dateFormatter.date(from: self.cardExpiryDate.removeWhitespace()) else {
      log.error("Incomplete state")
      throw LiquidityError.invalidData
    }
    
    let month = self.monthFormatter.string(from: date)
    let year = self.yearFormatter.string(from: date)
    
    let address = accountDataManager.userInfomationData
    let vaultAddress = VGSAddressModel(
      addressType: nil,
      line1: address.addressLine1,
      line2: address.addressLine2,
      city: address.city,
      state: address.state,
      country: address.country,
      postalCode: address.postalCode
    )
    
    return DebitCardModel(
      expiryMonth: month,
      expiryYear: year,
      cardNumber: cardNumber.removeWhitespace(),
      cvv: cardCVV,
      address: vaultAddress
    )
  }
}

extension AddBankWithDebitViewModel {
  enum Navigation {
    case verifyCard(cardId: String)
  }
}
