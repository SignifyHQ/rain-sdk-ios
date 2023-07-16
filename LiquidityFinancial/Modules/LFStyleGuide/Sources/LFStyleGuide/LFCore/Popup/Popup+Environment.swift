import SwiftUI

// MARK: - Keys

extension EnvironmentValues {
  private struct PopupCornerRadiusKey: EnvironmentKey {
    static var defaultValue: CGFloat = 16
  }

  private struct PopupPreferredWidthKey: EnvironmentKey {
    static var defaultValue: CGFloat = Device.screen.bounds.size.width - 60
  }

  private struct PopupTextAlignmentKey: EnvironmentKey {
    static var defaultValue: TextAlignment = .center
  }

  private struct PopupDismissActionKey: EnvironmentKey {
    static var defaultValue: PopupDismissAction?
  }
}

// MARK: - Values

extension EnvironmentValues {
  var popupCornerRadius: CGFloat {
    get { self[PopupCornerRadiusKey.self] }
    set { self[PopupCornerRadiusKey.self] = newValue }
  }

  var popupPreferredWidth: CGFloat {
    get { self[PopupPreferredWidthKey.self] }
    set { self[PopupPreferredWidthKey.self] = newValue }
  }

  var popupTextAlignment: TextAlignment {
    get { self[PopupTextAlignmentKey.self] }
    set { self[PopupTextAlignmentKey.self] = newValue }
  }

  var popupDismissAction: PopupDismissAction? {
    get { self[PopupDismissActionKey.self] }
    set { self[PopupDismissActionKey.self] = newValue }
  }
}

// MARK: - View Helpers

public extension View {
  /// Clips popups within the environment to its bounding frame, with the
  /// specified corner radius.
  func popupCornerRadius(_ cornerRadius: CGFloat) -> some View {
    environment(\.popupCornerRadius, cornerRadius)
  }

  /// Sets popups width within the environment to the specified value.
  func popupPreferredWidth(_ width: CGFloat) -> some View {
    environment(\.popupPreferredWidth, width)
  }

  /// Sets the alignment of popups text within the environment to the specified
  /// value.
  func popupTextAlignment(_ textAlignment: TextAlignment) -> some View {
    environment(\.popupTextAlignment, textAlignment)
  }

  /// Sets the dismiss action of popups within the environment to the specified
  /// value.
  internal func popupDismissAction(_ action: PopupDismissAction?) -> some View {
    environment(\.popupDismissAction, action)
  }
}

// MARK: - PopupDismissAction

/// Provides functionality for dismissing a popup.
struct PopupDismissAction {
  private let dismiss: () -> Void

  init(dismiss: @escaping () -> Void) {
    self.dismiss = dismiss
  }

  func callAsFunction() {
    dismiss()
  }
}
