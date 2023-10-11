import SwiftUI
import Factory
import LFUtilities
import LFStyleGuide
import AccountData
import DogeOnboarding
import LFRewards
import LFLocalizable

public struct OnboardingContentView: View {
  
  @StateObject
  var viewModel = OnboardingContentViewModel()
  
  @Injected(\.accountDataManager) var accountDataManager
  @Injected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.rewardFlowCoordinator) var rewardFlowCoordinator
  
  let environmentManager = EnvironmentManager()
  
  var onRoute: OnboardingFlowCoordinator.Route?
  
  public init(onRoute: OnboardingFlowCoordinator.Route? = nil) {
    self.onRoute = onRoute
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
  private func buildContent(for route: OnboardingFlowCoordinator.Route) -> some View {
    Group {
      switch route {
      case .initial:
        InitialView()
      case .phone:
        PhoneNumberView()
        .environmentObject(environmentManager)
      case .accountLocked:
        AccountLockedView()
      case .welcome:
        switch LFUtilities.target {
        case .DogeCard:
          DogeCardWelcomeView(destination: AnyView(AgreementView(viewModel: AgreementViewModel())))
        case .CauseCard, .PrideCard:
          SelectRewardsView()
        default:
          WelcomeView()
        }
      case .kycReview:
        KYCStatusView(viewModel: KYCStatusViewModel(state: .inReview(accountDataManager.userNameDisplay)))
      case .dashboard:
        EmptyView()
      case .question(let questions):
        QuestionsView(viewModel: QuestionsViewModel(questionList: questions))
      case .document:
        UploadDocumentView()
      case .zeroHash:
        SetupWalletView()
      case .information:
        PersonalInformationView()
      case .accountReject:
        KYCStatusView(viewModel: KYCStatusViewModel(state: .reject))
      case .unclear(let message):
        KYCStatusView(viewModel: KYCStatusViewModel(state: .common(message)))
      case .agreement, .featureAgreement:
        AgreementView(viewModel: AgreementViewModel()) {
          log.info("after accept agreement will fetch missing step and go next:\(viewModel.onboardingFlowCoordinator.routeSubject.value) ")
        }
      case .popTimeUp:
        ZStack {
          timeIsUpPopup
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
      case .documentInReview:
        KYCStatusView(viewModel: KYCStatusViewModel(state: .documentInReview))
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
