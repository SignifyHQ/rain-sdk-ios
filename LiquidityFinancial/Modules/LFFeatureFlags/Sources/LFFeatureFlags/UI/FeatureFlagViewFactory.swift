import Foundation
import SwiftUI

struct FeatureFlagViewFactory {
  
  let id: String
  let group: String?
  let makeView: () -> AnyView
  
  init<F: LFFeatureFlagType>(_ flag: F) {
    id = flag.id
    group = flag.group
    makeView = { AnyView(flag.view) }
  }
}
