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
          .frame(width: 32, height: 32)
        switch style {
        case .right, .delete, .plus, .xmark:
          Image(style.rawValue)
            .foregroundColor(Colors.label.swiftUIColor)
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
    case right = "rightArrowSmall"
    case left = "chevron.left"
    case up = "chevron.up"
    case down = "chevron.down"
    case camera
    case xmark = "xMark"
    case delete = "trash"
    case share = "square.and.arrow.up"
    case refresh = "arrow.counterclockwise"
    case plus = "add"
  }
}
