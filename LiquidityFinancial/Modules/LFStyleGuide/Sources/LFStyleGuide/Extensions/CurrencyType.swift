import Foundation
import SwiftUI
import AccountService

public extension CurrencyType {
  
  var filledImage: Image? {
    switch self {
    case .USD:
      return nil
    case .USDC:
      return GenImages.CommonImages.icUsdc.swiftUIImage
    case .AVAX:
      return GenImages.CommonImages.icAvaxFilled.swiftUIImage
    case .ADA:
      return GenImages.CommonImages.icCardanoFilled.swiftUIImage
    case .DOGE:
      return GenImages.CommonImages.icDogeFilled.swiftUIImage
    }
  }
  
}
