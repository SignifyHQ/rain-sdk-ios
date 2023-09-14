import Foundation
import SwiftUI

extension Color {
  static var random: Color {
    [Color.red, .green, .blue, .black, .pink, .purple, .yellow, .orange].randomElement() ?? .red
  }
}
