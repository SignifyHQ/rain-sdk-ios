import Foundation
import LFUtilities
import AccountDomain
import SolidData
import SolidDomain
import Factory

class BankStatementViewModel: ObservableObject {
  @Published var status: DataStatus<BankStatementViewModel.UIModel> = .idle
  @Published var navigation: Navigation?
  @Published var toastMessage: String?
  @Published var isLoadingStatement: Bool = false
  
  var showNoStatements = false
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  
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
  
  lazy var getStatementsUseCase: SolidGetAccountStatementItemUseCaseProtocol = {
    SolidGetAccountStatementItemUseCase(repository: solidAccountRepository)
  }()
  
  lazy var getAllStatementsUseCase: SolidGetAccountStatementListUseCaseProtocol = {
    SolidGetAccountStatementListUseCase(repository: solidAccountRepository)
  }()
  
  init() {
  }
  
  func onAppear() {
    switch status {
    case .idle:
      getBankStatements()
    default:
      break
    }
  }
  
  func getBankStatements() {
    Task { @MainActor in
      do {
        status = .loading
        let fiatAccountID = self.accountDataManager.fiatAccountID ?? ""
        let result = try await getAllStatementsUseCase.execute(liquidityAccountId: fiatAccountID)
        let model = result.compactMap({ BankStatementViewModel.UIModel(entity: $0) })
        status = .success(model)
      } catch {
        status = .failure(error)
      }
    }
  }
  
  func selectStatement(_ statement: UIModel) {
    if let url = fetchLocal(statement) {
      navigation = .pdfDocument(statement.title, url)
    } else {
      getStatement(statement: statement)
    }
  }

  private func getStatement(statement: UIModel) {
    Task { @MainActor in
      defer { isLoadingStatement = false }
      isLoadingStatement = true
      do {
        let fiatAccountID = self.accountDataManager.fiatAccountID ?? ""
        let result = try await getStatementsUseCase.execute(
          liquidityAccountId: fiatAccountID,
          fileName: statement.storageName,
          year: statement.year,
          month: statement.month)
        navigation = .pdfDocument(statement.title, result.url)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  private func fetchLocal(_ statement: UIModel) -> URL? {
    do {
      let docURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
      let contents = try FileManager.default.contentsOfDirectory(at: docURL, includingPropertiesForKeys: [.fileResourceTypeKey], options: .skipsHiddenFiles)
      return contents.first(where: { $0.description.contains(statement.storageName) })
    } catch {
      return nil
    }
  }
}

extension BankStatementViewModel {
  enum Navigation {
    case pdfDocument(String, URL)
  }
}

extension BankStatementViewModel {
  struct UIModel: Equatable, Identifiable {
    var id: String = UUID().uuidString
    var month: String
    var year: String
    var createdAt: String
    
    init(entity: SolidAccountStatementListEntity) {
      self.month = entity.month
      self.year = entity.year
      self.createdAt = entity.createdAt
    }
    
    var name: String {
      let calendar = Calendar.current
      var dateComponents = DateComponents()
      dateComponents.year = Int(year)
      dateComponents.month = Int(month)
      let date = calendar.date(from: dateComponents)
      let dateString = date?.formatted(Date.FormatStyle().month(.wide)) ?? "N/A"
      return dateString + " \(year)"
    }
    
    var desc: String {
      guard let date = DateFormatter.serverShort.date(from: createdAt) else {
        return .empty
      }
      return DateFormatter.monthDayYearDisplay.string(from: date)
    }
    
    var storageName: String {
      "BankStatement-\(year)-\(month).pdf"
    }
    
    var title: String {
      if let date = DateFormatter.yearMonth.date(from: identifiable) {
        return DateFormatter.monthYearDisplay.string(from: date)
      }
      return identifiable
    }

    var identifiable: String {
      "\(year)/\(month)"
    }
  }
}
