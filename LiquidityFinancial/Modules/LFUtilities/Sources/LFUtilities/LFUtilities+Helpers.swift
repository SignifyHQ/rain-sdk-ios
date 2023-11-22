import Foundation
import UIKit
import StoreKit

extension LFUtilities {
  public static func showRatingAlert() {
    if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
      DispatchQueue.main.async {
        SKStoreReviewController.requestReview(in: scene)
      }
    }
  }
  
  public static var deviceId: String {
    UIDevice.current.identifierForVendor?.uuidString ?? .empty
  }
  
  public static var cryptoCurrency: String {
    switch LFUtilities.target {
    case .DogeCard:
      return "Doge"
    case .Avalanche:
      return "AVAX"
    case .Cardano:
      return "ADA"
    default:
      return .empty
    }
  }
  
  public static var cardName: String {
    switch LFUtilities.target {
    case .DogeCard:
      return "Doge"
    case .Avalanche:
      return "Avalanche"
    case .Cardano:
      return "Cardano"
    case .CauseCard:
      return "Cause"
    case .PrideCard:
      return "Pride"
    default:
      return .empty
    }
  }
  
  public static var cardFullName: String {
    switch LFUtilities.target {
    case .DogeCard:
      return "DogeCard"
    case .Avalanche:
      return "Avalanche"
    case .Cardano:
      return "Cardano"
    case .CauseCard:
      return "CauseCard"
    case .PrideCard:
      return "PrideCard"
    default:
      return .empty
    }
  }
  
  public static func getCurrencyForAmount(currency: String, amount: Double, isDecimalRequired: Bool) -> String {
    let decimalAmountString: String
    // let currency = Utility.localizedString(forKey: "currency")
    let currency = currency
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal

    if isDecimalRequired {
      if currency == "$" {
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
      } else {
        formatter.maximumFractionDigits = 3
        formatter.minimumFractionDigits = 3
      }

      formatter.generatesDecimalNumbers = true

      decimalAmountString = String(describing: formatter.string(from: amount) ?? "N/A")

    } else {
      formatter.maximumFractionDigits = 0
      formatter.minimumFractionDigits = 0
      formatter.generatesDecimalNumbers = false

      decimalAmountString = String(describing: formatter.string(from: amount) ?? "N/A")
    }

    return currency == "$" ? "\(currency)\(decimalAmountString)" : "\(decimalAmountString)"
  }
}

public extension NumberFormatter {
    func string(from doubleValue: Double?) -> String? {
        if let doubleValue = doubleValue {
            return string(from: NSNumber(value: doubleValue))
        }
        return nil
    }
}
