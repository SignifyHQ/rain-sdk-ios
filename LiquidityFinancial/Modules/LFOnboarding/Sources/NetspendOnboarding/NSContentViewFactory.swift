import Foundation
import LFUtilities
import LFStyleGuide
import LFLocalizable
import SwiftUI
import BaseOnboarding
import Factory
import AccountDomain
import UIComponents

extension Container {
  var contenViewFactory: ParameterFactory<(EnvironmentManager), NSContentViewFactory> {
    self { (environment) in
      NSContentViewFactory(container: self, environment: environment)
    }
  }
}

final class NSContentViewFactory {
  enum ViewType {
    case initial, infomation, address, phone, ssn
    case accountLocked, welcome, kycReview, question(QuestionsEntity)
    case document, documentInReview, zeroHash
    case accountReject, unclear(String)
    case agreement, featureAgreement
  }
  
  let environmentManager: EnvironmentManager
  let flowCoordinator: OnboardingFlowCoordinatorProtocol
  let baseOnboardingNavigation: BaseOnboardingNavigations
  let accountDataManager: AccountDataStorageProtocol
  
  init(
    container: Container,
    environment: EnvironmentManager
  ) {
    baseOnboardingNavigation = container.baseOnboardingNavigations.callAsFunction()
    flowCoordinator = container.nsOnboardingFlowCoordinator.callAsFunction()
    accountDataManager = container.accountDataManager.callAsFunction()
    environmentManager = environment
  }
  
  @MainActor
  func createView(type: ViewType) -> some View {
    switch type {
    case .infomation:
      return AnyView(informationView)
    case .address:
      return AnyView(addressView)
    case .phone:
      return AnyView(phoneNumberView)
    case .ssn:
      return AnyView(enterSSNView)
    case .accountLocked:
      return AnyView(accountLockedView)
    case .welcome:
      return AnyView(welcomeView)
    case .kycReview:
      return AnyView(kycReviewView)
    case .question(let data):
      return AnyView(questionView(data: data))
    case .document:
      return AnyView(documentView)
    case .documentInReview:
      return AnyView(documentInReviewView)
    case .zeroHash:
      return AnyView(enterSSNView)
    case .accountReject:
      return AnyView(accountRejectView)
    case .unclear(let message):
      return AnyView(unclearView(message: message))
    case .agreement:
      return AnyView(agreementView)
    case .featureAgreement:
      return AnyView(featureAgreementView)
    case .initial:
      return AnyView(initialView)
    }
  }
}

private extension NSContentViewFactory {
  @MainActor
  var initialView: some View {
    InitialView()
  }
  
  @MainActor
  var featureAgreementView: some View {
    AgreementView(viewModel: AgreementViewModel(needBufferData: true)) { [weak self] in
      log.info("after accept agreement will fetch missing step and go next:\(self?.flowCoordinator.routeSubject.value ?? .featureAgreement)")
    }
  }
  
  @MainActor
  var agreementView: some View {
    AgreementView(viewModel: AgreementViewModel(needBufferData: true)) { [weak self] in
      log.info("after accept agreement will fetch missing step and go next:\(self?.flowCoordinator.routeSubject.value ?? .agreement)")
    }
  }
  
  @MainActor
  func unclearView(message: String) -> some View {
    KYCStatusView(viewModel: KYCStatusViewModel(state: .common(message)))
  }
  
  @MainActor
  var accountRejectView: some View {
    KYCStatusView(viewModel: KYCStatusViewModel(state: .reject))
  }
  
  @MainActor
  var zeroHashView: some View {
    SetupWalletView()
  }
  
  @MainActor
  var documentInReviewView: some View {
    KYCStatusView(viewModel: KYCStatusViewModel(state: .documentInReview))
  }
  
  @MainActor
  var documentView: some View {
    UploadDocumentView()
  }
  
  @MainActor
  func questionView(data: QuestionsEntity) -> some View {
    QuestionsView(viewModel: QuestionsViewModel(questionList: data))
  }
  
  @MainActor
  var kycReviewView: some View {
    KYCStatusView(viewModel: KYCStatusViewModel(state: .inReview(accountDataManager.userNameDisplay)))
  }
  
  @MainActor
  var accountLockedView: some View {
    AccountLockedView(viewModel: AccountLockedViewModel())
  }
  
  @MainActor
  var welcomeView: some View {
    switch LFUtilities.target {
    case .DogeCard:
      return AnyView(DogeCardWelcomeView(destination: AnyView(agreementView)))
    default:
      return AnyView(WelcomeView())
    }
  }
  
  @MainActor
  var enterSSNView: some View {
    EnterSSNView(
      viewModel: EnterSSNViewModel(isVerifySSN: true),
      onEnterAddress: { [weak self] in
        guard let self else { return }
        self.baseOnboardingNavigation.enterSSNDestinationView = .address(AnyView(self.addressView))
      },
      onEnterPassport: { [weak self] in
        guard let self else { return }
        self.baseOnboardingNavigation.enterSSNDestinationView = .enterPassport(AnyView(self.enterPassportView))
      })
  }
  
  @MainActor
  var enterPassportView: some View {
    EnterPassportView(
      viewModel: EnterPassportViewModel(),
      onEnterAddress: { [weak self] in
        guard let self else { return }
        self.baseOnboardingNavigation.enterSSNDestinationView = .address(AnyView(self.addressView))
      })
  }
  
  @MainActor
  var addressView: some View {
    AddressView()
  }
  
  @MainActor
  var informationView: some View {
    PersonalInformationView(
      viewModel: PersonalInformationViewModel(),
      onEnterSSN: { [weak self] in
        guard let self else { return }
        self.baseOnboardingNavigation.personalInformationDestinationView = .enterSSN(AnyView(self.enterSSNView))
      }
    )
  }
  
  @MainActor
  var phoneNumberView: some View {
    PhoneNumberView(
      viewModel: PhoneNumberViewModel(coordinator: baseOnboardingNavigation)
    )
    .environmentObject(environmentManager)
  }
}
