import SwiftUI
import UIKit
import LFUtilities
import LFStyleGuide

struct StickerPlaceholderView: View {
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
          .overlay(Circle().stroke(AngularGradient.primary(colors: Color.gradientAngular)))
      case let .linear(color, lineWidth):
        image
          .overlay(Circle().stroke(color, lineWidth: lineWidth))
      }
    }
  }
  
  private let overlay: Overlay?
  
  private var image: some View {
    GenImages.CommonImages.stickerPlaceholder.swiftUIImage
      .resizable()
  }
  
  enum Overlay {
    case gradient
    case linear(Color, CGFloat)
  }
}

#if DEBUG

  // MARK: - StickerPlaceholderView_Previews

struct StickerPlaceholderView_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 20) {
      Text("No overlay")
      StickerPlaceholderView()
        .frame(100)
      
      Text("Gradient overlay")
      StickerPlaceholderView(overlay: .gradient)
        .frame(100)
      
      Text("Linear overlay")
      StickerPlaceholderView(overlay: .linear(.yellow, 4))
        .frame(100)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(ModuleColors.background.swiftUIColor)
  }
}
#endif
