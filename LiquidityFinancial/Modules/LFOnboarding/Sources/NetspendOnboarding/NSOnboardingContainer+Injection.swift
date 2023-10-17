import Factory

extension Container {
  public var nsOnboardingFlowCoordinator: Factory<NSOnboardingFlowCoordinator> {
    self {
      NSOnboardingFlowCoordinator()
    }.singleton
  }
}
