import Foundation
import UIKit

extension LFUtilities {
  public static var rootViewController: UIViewController? {
    UIApplication
      .shared
      .connectedScenes
      .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
      .first(where: \.isKeyWindow)?
      .rootViewController
  }
  
  public static var visibleViewController: UIViewController? {
    UIApplication
      .shared
      .connectedScenes
      .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
      .first(where: \.isKeyWindow)?
      .visibleViewController
  }
  
  public static func popToRootView() {
    popToRootModalView()
    popToRootNavigationView()
  }
  
  private static func popToRootModalView() {
    rootViewController?.dismiss(animated: true)
  }
  
  private static func popToRootNavigationView() {
    findNavigationController(viewController: rootViewController)?.popToRootViewController(animated: true)
  }
  
  private static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
    guard let viewController = viewController else {
      return nil
    }
    if let navigationController = viewController as? UINavigationController {
      return navigationController
    }
    for childViewController in viewController.children {
      return findNavigationController(viewController: childViewController)
    }
    return nil
  }
}
