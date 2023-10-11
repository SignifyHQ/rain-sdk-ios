import Foundation
import Intercom
import LFUtilities
import Factory
import Combine

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
