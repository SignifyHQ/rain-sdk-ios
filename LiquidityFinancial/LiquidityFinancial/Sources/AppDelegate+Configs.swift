import Foundation
import LFStyleGuide
import DataUtilities

// swiftlint:disable force_unwrapping

extension AppDelegate {
  
  func setupConfigs() {
    setupStyleGuideConfig()
    setupDataUtilitiesConfig()
  }
  
}

private extension AppDelegate {
  func setupStyleGuideConfig() {
    LFStyleGuide.initial(target: Bundle.main.executableURL!.lastPathComponent)
  }
  
  func setupDataUtilitiesConfig() {
    DataUtilities.initial(target: Bundle.main.executableURL!.lastPathComponent)
  }
}
