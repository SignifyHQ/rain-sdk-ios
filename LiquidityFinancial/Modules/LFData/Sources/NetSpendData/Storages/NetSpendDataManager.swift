import Foundation
import NetspendSdk

public protocol NetSpendDataManagerProtocol {
  var jwkToken: APINSJwkToken? { get }
  var serverSession: APISessionData? { get }
  var sdkSession: NetspendSdkUserSession? { get }
  var agreement: APIAgreementData? { get }
  var accountPersonData: APIAccountPersonData? { get }
  var documentData: APIDocumentData? { get set }
  func clear()
  func update(jwkToken: APINSJwkToken?)
  func update(serverSession: APISessionData?)
  func update(agreement: APIAgreementData?)
  func update(sdkSession: NetspendSdkUserSession?)
  func update(accountPersonData: APIAccountPersonData?)
  func update(documentData: APIDocumentData?)
}

public class NetSpendDataManager: NetSpendDataManagerProtocol {
  public var documentData: APIDocumentData?
  public private(set) var jwkToken: APINSJwkToken?
  public private(set) var serverSession: APISessionData?
  public private(set) var agreement: APIAgreementData?
  public private(set) var sdkSession: NetspendSdkUserSession?
  public private(set) var accountPersonData: APIAccountPersonData?
  
  public func update(jwkToken: APINSJwkToken?) {
    self.jwkToken = jwkToken
  }
  
  public func update(serverSession: APISessionData?) {
    self.serverSession = serverSession
  }
  
  public func update(agreement: APIAgreementData?) {
    self.agreement = agreement
  }
  
  public func update(sdkSession: NetspendSdkUserSession?) {
    self.sdkSession = sdkSession
  }
  
  public func update(accountPersonData: APIAccountPersonData?) {
    self.accountPersonData = accountPersonData
  }
  
  public func update(documentData: APIDocumentData?) {
    self.documentData = documentData
  }
  
  public func clear() {
    jwkToken = nil
    serverSession = nil
    agreement = nil
    sdkSession = nil
    documentData = nil
  }
}
