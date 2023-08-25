import SwiftUI
import Factory
import LFUtilities
import LFStyleGuide
import AccountData
import DogeOnboarding
import LFRewards

public struct OnboardingContentView: View {
  
  @StateObject
  var viewModel = OnboardingContentViewModel()
  
  @Injected(\.accountDataManager) var accountDataManager
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
  
  @ViewBuilder
  private func buildContent(for route: OnboardingFlowCoordinator.Route) -> some View {
    Group {
      switch route {
      case .initial:
        InitialView()
      case .phone:
        PhoneNumberView()
        .environmentObject(environmentManager)
      case .welcome:
        switch LFUtilities.target {
        case .DogeCard:
          DogeCardWelcomeView(destination: AnyView(AgreementView(viewModel: AgreementViewModel())))
        case .CauseCard:
          SelectRewardsView(destination: AnyView(AgreementView(viewModel: AgreementViewModel())))
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
      }
    }
  }
}
