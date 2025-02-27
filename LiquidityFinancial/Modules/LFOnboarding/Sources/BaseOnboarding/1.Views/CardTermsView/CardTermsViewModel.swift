import Combine
import Factory
import Foundation
import LFLocalizable
import LFUtilities
import RainData
import RainDomain

// MARK: - CardTermsViewModel
@MainActor
public final class CardTermsViewModel: ObservableObject {
  @InjectedObject(\.onboardingDestinationObservable) var onboardingDestinationObservable
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.rainRepository) var rainRepozitory

  @LazyInjected(\.customerSupportService) var customerSupportService
  
  lazy var rainAcceptTermsUseCase: RainAcceptTermsUseCaseProtocol = {
    RainAcceptTermsUseCase(repository: rainRepozitory)
  }()
  
  @Published var isLoading: Bool = false
  @Published var isButtonEnabled: Bool = false
  
  @Published var isAccountDisclosureAgreed: Bool = false
  @Published var areCardTermsAgreed: Bool = false
  @Published var isInfoAccurateAgreed: Bool = false
  @Published var isAcknowledgmentAgreed: Bool = false
  
  @Published var toastMessage: String?
  
  let accountDisclosures = L10N.Common.Term.AccountDisclosures.attributeText
  let cardTerms = L10N.Common.Term.CardTerms.attributeText
  
  var isUS: Bool {
    accountDataManager.country?.lowercased() == "us"
  }
  
  private let handleOnboardingStep: (() async throws -> Void)?
  private let forceLogout: (() -> Void)?
  
  private var cancellables: Set<AnyCancellable> = []
  
  public init(
    handleOnboardingStep: (() async throws -> Void)?,
    forceLogout: (() -> Void)?
  ) {
    self.handleOnboardingStep = handleOnboardingStep
    self.forceLogout = forceLogout
    
    observeInput()
  }
}

// MARK: - APIs Handler
extension CardTermsViewModel {
  func acceptTerms() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        try await rainAcceptTermsUseCase.execute()
        try await handleOnboardingStep?()
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - View Handler
extension CardTermsViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func getURL(tappedString: String) -> URL? {
    let urlMapping: [String: String] = [
      accountDisclosures: LFUtilities.accountDisclosureURL,
      cardTerms: isUS ? LFUtilities.cardTermsURLUs : LFUtilities.cardTermsURLInt
    ]
    
    return urlMapping[tappedString].flatMap { URL(string: $0) }
  }
}

// MARK: - Private Functions
private extension CardTermsViewModel {
  func handleError(error: Error) {
    toastMessage = error.userFriendlyMessage
  }
  
  private func observeInput() {
    Publishers.CombineLatest4($isAccountDisclosureAgreed, $areCardTermsAgreed, $isInfoAccurateAgreed, $isAcknowledgmentAgreed)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isAccountDisclosureAgreed, areCardTermsAgreed, isInfoAccurateAgreed, isAcknowledgmentAgreed in
        guard let self else { return }
        
        self.isButtonEnabled = (isAccountDisclosureAgreed || !isUS) && areCardTermsAgreed && isInfoAccurateAgreed && isAcknowledgmentAgreed
      }
      .store(in: &cancellables)
  }
}

// MARK: - Types
extension CardTermsViewModel {
  enum OpenSafariType: String, Identifiable {
    var id: String {
      self.rawValue
    }
    
    case accountDisclosures
    case cardTerms
  }
}
