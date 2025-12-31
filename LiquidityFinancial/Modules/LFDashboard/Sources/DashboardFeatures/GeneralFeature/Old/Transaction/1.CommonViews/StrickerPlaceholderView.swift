import SwiftUI
import LFStyleGuide

struct StickerPlaceholderView: View {
  private let overlay: Overlay?

  init(overlay: Overlay? = nil) {
    self.overlay = overlay
  }
  
  var body: some View {
    Group {
      switch overlay {
      case .none:
        GenImages.CommonImages.stickerPlaceholder.swiftUIImage
          .resizable()
      case let .gradient(colors):
        GenImages.CommonImages.stickerPlaceholder.swiftUIImage
          .resizable()
          .overlay(Circle().stroke(AngularGradient.primary(colors: colors)))
      case let .linear(color, lineWidth):
        GenImages.CommonImages.stickerPlaceholder.swiftUIImage
          .resizable()
          .overlay(Circle().stroke(color, lineWidth: lineWidth))
      }
    }
  }
}

extension StickerPlaceholderView {
  enum Overlay {
    case gradient([Color])
    case linear(Color, CGFloat)
  }
}
