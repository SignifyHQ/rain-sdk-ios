import SwiftUI
import Factory
import LFUtilities
import LFStyleGuide
import AccountData
import DogeOnboarding

public struct OnboardingContentView: View {
  
  @StateObject
  var viewModel = OnboardingContentViewModel()
  
  @Injected(\.accountDataManager) var accountDataManager
  
  let environmentManager = EnvironmentManager()
  
  public init() {}
  
  public var body: some View {
    buildContent(for: viewModel.route)
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
          DogeCardWelcomeView(destination: AnyView(AgreementView()))
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
      }
    }
  }
}
