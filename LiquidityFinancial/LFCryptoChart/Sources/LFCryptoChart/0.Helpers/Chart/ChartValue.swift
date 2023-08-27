import SwiftUI

/// Representation of a single data point in a chart that is being observed
public class ChartValue: ObservableObject {
  @Published public var currentValue: Double = 0
  @Published public var interactionInProgress: Bool = false
  // Default of the index is -1 to prevent the unexpected select item
  @Published public var index: Int = -1

  public init(currentValue: Double = 0, interactionInProgress: Bool = false) {
    self.currentValue = currentValue
    self.interactionInProgress = interactionInProgress
  }
}
