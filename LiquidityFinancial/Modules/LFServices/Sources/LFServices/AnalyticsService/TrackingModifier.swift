import SwiftUI
import Factory

// MARK: - TrackingModifier

/// A view modifier that tracks analytics events
struct TrackingModifier: ViewModifier {
  @Injected(\.analyticsService) var analyticsService
  
  let name: String
  
  func body(content: Content) -> some View {
    content
      .onAppear {
        analyticsService.track(screen: name, appear: true)
      }
      .onDisappear {
        analyticsService.track(screen: name, appear: false)
      }
  }
}

public extension View {
  /// Track all analytics events for the given groups using the provided service
  func track(name: String) -> some View {
    let modifier = TrackingModifier(name: name)
    return self.modifier(modifier)
  }
}
