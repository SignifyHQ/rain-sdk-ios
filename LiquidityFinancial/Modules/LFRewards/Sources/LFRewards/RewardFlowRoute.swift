import Foundation

public enum RewardFlowRoute: Hashable, Identifiable {
  
  public static func == (lhs: RewardFlowRoute, rhs: RewardFlowRoute) -> Bool {
    return lhs.hashValue == rhs.hashValue
  }
  
  case selectReward
  case yourAccount
  
  public var id: String {
    String(describing: self)
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
