import Foundation
import LFUtilities
import AccountDomain
import NetspendDomain
import Factory

class BankStatementViewModel: ObservableObject {
  @Published var status: DataStatus<StatementModel> = .idle
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
  
  lazy var getStatementsUseCase: NSGetStatementsUseCaseProtocol = {
    NSGetStatementsUseCase(repository: nsAccountRepository)
  }()
  
  init() {
  }
  
  func onAppear() {
    switch status {
    case .idle:
      getBankStatement()
    default:
      break
    }
  }
  
  func getBankStatement() {
    Task { @MainActor in
      status = .loading
      do {
        let sessionID = accountDataManager.sessionID
        let date = Date()
        let month = self.monthFormatter.string(from: date)
        let year = self.yearFormatter.string(from: date)
        
        let response = try await getStatementsUseCase.execute(
          sessionId: sessionID,
          fromMonth: Constants.Default.statementFromMonth.rawValue,
          fromYear: Constants.Default.statementFromYear.rawValue,
          toMonth: month,
          toYear: year
        )
        status = .success(response)
      } catch {
        status = .failure(error)
      }
    }
  }
  
  func selectStatement(_ item: StatementModel) {
    guard let url = URL(string: item.url) else {
      return
    }
    navigation = .pdfDocument(item.period, url)
  }
  
  func detailFor(statement: StatementModel) -> String {
    guard let date = DateFormatter.serverShort.date(from: statement.createdAt) else {
      return .empty
    }
    return DateFormatter.monthDayYearDisplay.string(from: date)
  }
  
}

extension BankStatementViewModel {
  enum Navigation {
    case pdfDocument(String, URL)
  }
}
