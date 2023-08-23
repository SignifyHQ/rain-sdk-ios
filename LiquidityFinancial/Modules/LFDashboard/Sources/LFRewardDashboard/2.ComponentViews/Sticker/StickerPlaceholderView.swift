import SwiftUI
import LFStyleGuide

struct StickerPlaceholderView: View {
  private let overlay: Overlay?
  private var image: some View {
    GenImages.CommonImages.stickerPlaceholder.swiftUIImage
      .resizable()
  }
  
  init(overlay: Overlay? = nil) {
    self.overlay = overlay
  }
  
  var body: some View {
    Group {
      switch overlay {
      case .none:
        image
      case .gradient:
        image
          .overlay(Circle().stroke(Colors.primary.swiftUIColor))
      case let .linear(color, lineWidth):
        image
          .overlay(Circle().stroke(color, lineWidth: lineWidth))
      }
    }
  }
}

// MARK: - Types
extension StickerPlaceholderView {
  enum Overlay {
    case gradient
    case linear(Color, CGFloat)
  }
}
