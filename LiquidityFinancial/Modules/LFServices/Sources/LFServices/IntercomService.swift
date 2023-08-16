import Foundation
import Intercom
import LFUtilities
import Factory
import Combine

extension Container {
  public var intercomService: Factory<IntercomServiceProtocol> {
    self {
      IntercomService()
    }.singleton
  }
}

public protocol IntercomServiceProtocol {
  func openIntercom()
  func loginUnidentifiedUser()
  func loginIdentifiedUser(userAttributes: IntercomService.UserAttributes)
  func pushEventLogin(with userAttributes: IntercomService.UserAttributes?)
  func pushEventLogout()
}

public class IntercomService: IntercomServiceProtocol {
  
  public struct UserAttributes {
    public var phone: String
    public var userId: String?
    public var email: String?
    public var custon: CustomAttributes?
    
    public init(phone: String, userId: String? = nil, email: String? = nil, custon: CustomAttributes? = nil) {
      self.phone = phone
      self.userId = userId
      self.email = email
      self.custon = custon
    }
    
    public struct CustomAttributes {
      public var appStatus: String?
      public var bundleName: String?
      
      public init(appStatus: String? = nil, bundleName: String? = nil) {
        self.appStatus = appStatus
        self.bundleName = bundleName
      }
    }
  }
  
  private var subscriptions = Set<AnyCancellable>()
  
  let eventLoggin: PassthroughSubject<IntercomService.UserAttributes?, Never>
  let eventLogout: PassthroughSubject<Void, Never>
  init() {
    eventLoggin = PassthroughSubject<IntercomService.UserAttributes?, Never>()
    eventLogout = PassthroughSubject<Void, Never>()
    
    eventLoggin.sink { [weak self] userAttributes in
      if let att = userAttributes {
        self?.loginIdentifiedUser(userAttributes: att)
      } else {
        self?.loginUnidentifiedUser()
      }
    }
    .store(in: &subscriptions)
    
    eventLogout.sink { [weak self] _ in
      self?.logout()
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
  
  public func openIntercom() {
    //analyticsService.track(event: Event(name: .openIntercom))
    Intercom.present()
  }
  
  public func logout() {
    Intercom.logout()
  }
  
  public func loginUnidentifiedUser() {
    Intercom.loginUnidentifiedUser { result in
      switch result {
      case .success:
        log.debug("IntercomService login UnidentifiedUser is success")
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
    Intercom.loginUser(with: attributes) { result in
      switch result {
      case .success:
        log.debug("IntercomService login IdentifiedUser is success: \(userAttributes.phone)")
      case .failure(let error):
        log.error(error.localizedDescription)
      }
    }
  }
}
