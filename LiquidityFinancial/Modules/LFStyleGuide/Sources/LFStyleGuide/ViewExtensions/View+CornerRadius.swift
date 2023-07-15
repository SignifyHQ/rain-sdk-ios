import SwiftUI

public extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedRectangleCorner(radius: radius, corners: corners))
  }
  
  func cornerRadius(_ radius: CGFloat, style: RoundedCornerStyle) -> some View {
    clipShape(RoundedRectangle(cornerRadius: radius, style: style))
  }
}

// MARK: - RoundedRectangleCorner
public struct RoundedRectangleCorner: Shape {
  private let radius: CGFloat
  private let corners: UIRectCorner
  
  public init(radius: CGFloat, corners: UIRectCorner) {
    self.radius = radius
    self.corners = corners
  }
  
  /// Describes this shape as a path within a rectangular frame of reference.
  /// - Parameter rect: The frame of reference for describing this shape.
  /// - Returns: A path that describes this shape.
  public func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(radius)
    )
    return Path(path.cgPath)
  }
}

public extension CGSize {
  init(_ value: CGFloat) {
    self = CGSize(width: value, height: value)
  }
}
