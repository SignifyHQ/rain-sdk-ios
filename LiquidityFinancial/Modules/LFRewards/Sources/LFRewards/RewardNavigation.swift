import Foundation
import Factory
import LFUtilities
import SwiftUI

@MainActor
extension Container {
  
  public var rewardNavigation: Factory<RewardNavigation> {
    self {
      RewardNavigation()
    }.shared
  }
  
}

public final class RewardNavigation {
  
  enum Destination: String {
    case agreementView = "AgreementView"
  }
  
  var services: [String: Any.Type] = [:]
  
  public init() {}
  
  var container: DIContainerAnyView!
  public func setup(container: DIContainerAnyView) {
    self.container = container
  }
}
