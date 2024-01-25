import Factory
import AccountData
import AccountDomain
import Foundation
import LFLocalizable
import LFUtilities

public class YourAccountViewModel: ObservableObject {
  
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
  
  let esignString = L10N.Common.YourAccount.Agreements.esignature
  let agreementString = L10N.Common.YourAccount.Agreements.consumerTermsConditions
  
  let esignLink = L10N.Common.YourAccount.Links.esignature
  let consumerLink = L10N.Common.YourAccount.Links.consumerCardholder
  let termsLink = L10N.Common.YourAccount.Links.terms
  let privacyLink = L10N.Common.YourAccount.Links.privacy
  
  var remoteURLs: RemoteLinks?
  
  lazy var accountUseCase: AccountUseCaseProtocol = {
    AccountUseCase(repository: accountRepository)
  }()
  
  public init() {
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
