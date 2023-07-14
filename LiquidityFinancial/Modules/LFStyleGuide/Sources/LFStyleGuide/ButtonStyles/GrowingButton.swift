import Foundation
import SwiftUI

public struct GrowingButton: ButtonStyle {
  public init() {}
  
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .background(Colors.AvalancheColors.background.swiftUIColor)
      .foregroundStyle(.white)
      .clipShape(Capsule())
      .scaleEffect(configuration.isPressed ? 1.2 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}
