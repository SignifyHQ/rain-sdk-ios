import SwiftUI
import LFUtilities
import Factory
import OnboardingData
import AccountData
import Services
import Combine

// MARK: - EnterSSNNavigation
public enum EnterSSNNavigation {
  case address(AnyView)
}

// MARK: - EnterSSNViewModel
@MainActor
public final class EnterSSNViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var isActionAllowed: Bool = false
  @Published var ssn: String = .empty
  @Published var errorMessage: String?
  
  public init() {
    observePasswordInput()
  }
}

// MARK: - View Handler
extension EnterSSNViewModel {
  func onAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .viewedSSN))
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onClickedContinueButton(completion: @escaping () -> Void) {
    analyticsService.track(event: AnalyticsEvent(name: .ssnCompleted))
    accountDataManager.update(ssn: ssn)
    completion()
  }
}

// MARK: - Private Functions
private extension EnterSSNViewModel {
  func observePasswordInput() {
    $ssn
      .receive(on: DispatchQueue.main)
      .map { input in
        let inputMinLength = 4
        let trimmedInput = input.trimWhitespacesAndNewlines()
        
        let isValidLength = trimmedInput.count >= inputMinLength
        let isAlphanumeric = trimmedInput.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil
        
        return isValidLength && isAlphanumeric
      }
      .assign(
        to: &$isActionAllowed
      )
  }
}
