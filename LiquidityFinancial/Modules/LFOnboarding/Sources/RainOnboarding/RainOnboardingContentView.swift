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
      case .accountLocked:
        contentViewFactory
          .createView(type: .accountLocked)
      case .welcome:
        contentViewFactory
          .createView(type: .welcome)
      case .kycReview:
        contentViewFactory
          .createView(type: .kycReview)
      case .dashboard:
        EmptyView()
      case .information:
        contentViewFactory
          .createView(type: .infomation)
      case .accountReject:
        contentViewFactory
          .createView(type: .accountReject)
      case .unclear(let message):
        contentViewFactory
          .createView(type: .unclear(message))
      case .popTimeUp:
        ZStack {
          timeIsUpPopup
        }
        .frame(max: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
      case .forceUpdate(let model):
        contentViewFactory
          .createView(type: .forceUpdate(model))
      }
    }
    .onAppear {
      viewModel.onAppear()
    }
  }
  
  var timeIsUpPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Kyc.TimeIsUp.title,
      message: L10N.Common.Kyc.TimeIsUp.message,
      primary: .init(text: L10N.Common.Button.ContactSupport.title) {
        viewModel.contactSupport()
      },
      secondary: .init(text: L10N.Common.Button.NotNow.title) {
        viewModel.forcedLogout()
      }
    )
  }
}
