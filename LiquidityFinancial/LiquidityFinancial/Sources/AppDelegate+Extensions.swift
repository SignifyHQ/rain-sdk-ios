import Foundation
import UIKit
import LFStyleGuide

extension AppDelegate {
  
  // MARK: Appearance
  func setUpAppearence() {
    setNavigationBarAppearence()
    setRefreshControlAppearence()
  }
  
  private func setNavigationBarAppearence() {
      // TODO: iOS 16 support and up; use .toolbarBackground(Color.background, for: .navigationBar)
    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    appearance.backgroundColor = Colors.background.color
    appearance.shadowColor = .clear
    
    let image = GenImages.CommonImages.icBack.image.withRenderingMode(.alwaysOriginal)
    appearance.setBackIndicatorImage(image, transitionMaskImage: image)
    
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
  
  private func setRefreshControlAppearence() {
    UIRefreshControl.appearance().tintColor = .clear
    UIRefreshControl.appearance().addSubview(RefreshAnimationView.shared)
  }
}

extension UINavigationController {
  // swiftlint:disable override_in_extension
  open override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
      // This is to avoid a SwiftUI bug where on some random cases it adds the `Back` text next to the back button
      // set on setNavigationBarAppearence().
      // We should be able to set this on the UINavigationBar.appearance(), but the topItem is nil at such
    navigationBar.topItem?.backButtonDisplayMode = .minimal
  }
}
