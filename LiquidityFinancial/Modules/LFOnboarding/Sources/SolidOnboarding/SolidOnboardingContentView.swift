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
  
  var contentViewFactory: SolidContentViewFactory
  
  var onRoute: SolidOnboardingFlowCoordinator.Route?
  
  public init(onRoute: SolidOnboardingFlowCoordinator.Route? = nil) {
    self.onRoute = onRoute
    self.contentViewFactory = Container.shared.contenViewFactory.resolve(EnvironmentManager())
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
        contentViewFactory
          .createView(type: .initial)
      case .phone:
        contentViewFactory
          .createView(type: .phone)
      case .accountLocked:
        contentViewFactory
          .createView(type: .accountLocked)
      case .selecteReward:
        contentViewFactory
          .createView(type: .selecteReward)
      case .kycReview:
        contentViewFactory
          .createView(type: .kycReview)
      case .dashboard:
        contentViewFactory
          .createView(type: .dashboard)
      case .yourAccount:
        contentViewFactory
          .createView(type: .yourAccount)
      case .information:
        contentViewFactory
          .createView(type: .information)
      case .accountReject:
        contentViewFactory
          .createView(type: .accountReject)
      case .unclear(let string):
        contentViewFactory
          .createView(type: .unclear(string))
      case .forceUpdate(let model):
        contentViewFactory
          .createView(type: .forceUpdate(model))
      case .accountMigration:
        contentViewFactory
          .createView(type: .accountMigration)
      }
    }
    .onAppear {
      customerSupportService.loginUnidentifiedUser()
    }
  }
}
