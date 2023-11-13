import SwiftUI
import Factory
import LFUtilities
import LFStyleGuide
import AccountData
import UIComponents
import LFRewards
import LFLocalizable
import BaseOnboarding

public struct NSOnboardingContentView: View {
  @StateObject
  var viewModel = NSOnboardingContentViewModel()
  
  @Injected(\.accountDataManager)
  var accountDataManager
  
  @Injected(\.customerSupportService)
  var customerSupportService
  
  var contenViewFactory: NSContentViewFactory
  
  var onRoute: NSOnboardingFlowCoordinator.Route?
  
  public init(onRoute: NSOnboardingFlowCoordinator.Route? = nil) {
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
  
  //swiftlint:disable function_body_length
  @ViewBuilder
  private func buildContent(for route: NSOnboardingFlowCoordinator.Route) -> some View {
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
      case .welcome:
        contenViewFactory
          .createView(type: .welcome)
      case .kycReview:
        contenViewFactory
          .createView(type: .kycReview)
      case .dashboard:
        EmptyView()
      case .question(let questions):
        contenViewFactory
          .createView(type: .question(questions))
      case .document:
        contenViewFactory
          .createView(type: .document)
      case .zeroHash:
        contenViewFactory
          .createView(type: .zeroHash)
      case .information:
        contenViewFactory
          .createView(type: .infomation)
      case .accountReject:
        contenViewFactory
          .createView(type: .accountReject)
      case .unclear(let message):
        contenViewFactory
          .createView(type: .unclear(message))
      case .agreement:
        contenViewFactory
          .createView(type: .agreement)
      case .featureAgreement:
        contenViewFactory
          .createView(type: .featureAgreement)
      case .popTimeUp:
        ZStack {
          timeIsUpPopup
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
      case .documentInReview:
        contenViewFactory
          .createView(type: .documentInReview)
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
