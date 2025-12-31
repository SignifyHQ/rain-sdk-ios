import SwiftUI

struct ToastModifier: ViewModifier {
  @Binding var toastData: ToastData?
  var alignment: Alignment = .top
  
  private let toastAnimation = Animation.interactiveSpring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.2)
  
  func body(
    content: Content
  ) -> some View {
    ZStack(
      alignment: alignment
    ) {
      content
      
      if let data = toastData {
        DefaultToastView(
          for: data.type,
          toastTitle: data.title,
          toastBody: data.body
        )
        .transition(
          .asymmetric(
            insertion: AnyTransition.move(
              edge: alignment == .top ? .top : .bottom
            )
            .combined(
              with: .opacity
            )
            .combined(
              with: .scale(scale: 0.95)
            ),
            removal: AnyTransition.opacity.combined(
              with: .scale(scale: 0.9)
            )
          )
        )
        .onAppear {
          dismissToastAfterDelay(data.duration)
        }
        .onTapGesture {
          withAnimation {
            toastData = nil
          }
        }
      }
    }
    .animation(
      toastAnimation,
      value: toastData != nil
    )
  }
  
  private func dismissToastAfterDelay(
    _ duration: TimeInterval
  ) {
    Task {
      guard toastData != nil
      else {
        return
      }
      
      try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
      
      await MainActor.run {
        if toastData != nil {
          withAnimation(toastAnimation) {
            toastData = nil
          }
        }
      }
    }
  }
}

extension View {
  public func toast(
    data toastData: Binding<ToastData?>,
    alignment: Alignment = .top
  ) -> some View {
    self.modifier(ToastModifier(toastData: toastData, alignment: alignment))
  }
}
