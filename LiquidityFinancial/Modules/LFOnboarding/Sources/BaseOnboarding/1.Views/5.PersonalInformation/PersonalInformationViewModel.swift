import SwiftUI
import Factory
import AccountData
import LFUtilities
import Services
import LFLocalizable
import Combine

// MARK: - PersonalInformationNavigation
public enum PersonalInformationNavigation {
  case enterSSN(AnyView)
}

// MARK: - PersonalInformationViewModel
@MainActor
public final class PersonalInformationViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var isActionAllowed: Bool = false
  @Published var firstName: String = .empty
  @Published var lastName: String = .empty
  @Published var email: String = .empty
  @Published var dateOfBirth: String = .empty
  @Published var dateCheck: Date?
  @Published var toastMessage: String?
  
  private var fullName: String = .empty
  private var cancellables = Set<AnyCancellable>()
  
  public init() {
    observeUserInput()
  }
}

// MARK: - View Handler
extension PersonalInformationViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onClickedContinueButton(completion: @escaping () -> Void) {
    fullName = firstName + " " + lastName
    
    if fullName.count > 23 {
      toastMessage = L10N.Common.nameExceedMessage
    } else {
      analyticsService.track(event: AnalyticsEvent(name: .personalInfoCompleted))
      updateUserInformation()
      completion()
    }
  }
  
  func onAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .viewedPersonalInfo))
  }
}

// MARK: - Private Functions
private extension PersonalInformationViewModel {
  func observeUserInput() {
    Publishers.CombineLatest4($firstName, $lastName, $email, $dateOfBirth)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _, _, _, _ in
        self?.isAllDataFilled()
      }
      .store(in: &cancellables)
    
    $dateCheck
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.isAllDataFilled()
      }
      .store(in: &cancellables)
  }
  
  func isAllDataFilled() {
    let isValidFirstName = !firstName.trimWhitespacesAndNewlines().isEmpty
    let isValidLastName = !lastName.trimWhitespacesAndNewlines().isEmpty
    let isValidEmail = !email.trimWhitespacesAndNewlines().isEmpty && email.trimWhitespacesAndNewlines().isValidEmail()
    
    isActionAllowed = isValidFirstName && isValidLastName && isValidEmail && dateCheck != nil
  }
  
  func updateUserInformation() {
    accountDataManager.update(email: email)
    accountDataManager.update(firstName: firstName)
    accountDataManager.update(lastName: lastName)
    accountDataManager.update(fullName: fullName)
    accountDataManager.userNameDisplay = firstName
    accountDataManager.userEmail = email
    
    if let dateCheck {
      let dateOfBirth = LiquidityDateFormatter.simpleDate.parseToString(from: dateCheck)
      accountDataManager.update(dateOfBirth: dateOfBirth)
    }
    
    if accountDataManager.userInfomationData.phone == nil {
      accountDataManager.update(phone: UserDefaults.phoneCode + UserDefaults.phoneNumber)
    }
  }
}
