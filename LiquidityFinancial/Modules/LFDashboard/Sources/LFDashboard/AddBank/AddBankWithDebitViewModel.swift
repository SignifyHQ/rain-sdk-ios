import Foundation

@MainActor
class AddBankWithDebitViewModel: ObservableObject {
  
  init() {
    
  }
  
  @Published var actionEnabled: Bool = false
  @Published var dateError: String?
  
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
