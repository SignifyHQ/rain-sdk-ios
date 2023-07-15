import SwiftUI

public extension View {
  /// Applies modifier if given condition is satisfied.
  ///
  /// - Parameters:
  ///   - condition: The condition that must be `true` in order to apply given
  ///     modifier.
  ///   - modifier: The modifier to apply.
  @ViewBuilder func applyIf<Modifier: ViewModifier>(
    _ condition: Bool, @ViewBuilder modifier: () -> Modifier
  ) -> some View {
    if condition {
      self.modifier(modifier())
    } else {
      self
    }
  }
  
  /// Applies the given transform if the given condition evaluates to `true`.
  ///
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original view or the transformed view if the condition
  ///   is `true`.
  @ViewBuilder func applyIf<Content: View>(
    _ condition: Bool, @ViewBuilder transform: (Self) -> Content
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
  
  /// Applies the given transform if the given condition evaluates to `true`.
  ///
  /// - Parameters:
  ///   - condition: The condition to evaluate.
  ///   - transform: The transform to apply to the source `View`.
  /// - Returns: Either the original view or the transformed view if the condition
  ///   is `true`.
  @ViewBuilder func applyIf<Content: View>(
    _ condition: Binding<Bool>, @ViewBuilder transform: (Self) -> Content
  ) -> some View {
    if condition.wrappedValue {
      transform(self)
    } else {
      self
    }
  }
  
  /// Applies the given transform considering an optional Item.
  @ViewBuilder func apply<Content: View, Item: Hashable>(
    item: Item?, @ViewBuilder transform: (Item?, Self) -> Content
  ) -> some View {
    transform(item, self)
  }
  
  /// Applies the given transform considering a Bool value.
  @ViewBuilder func apply<Content: View>(
    condition: Bool, @ViewBuilder transform: (Bool, Self) -> Content
  ) -> some View {
    transform(condition, self)
  }
}
