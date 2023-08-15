import UIKit

  // MARK: - UIWindow

public extension UIWindow {
  var visibleViewController: UIViewController? {
    if let rootViewController {
      return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
    }
    return nil
  }
  
  private static func getVisibleViewControllerFrom(vc: UIViewController) -> UIViewController {
    if let navigationController = vc as? UINavigationController,
       let visibleController = navigationController.visibleViewController {
      return UIWindow.getVisibleViewControllerFrom(vc: visibleController)
    } else if let tabBarController = vc as? UITabBarController,
              let selectedTabController = tabBarController.selectedViewController {
      return UIWindow.getVisibleViewControllerFrom(vc: selectedTabController)
    } else {
      if let presentedViewController = vc.presentedViewController {
        return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
      } else {
        return vc
      }
    }
  }
}
