import Foundation
import SwiftUI

public class LFStyleGuideColors: LFStyleGuide {
  
  public static var backgroundColor: Color {
    appType == .avalanche ? Colors.AvalancheColors.avalancheDefaultColor.swiftUIColor : Colors.CardanoColors.cardanoDefaultColor.swiftUIColor
  }
  
}
