import Foundation
import LFStyleGuide
// swiftlint:disable force_unwrapping

extension AppDelegate {
  
  func setupConfigs() {
    setupStyleGuideConfig()
  }
  
}

private extension AppDelegate {
  func setupStyleGuideConfig() {
    LFStyleGuide.initial(target: Bundle.main.executableURL!.lastPathComponent)
  }
}
