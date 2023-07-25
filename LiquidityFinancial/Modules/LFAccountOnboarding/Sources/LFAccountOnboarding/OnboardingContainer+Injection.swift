import Factory

extension Container {
  public var onboardingFlowCoordinator: Factory<OnboardingFlowCoordinatorProtocol> {
    self {
      OnboardingFlowCoordinator()
    }.singleton
  }
}
