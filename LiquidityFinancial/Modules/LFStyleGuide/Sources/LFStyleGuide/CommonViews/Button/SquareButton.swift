import SwiftUI
import LFUtilities

public struct SquareButton: View {
  private let image: Image
  private let edgeSize: CGFloat
  private let cornerSize: CGFloat
  private let backgroundColor: Color
  private let action: () -> Void

  public init(
    image: Image,
    edgeSize: CGFloat = 56,
    cornerSize: CGFloat = 9,
    backgroundColor: Color,
    action: @escaping (() -> Void)
  ) {
    self.image = image
    self.edgeSize = edgeSize
    self.cornerSize = cornerSize
    self.backgroundColor = backgroundColor
    self.action = action
  }

  public var body: some View {
    Button(action: action) {
      Rectangle()
        .fill(backgroundColor)
        .frame(width: edgeSize, height: edgeSize)
        .cornerRadius(cornerSize)
        .overlay {
          image.foregroundColor(Colors.label.swiftUIColor)
        }
    }
  }
}
