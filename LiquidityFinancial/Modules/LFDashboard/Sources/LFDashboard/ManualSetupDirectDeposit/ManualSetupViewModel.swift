import Foundation
import LFUtilities

final class ManualSetupViewModel: ObservableObject {
  @Published var signatureImage: Data?
  @Published var selectedPaychekOption: PaychekOption = .optionFullPayCheck
  @Published var errorMessage: String = ""
  @Published var isSignatureAllowed: Bool = false
  @Published var employerName: String = ""
  @Published var paycheckAmount: String = ""
  @Published var paycheckPercentage: String = ""

  private let numberFormatter = NumberFormatter()
  private let decimalSeparator: String
  let achInformation: ACHModel
  
  var isDisableEmployerNameContinueButton: Bool {
    employerName.trimWhitespacesAndNewlines().isEmpty
  }
  var isDisableAmountContinueButton: Bool {
    paycheckAmount.trimWhitespacesAndNewlines().isEmpty
    || paycheckAmount.trimWhitespacesAndNewlines() == Constants.Default.currencyDefaultAmount.rawValue
  }
  var isDisablePercentageContinueButton: Bool {
    guard let value = numberFormatter.number(from: paycheckPercentage)?.doubleValue else {
      return true
    }
    return value > 100 || value < 0
  }
  
  let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM / dd / yyyy"
    return formatter
  }()
  
  init(achInformation: ACHModel) {
    self.achInformation = achInformation
    decimalSeparator = Locale.current.decimalSeparator ?? Constants.Default.decimalSeparator.rawValue
    numberFormatter.decimalSeparator = decimalSeparator
  }
}

// MARK: - View Helpers
extension ManualSetupViewModel {
  func onChangedPercentage(newValue: String) {
    guard let value = numberFormatter.number(from: newValue)?.doubleValue else {
      paycheckPercentage = ""
      return
    }
    if value > 100 {
      paycheckPercentage = "100"
    } else if value < 0 {
      paycheckPercentage = ""
    } else {
      let splitted = newValue.split(separator: ".")
      if splitted.count > 1 {
        let preDecimal = String(splitted[0])
        var afterDecimal = String(splitted[1])
        if afterDecimal.count > 2 {
          afterDecimal = String(afterDecimal.prefix(2))
        }
        if Int(afterDecimal) == nil {
          paycheckPercentage = "\(preDecimal)\(Locale.current.decimalSeparator)"
        } else {
          paycheckPercentage = "\(preDecimal)\(Locale.current.decimalSeparator)\(afterDecimal)"
        }
      }
    }
  }
}

// MARK: - Types
extension ManualSetupViewModel {
  enum PaychekOption {
    case optionFullPayCheck
    case optionAmount
    case optionPercentage
  }
}
