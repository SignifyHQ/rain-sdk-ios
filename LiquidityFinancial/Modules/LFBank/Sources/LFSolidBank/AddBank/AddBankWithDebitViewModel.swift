import CoreNetwork
import Factory
import LFUtilities
import Combine
import UIKit
import LFStyleGuide
import Services
import SwiftUI
import OnboardingData
import SolidData
import SolidDomain
import ExternalFundingData
import AccountService

@MainActor
class AddBankWithDebitViewModel: ObservableObject {
  @LazyInjected(\.vaultService) var vaultService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  
  lazy var solidDebitCardTokenUseCase: SolidDebitCardTokenUseCaseProtocol = {
    SolidDebitCardTokenUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var solidGetLinkedSourcesUseCase: SolidGetLinkedSourcesUseCaseProtocol = {
    SolidGetLinkedSourcesUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var unlinkContactUseCase: SolidUnlinkContactUseCaseProtocol = {
    SolidUnlinkContactUseCase(repository: solidExternalFundingRepository)
  }()
  
  private var fiatAccount: AccountModel?
  
  init() {
    fetchDefaultFiatAccount()
  }
  
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
  private func fetchDefaultFiatAccount() {
    Task {
      do {
        self.fiatAccount = self.accountDataManager.fiatAccounts.first
        if self.fiatAccount == nil {
          let accounts = try await fiatAccountService.getAccounts()
          self.fiatAccount = accounts.first
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func getDebitCardToken() async throws -> DebitCardToken {
    let accountId = fiatAccount?.id ?? .empty
    let tokenResponse = try await solidDebitCardTokenUseCase.execute(accountID: accountId)
    
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
      var isLinkedSuccessful = false
      var solidContactId = ""
      do {
        let debitCardToken = try await getDebitCardToken()
        let debitCardData = try generateDebitCardData()
        solidContactId = debitCardToken.solidContactId
        try await vaultService.addDebitCardToVault(
          debitCardToken: debitCardToken,
          debitCardData: debitCardData
        )
        
        isLinkedSuccessful = true
        analyticsService.track(event: AnalyticsEvent(name: .debitCardConnectionSuccess))
        
        guard let account = fiatAccount else {
          return
        }
        let response = try await self.solidGetLinkedSourcesUseCase.execute(accountID: account.id)
        let contacts = response.compactMap({ (data: SolidContactEntity) -> LinkedSourceContact? in
          guard let type = APISolidContactType(rawValue: data.type) else {
            return nil
          }
          let sourceType: LinkedSourceContactType = type == .externalBank ? .bank : .card
          return LinkedSourceContact(name: data.name, last4: data.last4, sourceType: sourceType, sourceId: data.solidContactId)
        })
        self.externalFundingDataManager.storeLinkedSources(contacts)
        
        self.navigation = .moveMoney
      } catch {
        if !isLinkedSuccessful {
          _ = try? await self.unlinkContactUseCase.execute(id: solidContactId)
        }
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
    case moveMoney
  }
}
