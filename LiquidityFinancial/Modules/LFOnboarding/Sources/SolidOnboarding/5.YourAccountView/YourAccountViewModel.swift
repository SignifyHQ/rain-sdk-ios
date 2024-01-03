import Factory
import AccountData
import AccountDomain
import Foundation
import LFLocalizable
import LFUtilities

class YourAccountViewModel: ObservableObject {
  
  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .agreement(let url):
        return url.absoluteString
      }
    }
    
    case agreement(URL)
  }
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var shouldContinue: Bool = false
  @Published var isEsignatureAccepted: Bool = false
  @Published var isTermsPrivacyAccepted: Bool = false
  
  let esignString = LFLocalizable.YourAccount.Agreements.esignature
  let agreementString = LFLocalizable.YourAccount.Agreements.consumerTermsConditions
  
  let esignLink = LFLocalizable.YourAccount.Links.esignature
  let consumerLink = LFLocalizable.YourAccount.Links.consumerCardholder
  let termsLink = LFLocalizable.YourAccount.Links.terms
  let privacyLink = LFLocalizable.YourAccount.Links.privacy
  
  var remoteURLs: RemoteLinks?
  
  lazy var accountUseCase: AccountUseCaseProtocol = {
    AccountUseCase(repository: accountRepository)
  }()
  
  init() {
    getFeatureConfig()
  }
  
  private func getFeatureConfig() {
    Task {
      do {
        let response = try await accountUseCase.getFeatureConfig()
        let configJSON = response.config ?? ""
        
        remoteURLs = AccountFeatureConfig(configJSON: configJSON).featureConfig?.remoteLinks
      } catch {
        log.debug(error.userFriendlyMessage)
      }
    }
  }
  
  func getUrl(for link: String) -> URL? {
    switch link {
    case esignLink:
      return URL(string: remoteURLs?.esignatureLink ?? LFUtilities.termsURL)
    case consumerLink:
      return URL(string: remoteURLs?.consumerAccountLink ?? LFUtilities.termsURL)
    case termsLink:
      return URL(string: remoteURLs?.termConditionLink ?? LFUtilities.termsURL)
    case privacyLink:
      return URL(string: remoteURLs?.privacyPolicyLink ?? LFUtilities.termsURL)
    default:
      return nil
    }
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}
