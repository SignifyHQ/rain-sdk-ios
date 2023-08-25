import UIKit

  // MARK: - UIWindow

public extension UIWindow {
  var visibleViewController: UIViewController? {
    if let rootViewController {
      return UIWindow.getVisibleViewControllerFrom(viewController: rootViewController)
    }
    return nil
  }
  
  private static func getVisibleViewControllerFrom(viewController: UIViewController) -> UIViewController {
    if let navigationController = viewController as? UINavigationController,
       let visibleController = navigationController.visibleViewController {
      return UIWindow.getVisibleViewControllerFrom(viewController: visibleController)
    } else if let tabBarController = viewController as? UITabBarController,
              let selectedTabController = tabBarController.selectedViewController {
      return UIWindow.getVisibleViewControllerFrom(viewController: selectedTabController)
    } else {
      if let presentedViewController = viewController.presentedViewController {
        return UIWindow.getVisibleViewControllerFrom(viewController: presentedViewController)
      } else {
        return viewController
      }
    }
  }
}
