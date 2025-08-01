import SwiftUICore
import UIKit

extension Image {
  static public func fromBase64(
    _ base64: String?
  ) -> Image? {
    guard let base64,
          let data = Data(base64Encoded: base64),
          let uiImage = UIImage(data: data)
    else {
      return nil
    }
    
    return Image(uiImage: uiImage)
  }
}
