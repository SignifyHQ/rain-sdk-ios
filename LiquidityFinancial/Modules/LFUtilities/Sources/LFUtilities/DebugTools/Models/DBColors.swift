import UIKit

// swiftlint:disable all
struct DBColors {
  enum HTTPCode {
    public static let Success = UIColor(hexString: "#297E4CFF") ?? .black
    public static let Redirect = UIColor(hexString: "#3D4140FF") ?? .black
    public static let ClientError = UIColor(hexString: "#D97853FF") ?? .black
    public static let ServerError = UIColor(hexString: "#D32C58FF") ?? .black
    public static let Generic = UIColor(hexString: "#999999FF") ?? .black
  }
}

extension UIColor {
  convenience init?(hexString: String) {
    let r, g, b, a: CGFloat

    if hexString.hasPrefix("#") {
      let start = hexString.index(hexString.startIndex, offsetBy: 1)
      let hexColor = String(hexString[start...])

      if hexColor.count == 8 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xFF00_0000) >> 24) / 255
          g = CGFloat((hexNumber & 0x00FF_0000) >> 16) / 255
          b = CGFloat((hexNumber & 0x0000_FF00) >> 8) / 255
          a = CGFloat(hexNumber & 0x0000_00FF) / 255

          self.init(red: r, green: g, blue: b, alpha: a)
          return
        }
      }
    }

    return nil
  }
}
