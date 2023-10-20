import Foundation
import NetspendSdk
import NetspendDomain

public protocol NetSpendDataManagerProtocol {
  var jwkToken: NSJwkTokenEntity? { get }
  var serverSession: APIEstablishedSessionData? { get }
  var sdkSession: NetspendSdkUserSession? { get }
  var agreement: AgreementDataEntity? { get }
  var fundingAgreement: APIAgreementData? { get }
  var accountPersonData: AccountPersonDataEntity? { get }
  var documentData: APIDocumentData? { get set }
  func clear()
  func update(jwkToken: NSJwkTokenEntity?)
  func update(serverSession: APIEstablishedSessionData?)
  func update(agreement: AgreementDataEntity?)
  func update(sdkSession: NetspendSdkUserSession?)
  func update(accountPersonData: AccountPersonDataEntity?)
  func update(documentData: APIDocumentData?)
  func update(fundingAgreement: APIAgreementData?)
}

public class NetSpendDataManager: NetSpendDataManagerProtocol {
  public var documentData: APIDocumentData?
  public private(set) var jwkToken: NSJwkTokenEntity?
  public private(set) var serverSession: APIEstablishedSessionData?
  public private(set) var agreement: AgreementDataEntity?
  public private(set) var sdkSession: NetspendSdkUserSession?
  public private(set) var accountPersonData: AccountPersonDataEntity?
  public private(set) var fundingAgreement: APIAgreementData?
  
  public func update(jwkToken: NSJwkTokenEntity?) {
    self.jwkToken = jwkToken
  }
  
  public func update(serverSession: APIEstablishedSessionData?) {
    self.serverSession = serverSession
  }
  
  public func update(agreement: AgreementDataEntity?) {
    self.agreement = agreement
  }
  
  public func update(fundingAgreement: APIAgreementData?) {
    self.fundingAgreement = fundingAgreement
  }
  
  public func update(sdkSession: NetspendSdkUserSession?) {
    self.sdkSession = sdkSession
  }
  
  public func update(accountPersonData: AccountPersonDataEntity?) {
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
    fundingAgreement = nil
  }
}
