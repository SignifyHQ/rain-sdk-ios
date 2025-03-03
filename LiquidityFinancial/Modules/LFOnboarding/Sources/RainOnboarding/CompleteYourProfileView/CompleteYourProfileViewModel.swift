import Combine
import Factory
import Foundation
import FraudForce
import LFLocalizable
import LFUtilities
import RainData
import RainDomain

@MainActor
final class CompleteYourProfileViewModel: ObservableObject {
  @LazyInjected(\.rainOnboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @LazyInjected(\.rainRepository) var rainRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isLoading: Bool = false
  @Published var isContinueButtonEnabled: Bool = false
  @Published var toastMessage: String?
  
  @Published var selectedCategory: CompleteProfileCategory?
  
  @Published var occupationString: String?
  @Published var salaryString: String?
  @Published var purposeString: String?
  @Published var spendString: String?
  
  var selectedOptions: [CompleteProfileCategory: String?] {
    get {
      [
        .occupation: occupationString,
        .salary: salaryString,
        .accountPurpose: purposeString,
        .spend: spendString
      ]
    }
    set {
      occupationString = newValue[.occupation] ?? occupationString
      salaryString = newValue[.salary] ?? salaryString
      purposeString = newValue[.accountPurpose] ?? purposeString
      spendString = newValue[.spend] ?? spendString
    }
  }
  
  lazy var createRainAccount: CreateRainAccountUseCaseProtocol = {
    return CreateRainAccountUseCase(repository: rainRepository)
  }()
  
  init() {
    observeUserInput()
  }
}

// MARK: - API Handle
extension CompleteYourProfileViewModel {
  private func createRainUser() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
         let parameters = createRainPersonParameters()
         _ = try await createRainAccount.execute(parameters: parameters)
         try await onboardingFlowCoordinator.fetchOnboardingMissingSteps()
      } catch {
        log.error(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Handle
extension CompleteYourProfileViewModel {
  func onAppear() {
    
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTapped() {
    createRainUser()
  }
}

// MARK: - Private Functions
private extension CompleteYourProfileViewModel {
  func observeUserInput() {
    Publishers.CombineLatest4($occupationString, $salaryString, $purposeString, $spendString)
      .map { occupation, salary, purpose, spend in
        occupation.isNotNil && salary.isNotNil && purpose.isNotNil && spend.isNotNil
      }
      .assign(
        to: &$isContinueButtonEnabled
      )
  }
  
  func createRainPersonParameters() -> APIRainPersonParameters {
    let rainAddress = RainAddressParameters(
      line1: accountDataManager.userInfomationData.addressLine1 ?? .empty,
      line2: accountDataManager.userInfomationData.addressLine2 ?? .empty,
      city: accountDataManager.userInfomationData.city ?? .empty,
      region: accountDataManager.userInfomationData.state ?? .empty,
      postalCode: accountDataManager.userInfomationData.postalCode ?? .empty,
      countryCode: accountDataManager.country?.uppercased() ?? "",
      country: accountDataManager.userInfomationData.country ?? .empty
    )
    
    return APIRainPersonParameters(
      firstName: accountDataManager.userInfomationData.firstName ?? .empty,
      lastName: accountDataManager.userInfomationData.lastName ?? .empty,
      birthDate: accountDataManager.userInfomationData.dateOfBirth ?? .empty,
      nationalId: accountDataManager.userInfomationData.ssn ?? .empty,
      countryOfIssue: accountDataManager.country?.uppercased() ?? "",
      email: accountDataManager.userInfomationData.email ?? .empty,
      address: rainAddress,
      phoneCountryCode: accountDataManager.phoneCode,
      phoneNumber: accountDataManager.phoneNumber,
      occupation: occupationString,
      annualSalary: salaryString,
      accountPurpose: purposeString,
      expectedMonthlyVolume: spendString,
      iovationBlackbox: FraudForce.blackbox()
    )
  }
}

enum CompleteProfileCategory: CaseIterable {
  case occupation
  case salary
  case accountPurpose
  case spend
  
  var title: String {
    switch self {
    case .occupation:
      "Occupation"
    case .salary:
      "Annual Salary"
    case .accountPurpose:
      "Primary Account Purpose"
    case .spend:
      "How much do you expect to spend each month?"
    }
  }
  
  var placeholder: String {
    switch self {
    case .occupation:
      "Select your occupation"
    case .salary:
      "Select salary range"
    case .accountPurpose:
      "Select account purpose"
    case .spend:
      "Select expected monthly spend amount"
    }
  }
  
  var options: [CompleteProfileCategoryOption] {
    switch self {
    case .occupation:
      [
        CompleteProfileCategoryOption(value: "Employed"),
        CompleteProfileCategoryOption(value: "Self-Employed"),
        CompleteProfileCategoryOption(value: "Business owner"),
        CompleteProfileCategoryOption(value: "Student"),
        CompleteProfileCategoryOption(value: "Retired"),
        CompleteProfileCategoryOption(value: "Other"),
      ]
    case .salary:
      [
        CompleteProfileCategoryOption(value: "$0 – $25,000"),
        CompleteProfileCategoryOption(value: "$25,001 – $50,000"),
        CompleteProfileCategoryOption(value: "$50,001 – $75,000"),
        CompleteProfileCategoryOption(value: "$75,001 – $100,000"),
        CompleteProfileCategoryOption(value: "$100,001+"),
      ]
    case .accountPurpose:
      [
        CompleteProfileCategoryOption(value: "Savings"),
        CompleteProfileCategoryOption(value: "Investments"),
        CompleteProfileCategoryOption(value: "Business Transactions"),
        CompleteProfileCategoryOption(value: "Personal Spending"),
        CompleteProfileCategoryOption(value: "Other"),
      ]
    case .spend:
      [
        CompleteProfileCategoryOption(value: "$0 – $1,000"),
        CompleteProfileCategoryOption(value: "$1,001 – $5,000"),
        CompleteProfileCategoryOption(value: "$5,001 – $10,000"),
        CompleteProfileCategoryOption(value: "$10,001 – $50,000"),
        CompleteProfileCategoryOption(value: "$50,001+")
      ]
    }
  }
}

struct CompleteProfileCategoryOption {
  let id: String = UUID().uuidString
  let value: String
}
