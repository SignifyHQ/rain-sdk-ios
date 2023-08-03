import SwiftUI

extension View {
  @ViewBuilder
  func hidden(_ shouldHide: Bool) -> some View {
    switch shouldHide {
    case true: hidden()
    case false: self
    }
  }
}

public extension View {
  func navigationDestination<Item, Destination: View>(
    binding: Binding<Item?>,
    @ViewBuilder destination: @escaping (Item) -> Destination
  ) -> some View {
    self.modifier(NavigationStackModifier(item: binding, destination: destination))
  }
}

public extension Binding where Value == Bool {
  init<Wrapped>(bindingOptional: Binding<Wrapped?>) {
    self.init(
      get: {
        bindingOptional.wrappedValue != nil
      },
      set: { newValue in
        guard newValue == false else { return }
        
          /// We only handle `false` booleans to set our optional to `nil`
          /// as we can't handle `true` for restoring the previous value.
        bindingOptional.wrappedValue = nil
      }
    )
  }
}

extension Binding {
  public func mappedToBool<Wrapped>() -> Binding<Bool> where Value == Wrapped? {
    return Binding<Bool>(bindingOptional: self)
  }
}

struct NavigationStackModifier<Item, Destination: View>: ViewModifier {
  let item: Binding<Item?>
  let destination: (Item) -> Destination
  
  func body(content: Content) -> some View {
    content.background(NavigationLink(isActive: item.mappedToBool()) {
      if let item = item.wrappedValue {
        destination(item)
      } else {
        EmptyView()
      }
    } label: {
      EmptyView()
    })
  }
}
