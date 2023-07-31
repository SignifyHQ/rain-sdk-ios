import Foundation
import NetspendSdk

public protocol NetSpendDataManagerProtocol {
  var jwkToken: NetSpendJwkToken? { get }
  var serverSession: NetSpendSessionData? { get }
  var sdkSession: NetspendSdkUserSession? { get }
  var agreement: NetSpendAgreementData? { get }
  var accountPersonData: NetSpendAccountPersonData? { get }
  var documentData: NetSpendDocumentData? { get set }
  func clear()
  func update(jwkToken: NetSpendJwkToken?)
  func update(serverSession: NetSpendSessionData?)
  func update(agreement: NetSpendAgreementData?)
  func update(sdkSession: NetspendSdkUserSession?)
  func update(accountPersonData: NetSpendAccountPersonData?)
  func update(documentData: NetSpendDocumentData?)
}

public class NetSpendDataManager: NetSpendDataManagerProtocol {
  public var documentData: NetSpendDocumentData?
  public private(set) var jwkToken: NetSpendJwkToken?
  public private(set) var serverSession: NetSpendSessionData?
  public private(set) var agreement: NetSpendAgreementData?
  public private(set) var sdkSession: NetspendSdkUserSession?
  public private(set) var accountPersonData: NetSpendAccountPersonData?
  
  public func update(jwkToken: NetSpendJwkToken?) {
    self.jwkToken = jwkToken
  }
  
  public func update(serverSession: NetSpendSessionData?) {
    self.serverSession = serverSession
  }
  
  public func update(agreement: NetSpendAgreementData?) {
    self.agreement = agreement
  }
  
  public func update(sdkSession: NetspendSdkUserSession?) {
    self.sdkSession = sdkSession
  }
  
  public func update(accountPersonData: NetSpendAccountPersonData?) {
    self.accountPersonData = accountPersonData
  }
  
  public func update(documentData: NetSpendDocumentData?) {
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
