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
  
  private let isVerifySSN: Bool
  
  private var cancellables: Set<AnyCancellable> = []
  
  public init(isVerifySSN: Bool) {
    self.isVerifySSN = isVerifySSN
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
      .sink { [weak self] ssn in
        guard let self else { return }
        let ssnMaxLength = self.isVerifySSN
        ? Constants.MaxCharacterLimit.fullSSNLength.value
        : Constants.MaxCharacterLimit.ssnLength.value
        let isSSNValidString = !ssn.trimWhitespacesAndNewlines().isEmpty
        let isSSNValidLength = ssn.trimWhitespacesAndNewlines().count == ssnMaxLength
        
        self.isActionAllowed = isSSNValidString && isSSNValidLength
      }
      .store(in: &cancellables)
  }
}
