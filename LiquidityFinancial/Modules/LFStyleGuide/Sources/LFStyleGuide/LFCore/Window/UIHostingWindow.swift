import SwiftUI

  /// A UIKit window that manages a SwiftUI view hierarchy.
open class UIHostingWindow<Content: View>: UIWindow {
  public init(rootView: Content) {
    hostingController = .init(rootView: rootView)
    
    if let windowScene = UIApplication.sharedOrNil?.firstWindowScene {
      super.init(windowScene: windowScene)
    } else {
      super.init(frame: UIScreen.main.bounds)
    }
    
    backgroundColor = .clear
    rootViewController = hostingController
    accessibilityViewIsModal = true
    rootViewController?.view.backgroundColor = .clear
  }
  
  @available(*, unavailable)
  public required init?(coder _: NSCoder) {
    fatalError("Unexpected call to init(coder:)")
  }
  
    /// A succinct label that identifies the window.
  open var windowLabel: String? {
    get { accessibilityLabel }
    set { accessibilityLabel = newValue }
  }
  
  open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    guard shouldConsumeTouches else {
      return nil
    }

    guard let rootView = rootViewController?.viewIfLoaded,
          let hitView = super.hitTest(point, with: event),
          hitView.isDescendant(of: rootView) else {
      return nil
    }

    return hitView
  }
  
    /// A boolean value indicating whether to passthrough touches that are not
    /// inside the root view.
  public var shouldConsumeTouches = true
  
    // MARK: - Presentation
  
  public var preferredKey = false
  
  public var isPresented: Bool {
    get { !isHidden }
    set { newValue ? show() : hide() }
  }
  
  var rootView: Content {
    get { hostingController.rootView }
    set { hostingController.rootView = newValue }
  }
  
  private let hostingController: HostingController
  
  private func show() {
    if windowScene == nil, let scene = UIApplication.sharedOrNil?.firstWindowScene {
      windowScene = scene
    }
    
    isHidden = false
    
    if preferredKey {
      makeKey()
    }
  }
  
  private func hide() {
    isHidden = true
    windowScene = nil
  }
}

extension UIHostingWindow {
  private final class HostingController: UIHostingController<Content> {
    override func viewDidLoad() {
      super.viewDidLoad()
      view.backgroundColor = .clear
    }
  }
}

public extension UIApplication {
    /// Swift doesn't allow marking parts of Swift framework unavailable for the App
    /// Extension target. This solution let's us overcome this limitation for now.
    ///
    /// `UIApplication.shared` is marked as unavailable for these for App Extension
    /// target.
    ///
    /// https://bugs.swift.org/browse/SR-1226 is still unresolved
    /// and cause problems. It seems that as of now, marking API as unavailable
    /// for extensions in Swift still doesn’t let you compile for App extensions.
  static var sharedOrNil: UIApplication? {
    let sharedApplicationSelector = NSSelectorFromString("sharedApplication")
    
    guard UIApplication.responds(to: sharedApplicationSelector) else {
      return nil
    }
    
    guard let unmanagedSharedApplication = UIApplication.perform(sharedApplicationSelector) else {
      return nil
    }
    
    return unmanagedSharedApplication.takeUnretainedValue() as? UIApplication
  }
  
    /// Iterates through `windows` from top to bottom and returns window matching
    /// the given `keyPaths`.
    ///
    /// - Returns: Returns an optional window object based on attributes options.
    /// - Complexity: O(_n_), where _n_ is the length of the `windows` array.
  func window(_ keyPaths: KeyPath<UIWindow, Bool>...) -> UIWindow? {
    let window = UIApplication.shared.connectedScenes
      .filter({ $0.activationState == .foregroundActive })
      .map({ $0 as? UIWindowScene })
      .compactMap({ $0 })
      .first?.windows
      .reversed()
      .first(keyPaths)
    return window
  }
  
    /// Iterates through app's first currently active scene's `windows` from top to
    /// bottom and returns window matching the given `keyPaths`.
    ///
    /// - Returns: Returns an optional window object based on attributes options.
    /// - Complexity: O(_n_), where _n_ is the length of the `windows` array.
  func sceneWindow(_ keyPaths: KeyPath<UIWindow, Bool>...) -> UIWindow? {
    firstWindowScene?
      .windows
      .lazy
      .reversed()
      .first(keyPaths)
  }
  
    /// Returns the app's first currently active scene's first key window.
  var firstSceneKeyWindow: UIWindow? {
    sceneWindow(\.isKeyWindow)
  }
  
    /// Returns the app's first window scene.
  var firstWindowScene: UIWindowScene? {
    windowScenes.first
  }
  
    /// Returns all of the connected window scenes sorted by from active state to
    /// background state.
  var windowScenes: [UIWindowScene] {
    connectedScenes
      .lazy
      .compactMap { $0 as? UIWindowScene }
      .sorted { $0.activationState.sortOrder < $1.activationState.sortOrder }
  }
  
  // swiftlint: disable first_where
  var keyWindow: UIWindow? {
    let keyWindow = UIApplication.shared.connectedScenes
      .filter({ $0.activationState == .foregroundActive })
      .map({ $0 as? UIWindowScene })
      .compactMap({ $0 })
      .first?.windows
      .filter({ $0.isKeyWindow }).first
    return keyWindow
  }
}

extension Sequence {
    /// Returns the first element of the sequence that satisfies the given
    /// predicate.
    ///
    /// - Parameter keyPaths: A list of `keyPaths` that are used to find an element
    ///   in the sequence.
    /// - Returns: The first element of the sequence that satisfies predicate, or
    ///   `nil` if there is no element that satisfies predicate.
    /// - Complexity: O(_n_), where _n_ is the length of the sequence.
  func first(_ keyPaths: KeyPath<Element, Bool>...) -> Element? {
    first { element in
      keyPaths.allSatisfy {
        element[keyPath: $0]
      }
    }
  }
  
    /// Returns the first element of the sequence that satisfies the given
    /// predicate.
    ///
    /// - Parameter keyPaths: A list of `keyPaths` that are used to find an element
    ///   in the sequence.
    /// - Returns: The first element of the sequence that satisfies predicate, or
    ///   `nil` if there is no element that satisfies predicate.
    /// - Complexity: O(_n_), where _n_ is the length of the sequence.
  func first(_ keyPaths: [KeyPath<Element, Bool>]) -> Element? {
    first { element in
      keyPaths.allSatisfy {
        element[keyPath: $0]
      }
    }
  }
}

private extension UIScene.ActivationState {
  var sortOrder: Int {
    switch self {
    case .foregroundActive:
      return 0
    case .foregroundInactive:
      return 1
    case .background:
      return 2
    case .unattached:
      return 3
    @unknown default:
      return 4
    }
  }
}
