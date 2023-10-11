import Foundation

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
