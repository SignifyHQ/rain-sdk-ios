import SwiftUI

public struct LazyView<Content>: View where Content: View {
  private let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public init(_ content: @autoclosure @escaping () -> Content) {
    self.content = content
  }

  public var body: Content {
    content()
  }
}
