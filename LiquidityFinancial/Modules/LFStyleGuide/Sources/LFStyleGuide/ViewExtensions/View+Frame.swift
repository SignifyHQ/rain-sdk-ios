import SwiftUI

public extension View {
  /// Positions this view within an invisible frame with the specified size.
  ///
  /// Use this method to specify a fixed size for a view's width, height, or
  /// both. If you only specify one of the dimensions, the resulting view
  /// assumes this view's sizing behavior in the other dimension.
  func frame(_ size: CGFloat?, alignment: Alignment = .center) -> some View {
    frame(width: size, height: size, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame with the specified size.
  ///
  /// Use this method to specify a fixed size for a view's width and height
  func frame(_ size: CGSize, alignment: Alignment = .center) -> some View {
    frame(width: size.width, height: size.height, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame having the specified size
  /// constraints.
  ///
  /// If no maximum constraint is specified, the frame adopts the sizing behavior
  /// of its child. If a maximum constraint is specified and the size proposed for
  /// the frame by the parent is greater than the size of this view, the proposed
  /// size, clamped to that maximum.
  ///
  func frame(max: CGFloat?, alignment: Alignment = .center) -> some View {
    frame(maxWidth: max, maxHeight: max, alignment: alignment)
  }
  
  /// Positions this view within an invisible frame having the specified size
  /// constraints.
  ///
  /// If no minimum constraint is specified, the frame adopts the sizing behavior
  /// of its child. If a minimum constraint is specified and the size proposed for
  /// the frame by the parent is less than the size of this view, the proposed
  /// size, clamped to that minimum.
  func frame(min: CGFloat?, alignment: Alignment = .center) -> some View {
    frame(minWidth: min, minHeight: min, alignment: alignment)
  }
}
