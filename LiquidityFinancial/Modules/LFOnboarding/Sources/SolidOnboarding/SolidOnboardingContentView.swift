import SwiftUI
import Factory
import LFUtilities
import LFStyleGuide
import AccountData
import UIComponents
import LFRewards
import LFLocalizable
import BaseOnboarding

public struct SolidOnboardingContentView: View {
  @StateObject
  var viewModel = SolidOnboardingContentViewModel()
  
  @Injected(\.accountDataManager)
  var accountDataManager
  
  @Injected(\.customerSupportService)
  var customerSupportService
  
  @LazyInjected(\.rewardFlowCoordinator)
  var rewardFlowCoordinator
  
  var contenViewFactory: SolidContentViewFactory
  
  var onRoute: SolidOnboardingFlowCoordinator.Route?
  
  public init(onRoute: SolidOnboardingFlowCoordinator.Route? = nil) {
    self.onRoute = onRoute
    self.contenViewFactory = Container.shared.contenViewFactory.resolve(EnvironmentManager())
  }
  
  public var body: some View {
    if let onRoute = onRoute {
      buildContent(for: onRoute)
    } else {
      buildContent(for: viewModel.route)
    }
  }
  
  @ViewBuilder
  private func buildContent(for route: SolidOnboardingFlowCoordinator.Route) -> some View {
    Group {
      switch route {
      case .initial:
        contenViewFactory
          .createView(type: .initial)
      case .phone:
        contenViewFactory
          .createView(type: .phone)
      case .accountLocked:
        contenViewFactory
          .createView(type: .accountLocked)
      case .selecteReward:
        contenViewFactory
          .createView(type: .selecteReward)
      case .kycReview:
        contenViewFactory
          .createView(type: .kycReview)
      case .dashboard:
        contenViewFactory
          .createView(type: .dashboard)
      case .yourAccount:
        contenViewFactory
          .createView(type: .yourAccount)
      case .information:
        contenViewFactory
          .createView(type: .information)
      case .accountReject:
        contenViewFactory
          .createView(type: .accountReject)
      case .unclear(let string):
        contenViewFactory
          .createView(type: .unclear(string))
      }
    }
    .onAppear {
      customerSupportService.loginUnidentifiedUser()
    }
  }
}
