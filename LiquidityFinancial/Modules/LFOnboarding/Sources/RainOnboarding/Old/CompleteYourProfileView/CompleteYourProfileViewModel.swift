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
  
  @Published var isLoadingOccupationList: Bool = false
  @Published var isLoading: Bool = false
  @Published var isContinueButtonEnabled: Bool = false
  @Published var toastMessage: String?
  
  var occupationList: [APIOccupation] = []
  
  @Published var selectedCategory: CompleteProfileCategory?
  @Published var selectedOptions: [CompleteProfileCategory: CompleteProfileCategoryOption?] = [
    .occupation: nil,
    .salary: nil,
    .accountPurpose: nil,
    .spend: nil
  ]
  
  lazy var getOccupationListUseCase: GetOccupationListUseCaseProtocol = {
    return GetOccupationListUseCase(repository: rainRepository)
  }()
  
  
  lazy var createRainAccountUseCase: CreateRainAccountUseCaseProtocol = {
    return CreateRainAccountUseCase(repository: rainRepository)
  }()
  
  init() {
    getOccupationList()
    observeUserInput()
  }
  
  func options(
    for category: CompleteProfileCategory
  ) -> [CompleteProfileCategoryOption] {
    switch category {
    case .occupation:
      occupationList
        .map { occupation in
          CompleteProfileCategoryOption(id: occupation.code, value: occupation.occupation)
        }
    default:
      category.options
    }
  }
}

// MARK: - API Handle
extension CompleteYourProfileViewModel {
  private func getOccupationList() {
    Task {
      defer { isLoadingOccupationList = false }
      isLoadingOccupationList = true
      
      do {
        let occupationList = try await getOccupationListUseCase.execute()
        self.occupationList = occupationList.sorted { $0.occupation < $1.occupation } as? [APIOccupation] ?? []
      } catch {
        log.error(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  private func createRainUser() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let parameters = createRainPersonParameters()
        _ = try await createRainAccountUseCase.execute(parameters: parameters)
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
    $selectedOptions
      .map { selectedOptions in
        selectedOptions[.occupation]??.value != nil &&
        selectedOptions[.salary]??.value != nil &&
        selectedOptions[.accountPurpose]??.value != nil &&
        selectedOptions[.spend]??.value != nil
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
      occupation: selectedOptions[.occupation]??.id,
      annualSalary: selectedOptions[.salary]??.value,
      accountPurpose: selectedOptions[.accountPurpose]??.value,
      expectedMonthlyVolume: selectedOptions[.spend]??.value,
      iovationBlackbox: FraudForce.blackbox()
    )
  }
}
