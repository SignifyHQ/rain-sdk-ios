import SwiftUI

// MARK: - View Extension

public extension View {
  /// - Parameters:
  ///   - isPresented: A binding to a Boolean value that determines whether to
  ///     present the popup that you create in the modifier's `content` closure.
  ///   - style: The style of the popup.
  ///   - dismissMethods: An option set specifying the dismissal methods for the
  ///     popup.
  ///   - dismissAction: An action to perform when popup dismiss by user
  ///   - content: A closure returning the content of the popup.
  func popup<Content: View>(
    isPresented: Binding<Bool>,
    style: Popup.Style = .alert,
    dismissMethods: Popup.DismissMethods = [.tapOutside],
    dismissAction: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) -> some View {
    modifier(PopupViewModifier(
      isPresented: isPresented,
      style: style,
      dismissMethods: dismissMethods,
      dismissAction: dismissAction,
      content: content
    ))
  }

  /// - Parameters:
  ///   - item: A binding to an optional source of truth for the popup. When
  ///    `item` is non-`nil`, the system passes the item's content to the
  ///     modifier's closure. You display this content in a popup that you create
  ///     that the system displays to the user. If `item` changes, the system
  ///     dismisses the popup and replaces it with a new one using the same
  ///     process.
  ///   - style: The style of the popup.
  ///   - dismissMethods: An option set specifying the dismissal methods for the
  ///     popup.
  ///   - dismissAction: An action to perform when popup dismiss by user
  ///   - content: A closure returning the content of the popup.
  func popup<Item, Content: View>(
    item: Binding<Item?>,
    style: Popup.Style = .alert,
    dismissMethods: Popup.DismissMethods = [.tapOutside],
    dismissAction: (() -> Void)? = nil,
    @ViewBuilder content: @escaping (Item) -> Content
  ) -> some View {
    popup(
      isPresented: .init {
        item.wrappedValue != nil
      } set: { isPresented in
        if !isPresented {
          item.wrappedValue = nil
        }
      },
      style: style,
      dismissMethods: dismissMethods,
      dismissAction: dismissAction,
      content: {
        if let item = item.wrappedValue {
          content(item)
        }
      }
    )
  }
}

// MARK: - PopupViewModifier
private struct PopupViewModifier<PopupContent: View>: ViewModifier {
  init(
    isPresented: Binding<Bool>,
    style: Popup.Style,
    dismissMethods: Popup.DismissMethods,
    dismissAction: (() -> Void)? = nil,
    @ViewBuilder content: @escaping () -> PopupContent
  ) {
    _isPresented = isPresented
    self.style = style
    self.dismissMethods = dismissMethods
    self.dismissAction = dismissAction
    self.content = content
  }
  
  func body(content: Content) -> some View {
    content
      .window(isPresented: $isPresented, style: style.windowStyle) {
        popupContent(dismissAction: dismissAction)
      }
      .onChange(of: isPresented) { isPresented in
        if isPresented {
          setupAutomaticDismissalIfNeeded()
          UIAccessibility.post(notification: .screenChanged, argument: nil)
          UIAccessibility.post(notification: .announcement, argument: "Alert")
        }
      }
  }
  
  @State private var workItem: DispatchWorkItem?
  
  /// A Boolean value that indicates whether the popup associated with this
  /// environment is currently being presented.
  @Binding private var isPresented: Bool
  
  /// A property indicating the popup style.
  private let style: Popup.Style
  
  /// A closure containing the content of popup.
  private let content: () -> PopupContent
  
  /// A property indicating all of the ways popup can be dismissed.
  private let dismissMethods: Popup.DismissMethods
  
  /// An action to perform when popup dismiss by user
  private let dismissAction: (() -> Void)?
  
  private func popupContent(dismissAction: (() -> Void)?) -> some View {
    ZStack {
      if isPresented {
        if style.allowDimming {
          // Host Content Dim Overlay
          Color(white: 0, opacity: 0.20)
            .frame(max: .infinity)
            .ignoresSafeArea()
            .onTapGestureIf(dismissMethods.contains(.tapOutside)) {
              dismissAction?()
              isPresented = false
            }
            .zIndex(1)
            .transition(.opacity)
        }
        
        content()
          .frame(max: .infinity, alignment: style.alignment)
          .ignoresSafeArea(edges: style.ignoresSafeAreaEdges)
          .onTapGestureIf(dismissMethods.contains(.tapInside)) {
            dismissAction?()
            isPresented = false
          }
          .zIndex(2)
          .transition(style.transition)
      }
    }
    .animation(style.animation, value: isPresented)
    .popupDismissAction(
      dismissMethods.contains(.xmark)
      ? PopupDismissAction {
        dismissAction?()
        isPresented = false
      }
      : nil
    )
  }
  
  private func setupAutomaticDismissalIfNeeded() {
    guard let duration = style.dismissAfter else {
      return
    }
    
    workItem?.cancel()
    
    workItem = DispatchWorkItem {
      isPresented = false
    }
    
    if isPresented, let work = workItem {
      DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: work)
    }
  }
}
