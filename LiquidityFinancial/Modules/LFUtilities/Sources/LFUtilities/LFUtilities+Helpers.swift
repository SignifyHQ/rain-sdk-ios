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
}
