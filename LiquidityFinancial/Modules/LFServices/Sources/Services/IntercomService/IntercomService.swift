import Foundation
import Intercom
import LFUtilities
import Factory
import Combine
import EnvironmentService

public class IntercomService: CustomerSupportServiceProtocol {
  
  public private(set) var isLoginIdentifiedSuccess: Bool = false
  
  private var subscriptions = Set<AnyCancellable>()
  
  let eventLoggin: PassthroughSubject<UserAttributes?, Never>
  let eventLogout: PassthroughSubject<Void, Never>
  init() {
    eventLoggin = PassthroughSubject<UserAttributes?, Never>()
    eventLogout = PassthroughSubject<Void, Never>()
    
    eventLoggin.sink { [weak self] userAttributes in
      if let att = userAttributes {
        self?.loginIdentifiedUser(userAttributes: att)
      } else {
        self?.loginUnidentifiedUser()
      }
    }
    .store(in: &subscriptions)
    
    eventLogout
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.logout()
      }
    .store(in: &subscriptions)
    
    NotificationCenter.default
      .publisher(for: .environmentChanage)
      .compactMap({ ($0.userInfo?[Notification.Name.environmentChanage.rawValue] as? NetworkEnvironment) })
      .sink { [weak self] value in
        log.debug("Setup environment for IntercomService with: \(value)")
        self?.setUp(environment: value)
      }
      .store(in: &subscriptions)
  }
  
  public func pushEventLogin(with userAttributes: UserAttributes?) {
    if let userAttributes = userAttributes {
      eventLoggin.send(userAttributes)
    } else {
      eventLoggin.send(nil)
    }
  }
  
  public func pushEventLogout() {
    eventLogout.send(())
  }
  
  public func setUp(environment: NetworkEnvironment) {
    let apiKey = environment == .productionTest ? Configs.Intercom.apiKeySandBox : Configs.Intercom.apiKey
    let appID = environment == .productionTest ? Configs.Intercom.appIDSandBox : Configs.Intercom.appID
    Intercom.setApiKey(apiKey, forAppId: appID)
    Intercom.setLauncherVisible(false)
  }
  
  public func openSupportScreen() {
    Intercom.present()
  }
  
  public func logout() {
    Intercom.logout()
  }
  
  public func loginUnidentifiedUser() {
    Intercom.loginUnidentifiedUser { result in
      switch result {
      case .success:
        log.info("IntercomService login UnidentifiedUser is success")
      case .failure(let error):
        log.error(error.localizedDescription)
      }
    }
  }
  
  public func loginIdentifiedUser(userAttributes: UserAttributes) {
    let attributes = ICMUserAttributes()
    attributes.phone = userAttributes.phone
    if let email = userAttributes.email {
      attributes.email = email
    }
    if let userId = userAttributes.userId {
      attributes.userId = userId
    }
    Intercom.loginUser(with: attributes) { [weak self] result in
      switch result {
      case .success:
        log.info("IntercomService login IdentifiedUser is success: \(userAttributes.phone)")
        self?.isLoginIdentifiedSuccess = true
      case .failure(let error):
        log.error(error.localizedDescription)
      }
    }
  }
}
