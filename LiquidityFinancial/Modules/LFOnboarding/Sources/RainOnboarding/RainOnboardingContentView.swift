import SwiftUI
import Factory
import LFUtilities
import LFStyleGuide
import AccountData
import BaseOnboarding
import LFLocalizable
import Services

public struct RainOnboardingContentView: View {
  @StateObject var viewModel = RainOnboardingContentViewModel()
  
  private let contentViewFactory: RainContentViewFactory
  private let onRoute: RainOnboardingFlowCoordinator.Route?
  
  public init(onRoute: RainOnboardingFlowCoordinator.Route? = nil) {
    self.onRoute = onRoute
    self.contentViewFactory = Container.shared.contenViewFactory.resolve()
  }
  
  public var body: some View {
    if let onRoute {
      buildContent(for: onRoute)
    } else {
      buildContent(for: viewModel.route)
    }
  }
}

// MARK: - Private View Components
private extension RainOnboardingContentView {
  func buildContent(for route: RainOnboardingFlowCoordinator.Route) -> some View {
    Group {
      switch route {
      case .initial:
        contentViewFactory
          .createView(type: .initial)
      case .phone:
        contentViewFactory
          .createView(type: .phone)
      case .createWallet:
        contentViewFactory
          .createView(
            type: .welcome(RainContentViewFactory.WelcomeType.createWallet)
          )
      case .personalInformation:
        contentViewFactory
          .createView(
            type: .welcome(RainContentViewFactory.WelcomeType.personalInformation)
          )
      case .accountInReview:
        contentViewFactory
          .createView(type: .accountInReview)
      case .dashboard:
        EmptyView()
      case .accountLocked:
        contentViewFactory
          .createView(type: .accountLocked)
      case .accountReject:
        contentViewFactory
          .createView(type: .accountReject)
      case .missingInformation:
        contentViewFactory
          .createView(type: .missingInformation)
      case .identifyVerification:
        contentViewFactory
          .createView(type: .identifyVerification)
      case .unclear(let message):
        contentViewFactory
          .createView(type: .unclear(message))
      case .forceUpdate(let model):
        contentViewFactory
          .createView(type: .forceUpdate(model))
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
  }
}
