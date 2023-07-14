import Foundation
import SwiftUI

public class LFStyleGuideColors: LFStyleGuide {
  
  public static var backgroundColor: Color {
    switch appType {
      case .avalanche:
        return Colors.AvalancheColors.background.swiftUIColor
      case .cardano:
        return Colors.CardanoColors.background.swiftUIColor
    }
  }
  
  public static var secondaryBackgroundColor: Color {
    switch appType {
      case .avalanche:
        return Colors.AvalancheColors.secondaryBackground.swiftUIColor
      case .cardano:
        return Colors.CardanoColors.secondaryBackground.swiftUIColor
    }
  }
  
  public static var primaryColor: Color {
    switch appType {
      case .avalanche:
        return Colors.AvalancheColors.primary.swiftUIColor
      case .cardano:
        return Colors.CardanoColors.primary.swiftUIColor
    }
  }
  
  public static var buttonsColor: Color {
    switch appType {
      case .avalanche:
        return Colors.AvalancheColors.buttons.swiftUIColor
      case .cardano:
        return Colors.CardanoColors.buttons.swiftUIColor
    }
  }
  
  public static var pendingColor: Color {
    switch appType {
      case .avalanche:
        return Colors.AvalancheColors.pending.swiftUIColor
      case .cardano:
        return Colors.CardanoColors.pending.swiftUIColor
    }
  }
}
