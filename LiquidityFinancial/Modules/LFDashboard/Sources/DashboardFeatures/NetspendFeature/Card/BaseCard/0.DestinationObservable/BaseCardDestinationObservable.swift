import Foundation
import Factory
import SwiftUI

public extension Container {
    var baseCardDestinationObservable: Factory<BaseCardDestinationObservable> {
      self { BaseCardDestinationObservable() }.singleton
    }
}

public final class BaseCardDestinationObservable: ObservableObject {
  public init() {}
  
  @Published public var listCardsDestinationObservable = ListCardsDestinationObservable(navigation: nil, sheet: nil, fullScreen: nil)
  @Published public var orderPhysicalCardDestinationObservable = OrderPhysicalCardDestinationObservable(navigation: nil)
}
