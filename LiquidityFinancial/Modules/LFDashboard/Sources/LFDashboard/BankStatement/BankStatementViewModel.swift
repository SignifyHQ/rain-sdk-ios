import Foundation
import LFUtilities
import AccountDomain
import NetSpendDomain
import Factory

class BankStatementViewModel: ObservableObject {
  @Published var statements = [StatementModel]()
  @Published var isLoading = false
  @Published var navigation: Navigation?
  @Published var toastMessage: String?
  var showNoStatements = false
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.nsAccountRepository) var nsAccountRepository
  
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
  
  init() {
    getBankStatement()
  }
  
  func onAppear() {
  }
 
  func getBankStatement() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let sessionID = accountDataManager.sessionID
        let date = Date()
        let month = self.monthFormatter.string(from: date)
        let year = self.yearFormatter.string(from: date)
        
        let response = try await nsAccountRepository.getStatements(
          sessionId: sessionID,
          fromMonth: Constants.Default.statementFromMonth.rawValue,
          fromYear: Constants.Default.statementFromYear.rawValue,
          toMonth: month,
          toYear: year
        )
        self.statements = response
      } catch {
        log.error(error)
      }
    }
  }
  
  func selectStatement(_ item: StatementModel) {
    guard let url = URL(string: item.url) else {
      return
    }
    navigation = .pdfDocument(item.period, url)
  }
  
}

extension BankStatementViewModel {
  enum Navigation {
    case pdfDocument(String, URL)
  }
}
