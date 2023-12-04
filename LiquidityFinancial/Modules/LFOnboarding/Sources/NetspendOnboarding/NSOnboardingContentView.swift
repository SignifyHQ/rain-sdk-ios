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
  
  var onRoute: NSOnboardingFlowCoordinator.Route?
  
  public init(onRoute: NSOnboardingFlowCoordinator.Route? = nil) {
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
  private func buildContent(for route: NSOnboardingFlowCoordinator.Route) -> some View {
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
      case .question(let questions):
        contentViewFactory
          .createView(type: .question(questions))
      case .document:
        contentViewFactory
          .createView(type: .document)
      case .zeroHash:
        contentViewFactory
          .createView(type: .zeroHash)
      case .information:
        contentViewFactory
          .createView(type: .infomation)
      case .accountReject:
        contentViewFactory
          .createView(type: .accountReject)
      case .unclear(let message):
        contentViewFactory
          .createView(type: .unclear(message))
      case .agreement:
        contentViewFactory
          .createView(type: .agreement)
      case .featureAgreement:
        contentViewFactory
          .createView(type: .featureAgreement)
      case .popTimeUp:
        ZStack {
          timeIsUpPopup
        }
        .frame(max: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
      case .documentInReview:
        contentViewFactory
          .createView(type: .documentInReview)
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
  
  private var timeIsUpPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Kyc.TimeIsUp.title,
      message: LFLocalizable.Kyc.TimeIsUp.message,
      primary: .init(text: LFLocalizable.Button.ContactSupport.title) {
        viewModel.contactSupport()
      },
      secondary: .init(text: LFLocalizable.Button.NotNow.title) {
        viewModel.forcedLogout()
      }
    )
  }
}
