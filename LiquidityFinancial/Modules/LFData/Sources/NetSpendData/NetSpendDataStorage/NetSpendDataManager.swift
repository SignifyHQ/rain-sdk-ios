import Foundation
import NetspendSdk

public protocol NetSpendDataManagerProtocol {
  var jwkToken: NetSpendJwkToken? { get }
  var session: NetSpendSessionData? { get }
  var userSession: NetspendSdkUserSession? { get }
  var agreement: NetSpendAgreementData? { get }
  var accountPersonData: NetSpendAccountPersonData? { get }
  func clear()
  func update(jwkToken: NetSpendJwkToken?)
  func update(session: NetSpendSessionData?)
  func update(agreement: NetSpendAgreementData?)
  func update(userSession: NetspendSdkUserSession?)
  func update(accountPersonData: NetSpendAccountPersonData?)
}

public class NetSpendDataManager: NetSpendDataManagerProtocol {
  public private(set) var jwkToken: NetSpendJwkToken?
  public private(set) var session: NetSpendSessionData?
  public private(set) var agreement: NetSpendAgreementData?
  public private(set) var userSession: NetspendSdkUserSession?
  public private(set) var accountPersonData: NetSpendAccountPersonData?
  
  public func update(jwkToken: NetSpendJwkToken?) {
    self.jwkToken = jwkToken
  }
  
  public func update(session: NetSpendSessionData?) {
    self.session = session
  }
  
  public func update(agreement: NetSpendAgreementData?) {
    self.agreement = agreement
  }
  
  public func update(userSession: NetspendSdkUserSession?) {
    self.userSession = userSession
  }
  
  public func update(accountPersonData: NetSpendAccountPersonData?) {
    self.accountPersonData = accountPersonData
  }
  
  public func clear() {
    jwkToken = nil
    session = nil
    agreement = nil
    userSession = nil
  }
}
