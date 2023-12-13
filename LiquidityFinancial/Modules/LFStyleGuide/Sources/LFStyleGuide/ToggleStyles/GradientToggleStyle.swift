import Foundation
import SwiftUI

public struct GradientToggleStyle: ToggleStyle {
  private let action: (() -> Void)?
  
  public init(didToggleStateChanged: (() -> Void)? = nil) {
    self.action = didToggleStateChanged
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    ZStack {
      RoundedRectangle(cornerRadius: 10)
        .fill(
          configuration.isOn
          ? LinearGradient(
            gradient: Gradient(colors: gradientColor),
            startPoint: .leading,
            endPoint: .trailing
          )
          : LinearGradient(
            gradient: Gradient(colors: [Colors.label.swiftUIColor.opacity(0.5)]),
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .frame(width: 36, height: 20)

      Circle()
        .fill(circleColor)
        .offset(x: configuration.isOn ? 8 : -8, y: 0)
        .gesture(
          DragGesture().onEnded { _ in
            withAnimation {
              configuration.isOn.toggle()
              action?()
            }
          }
        )
    }
    .frame(width: 36, height: 22)
    .onTapGesture {
      withAnimation {
        configuration.isOn.toggle()
        action?()
      }
    }
  }
  
  var gradientColor: [Color] {
    switch LFStyleGuide.target {
    case .CauseCard:
      return [
        Colors.Gradients.Button.gradientButton0.swiftUIColor,
        Colors.Gradients.Button.gradientButton1.swiftUIColor
      ]
    default:
      return [Colors.tertiary.swiftUIColor]
    }
  }
  
  var circleColor: Color {
    switch LFStyleGuide.target {
    case .CauseCard, .PrideCard:
      return Colors.buttons.swiftUIColor
    default:
      return Colors.whiteText.swiftUIColor
    }
  }
}
