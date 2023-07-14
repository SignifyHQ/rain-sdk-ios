import Foundation
import SwiftUI

public class LFStyleGuideImages: LFStyleGuide {

  public static var iconLogo: Image {
    appType == .avalanche ? Images.AvalancheImages.icAvalancheLogo.swiftUIImage : Images.CardanoImages.icCardanoLogo.swiftUIImage
  }
  
}
