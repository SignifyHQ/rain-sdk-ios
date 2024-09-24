import Foundation
import SwiftUI
import Factory
import NetSpendData
import NetspendDomain
import LFUtilities
import Combine
import NetspendSdk
import FraudForce
import OnboardingData
import Services

final class WelcomeViewModel: ObservableObject {
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.authorizationManager) var authorizationManager

  @Published var isPushToNextStep: Bool = false
  
  init() {}
}

// MARK: - View Handler
extension WelcomeViewModel {
  func onAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .viewsWelcome))
  }
  
  func onClickedContinueButton() {
    isPushToNextStep = true
  }
  
  func forcedLogout() {
    NotificationCenter.default.post(name: authorizationManager.logOutForcedName, object: nil)
  }
}
