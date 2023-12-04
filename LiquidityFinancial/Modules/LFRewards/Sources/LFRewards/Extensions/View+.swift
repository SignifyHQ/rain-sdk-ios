import SwiftUI
import LFStyleGuide

private struct ImageGradientViewModifier: ViewModifier {
  func body(content: Content) -> some View {
    ZStack(alignment: .bottom) {
      content
      ImageGradientView()
    }
  }
}

extension View {
  func applyImageGradient() -> some View {
    modifier(ImageGradientViewModifier())
  }
}

  // MARK: - ImageGradientView

private struct ImageGradientView: View {
  var body: some View {
    Rectangle()
      .fill(gradient)
      .frame(max: .infinity)
  }
  
  private var gradient: LinearGradient {
    .init(colors: [Color.black.opacity(0.0), Color.black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
  }
}
