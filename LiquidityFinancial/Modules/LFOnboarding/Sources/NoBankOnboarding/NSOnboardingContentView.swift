import SwiftUI
import Factory
import LFUtilities
import LFStyleGuide
import AccountData
import UIComponents
import LFRewards
import LFLocalizable
import BaseOnboarding
import Services
import EnvironmentService

public struct NSOnboardingContentView: View {
  @StateObject
  var viewModel = NSOnboardingContentViewModel()
  
  @Injected(\.accountDataManager)
  var accountDataManager
  
  @Injected(\.customerSupportService)
  var customerSupportService
  
  @Injected(\.environmentService)
  var environmentService
  
  var contentViewFactory: NSContentViewFactory
  
  var onRoute: NoBankOnboardingFlowCoordinator.Route?
  
  public init(onRoute: NoBankOnboardingFlowCoordinator.Route? = nil) {
    self.onRoute = onRoute
    self.contentViewFactory = Container.shared.contenViewFactory.resolve()
  }
  
  public var body: some View {
    if let onRoute = onRoute {
      buildContent(for: onRoute)
    } else {
      buildContent(for: viewModel.route)
    }
  }
  
  //swiftlint:disable function_body_length
  @ViewBuilder
  private func buildContent(for route: NoBankOnboardingFlowCoordinator.Route) -> some View {
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
      case .dashboard:
        EmptyView()
      case .forceUpdate(let model):
        contentViewFactory
          .createView(type: .forceUpdate(model))
      case .accountMigration:
        contentViewFactory
          .createView(type: .accountMigration)
      case .noBankPopup:
        contentViewFactory
          .createView(type: .noBankPopup)
      }
    }
    .onAppear {
      customerSupportService.loginUnidentifiedUser()
    }
  }
}
