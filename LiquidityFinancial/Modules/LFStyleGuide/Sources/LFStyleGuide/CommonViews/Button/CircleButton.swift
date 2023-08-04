import SwiftUI

public struct CircleButton: View {
  public init(style: Style) {
    self.style = style
  }
  
  private let style: Style
  
  public var body: some View {
    ZStack {
      Circle()
        .fill(Colors.buttons.swiftUIColor)
        .frame(32.0)
      switch style {
      case .right, .delete, .plus, .xmark:
        if let imageAsset = style.imageAsset {
          imageAsset.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
            .frame(24.0)
        }
      default:
        Image(systemName: style.rawValue)
          .imageScale(.small)
          .foregroundColor(Colors.label.swiftUIColor)
      }
    }
  }
}

  // MARK: - Style

public extension CircleButton {
  enum Style: String, CaseIterable {
    case right
    case left = "chevron.left"
    case chevronUp = "chevron.up"
    case down = "chevron.down"
    case camera
    case xmark
    case delete
    case share = "square.and.arrow.up"
    case refresh = "arrow.counterclockwise"
    case plus = "add"
    
    var imageAsset: ImageAsset? {
      switch self {
      case .right:
        return GenImages.CommonImages.icRightArrow
      case .xmark:
        return GenImages.CommonImages.icXMark
      case .delete:
        return GenImages.CommonImages.icTrash
      case .plus:
        return GenImages.CommonImages.icPlus
      default:
        return nil
      }
    }
  }
}
