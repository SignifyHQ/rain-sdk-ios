import Factory

extension Container {
  public var rewardFlowCoordinator: Factory<RewardFlowCoordinatorProtocol> {
    self {
      RewardFlowCoordinator()
    }.singleton
  }
}
