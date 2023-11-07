import SwiftUI
import LFUtilities
import Combine
import Factory
import RewardData
import RewardDomain

public protocol RewardFlowCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<RewardFlowCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: RewardFlowCoordinator.Route)
}

public class RewardFlowCoordinator: RewardFlowCoordinatorProtocol {
  
  public enum Route: Hashable, Identifiable {
    
    public static func == (lhs: RewardFlowCoordinator.Route, rhs: RewardFlowCoordinator.Route) -> Bool {
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
  
  @LazyInjected(\.rewardRepository) var rewardRepository
  
  public let routeSubject: CurrentValueSubject<Route, Never>
  
  public init() {
    self.routeSubject = .init(.selectReward)
  }
  
  public func set(route: Route) {
    guard routeSubject.value != route else { return }
    log.info("RewardFlowCoordinator route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  public func routeUser() {

  }
}
