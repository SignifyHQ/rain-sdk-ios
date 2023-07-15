import SwiftUI

public extension View {
  /// Navigates to the destination when `isActive` is `true`.
  func navigationLink<Destination: View>(isActive: Binding<Bool>, @ViewBuilder destination: @escaping () -> Destination) -> some View {
    background(
      NavigationLink(destination: LazyView { destination() }, isActive: isActive, label: EmptyView.init)
        .hidden()
    )
  }
  
  /// Navigates to the destination determined by the `item` when such binding is available.
  func navigationLink<Item, Destination: View>(item: Binding<Item?>, @ViewBuilder destination: @escaping (Item) -> Destination) -> some View {
    navigationLink(
      isActive: Binding(
        get: { item.wrappedValue != nil },
        set: { if !$0 { item.wrappedValue = nil } }
      ),
      destination: {
        if let item = item.wrappedValue {
          destination(item)
        }
      }
    )
  }
  
  /// Navigates to the destination when `item` value equalsthe given tag.
  func navigationLink<Item: Hashable, Destination: View>(item: Binding<Item?>, tag: Item, @ViewBuilder destination: @escaping () -> Destination) -> some View {
    navigationLink(
      isActive: Binding(
        get: { item.wrappedValue == tag },
        set: { if !$0 { item.wrappedValue = nil } }
      ),
      destination: {
        destination()
      }
    )
  }
  
  /// Embeds the current view inside a `NavigationView` with `.stack` style.
  func embedInNavigation() -> some View {
    NavigationView {
      self
    }
    .navigationViewStyle(.stack)
  }
}

// MARK: - LazyView
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
