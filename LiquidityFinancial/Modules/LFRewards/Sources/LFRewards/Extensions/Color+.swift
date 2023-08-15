import SwiftUI

// swiftlint:disable identifier_name
extension Color {
  
  static var gradientAngular: [Color] = {
    let colors: [Color] = gradientSet(amount: 2, name: "gradientAngular")
    return colors + colors.reversed()
  }()
  
  private static func gradientSet(amount: Int, name: String) -> [Color] {
    var result: [Color] = []
    for i in 0 ..< amount {
      result.append(.init("\(name)\(i)"))
    }
    return result
  }
  
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 3: // RGB (12-bit)
      (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
    case 6: // RGB (24-bit)
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: // ARGB (32-bit)
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (1, 1, 1, 0)
    }
    
    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }
}

extension String {
  var asHexColor: Color? {
    if let hex = nilIfEmpty {
      return .init(hex: hex)
    } else {
      return nil
    }
  }
  
  var nilIfEmpty: String? {
    isEmpty ? nil : self
  }
}
