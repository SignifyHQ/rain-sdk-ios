import SwiftUI

struct FullScreenLoaderMofifier: ViewModifier {
  @Binding var isLoading: Bool
  public var size: CGFloat = 52
  public var backgroundColor: Color = Colors.backgroundPrimary.swiftUIColor
  
  func body(
    content: Content
  ) -> some View {
    ZStack {
      content
      
      if isLoading {
        FullScreenLoaderView(
          size: size,
          backgroundColor: backgroundColor
        )
      }
    }
  }
}

extension View {
  public func withLoadingIndicator(
    isShowing isLoading: Binding<Bool>,
    isOpaque: Bool = true
  ) -> some View {
    self.modifier(
      FullScreenLoaderMofifier(
        isLoading: isLoading,
        backgroundColor: Colors.backgroundPrimary.swiftUIColor.opacity(isOpaque ? 1 : 0.5)
      )
    )
  }
//  
//  public func isLoading(
//    _ isLoading: Binding<Bool>
//  ) -> some View {
//    self.modifier(
//      FullScreenLoaderMofifier(
//        isLoading: isLoading,
//        size: 52,
//        backgroundColor: Colors.baseAppBackground2.swiftUIColor.opacity(0.5)
//      )
//    )
//  }
}
