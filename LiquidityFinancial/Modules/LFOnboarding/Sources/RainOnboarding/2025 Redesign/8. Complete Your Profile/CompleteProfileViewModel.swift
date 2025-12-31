import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import RainData
import RainDomain

@MainActor
public final class CompleteProfileViewModel: ObservableObject {
  @LazyInjected(\.rainRepository) var rainRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var navigation: Navigation?
  
  @Published var isLoadingOccupationList: Bool = false
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  
  @Published var selectedCategory: CompleteProfileCategory?
  @Published var selectedOptions: [CompleteProfileCategory: CompleteProfileCategoryOption?] = [
    .occupation: nil,
    .salary: nil,
    .accountPurpose: nil,
    .spend: nil
  ]
  
  @Published private var occupationList: [APIOccupation] = []
  
  @Published var occupationListFiltered: [APIOccupation] = []
  @Published var searchQuery: String = .empty
  
  lazy var getOccupationListUseCase: GetOccupationListUseCaseProtocol = {
    return GetOccupationListUseCase(repository: rainRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    selectedOptions[.occupation]??.value != nil &&
    selectedOptions[.salary]??.value != nil &&
    selectedOptions[.accountPurpose]??.value != nil &&
    selectedOptions[.spend]??.value != nil
  }
  
  init(
  ) {
    bindSearchQueries()
    getOccupationList()
  }
}

// MARK: - Binding Observables
extension CompleteProfileViewModel {
  private func bindSearchQueries() {
    Publishers
      .CombineLatest(
        $searchQuery,
        $occupationList
      )
      .map { searchQuery, allCases in
        let trimmedQuery = searchQuery.trimWhitespacesAndNewlines().lowercased()
        
        guard !trimmedQuery.isEmpty
        else {
          return allCases
        }
        
        return allCases
          .filter { occupation in
            occupation.occupation.lowercased().contains(trimmedQuery)
          }
      }
      .assign(
        to: &$occupationListFiltered
      )
  }
}

// MARK: - Handling API Calls
extension CompleteProfileViewModel {
  private func getOccupationList() {
    Task {
      defer {
        isLoadingOccupationList = false
      }
      
      isLoadingOccupationList = true
      
      do {
        let occupationListResponse = try await getOccupationListUseCase.execute()
        
        self.occupationList = occupationListResponse
          .sorted {
            $0.occupation < $1.occupation
          } as? [APIOccupation] ?? []
      } catch {
        log.error(error)
        
        currentToast = ToastData(
          type: .error,
          title: "Error occured",
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

// MARK: - Handling UI/UX Logic
extension CompleteProfileViewModel {
}

// MARK: - Handling Interations
extension CompleteProfileViewModel {
  func onSupportButtonTap() {
    hideSelections()
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    let additionalProfileInformation: AdditionalProfileInformation = AdditionalProfileInformation(
      occupation: selectedOptions[.occupation]??.id,
      annualSalary: selectedOptions[.salary]??.value,
      accountPurpose: selectedOptions[.accountPurpose]??.value,
      expectedMonthlyVolume: selectedOptions[.spend]??.value
    )
    
    hideSelections()
    navigation = .ssnInput(additionalProfileInformation: additionalProfileInformation)
  }
  
  func hideSelections() {
    selectedCategory = nil
  }
}

// MARK: - Helper Functions
extension CompleteProfileViewModel {
  func options(
    for category: CompleteProfileCategory
  ) -> [CompleteProfileCategoryOption] {
    switch category {
    case .occupation:
      occupationListFiltered
        .map { occupation in
          CompleteProfileCategoryOption(
            id: occupation.code,
            value: occupation.occupation
          )
        }
    default:
      category.options
    }
  }
}

// MARK: - Private Enums
extension CompleteProfileViewModel {
  enum Navigation {
    case ssnInput(additionalProfileInformation: AdditionalProfileInformation)
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
      "Annual salary"
    case .accountPurpose:
      "Primary account purpose"
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
      []
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
  var id: String = UUID().uuidString
  let value: String
}
