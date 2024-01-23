import Factory
import Foundation
import AccountData
import AccountDomain
import LFLocalizable
import LFUtilities
import EnvironmentService

class PatriotActViewModel: ObservableObject {
  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .privacy(let url):
        return url.absoluteString
      }
    }
    
    case privacy(URL)
  }
  
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var shouldContinue: Bool = false
  @Published var isNoticeAccepted: Bool = false
  
  let patriotActString = L10N.Common.PatriotAct.Agreements.partiotActNotice
  let patriotActlink = L10N.Common.PatriotAct.Links.partiotActNotice
  
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
    case patriotActlink:
      return URL(string: remoteURLs?.patriotNoticeLink ?? LFUtilities.termsURL)
    default:
      return nil
    }
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}
