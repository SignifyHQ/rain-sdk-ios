import SwiftUI
import LFStyleGuide

struct CirclePauseIconView: View {
  let size: Size
  let backgroundColor: Color
  
  init(
    size: Size,
    backgroundColor: Color
  ) {
    self.size = size
    self.backgroundColor = backgroundColor
  }
  
  var body: some View {
    Circle()
    .fill(backgroundColor)
    .frame(size.circleSize)
    .overlay {
      HStack(spacing: size.spacing) {
        RoundedRectangle(cornerRadius: size.roundedRectangleRadius)
          .frame(size.roundedRectangleSize)
          .foregroundColor(backgroundColor.contrastColor())
        RoundedRectangle(cornerRadius: size.roundedRectangleRadius)
          .frame(size.roundedRectangleSize)
          .foregroundColor(backgroundColor.contrastColor())
      }
    }
  }
}

extension CirclePauseIconView {
  enum Size {
    case small
    case medium
    
    var circleSize: CGFloat {
      switch self {
      case .small:
        16
      case .medium:
        32
      }
    }
    
    var roundedRectangleSize: CGSize {
      switch self {
      case .small:
        CGSize(width: 1.2, height: 8)
      case .medium:
        CGSize(width: 2.4, height: 16)
      }
    }
    
    var roundedRectangleRadius: CGFloat {
      switch self {
      case .small:
        10
      case .medium:
        20
      }
    }
    
    var spacing: CGFloat {
      switch self {
      case .small:
        1.6
      case .medium:
        4
      }
    }
  }
}
