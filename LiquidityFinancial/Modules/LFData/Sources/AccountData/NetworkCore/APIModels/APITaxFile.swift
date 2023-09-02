import Foundation
import AccountDomain

public struct APITaxFile: Decodable, Identifiable, TaxFileEntity {
  public let name, year, url: String?
  public let createdAt: String?
  
  public var id: String {
    "\(name ?? "")-\(year ?? "")-\(UUID().uuidString)"
  }
  
  public var storageName: String {
    "TaxFile-\(year ?? id)-\(name ?? "")"
  }
}
