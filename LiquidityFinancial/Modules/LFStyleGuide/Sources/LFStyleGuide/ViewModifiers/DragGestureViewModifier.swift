import SwiftUI

public struct DragGestureViewModifier: ViewModifier {
  enum GestureStatus: Equatable {
    case idle
    case started
    case active
    case ended
    case cancelled
  }

  @GestureState private var isDragging: Bool = false
  @State private var gestureState: GestureStatus = .idle
  @State private var currentWidth: Double = 0

  let onUpdate: ((DragGesture.Value) -> Void)?
  let onEnd: ((Double) -> Void)?

  public func body(content: Content) -> some View {
    content
      .gesture(
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
          .updating($isDragging) { _, isDragging, _ in
            isDragging = true
          }
          .onChanged(onDragChanged)
          .onEnded(onDragEnded)
      )
      .onChange(of: gestureState, perform: onGestureStateChanged)
      .onChange(of: isDragging, perform: onDraggingChanged)
  }
}

// MARK: Private extension DragGestureViewModifier

private extension DragGestureViewModifier {
  func onDragChanged(_ value: DragGesture.Value) {
    guard gestureState == .started || gestureState == .active else { return }
    currentWidth = value.translation.width
    onUpdate?(value)
  }

  func onDragEnded(_ value: DragGesture.Value) {
    gestureState = .ended
    onEnd?(value.translation.width)
  }

  func onGestureStateChanged(state: GestureStatus) {
    guard state == .started else { return }
    gestureState = .active
  }

  func onDraggingChanged(value: Bool) {
    if value, gestureState != .started {
      gestureState = .started
    } else if !value, gestureState != .ended {
      gestureState = .cancelled
      onEnd?(currentWidth)
    }
  }
}

// MARK: SwipeCellGesture

public extension View {
  func swipeCellGesture(
    onUpdate: @escaping ((DragGesture.Value) -> Void),
    onEnd: @escaping ((Double) -> Void)
  ) -> some View {
    modifier(
      DragGestureViewModifier(onUpdate: onUpdate, onEnd: onEnd)
    )
  }
}
